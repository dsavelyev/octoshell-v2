module Quotas
  class QuotaSynchronizer
    include Sidekiq::Worker
    sidekiq_options queue: :synchronizer, retry: 0, backtrace: true

    # We use our own retry mechanism
    MAX_RETRIES = 5
    RETRY_DELAY = 5.minutes

    def perform(params)
      try = params.delete('try') || 1

      q = Quota.includes(:subject, :domain, kind: :cluster)
               .find_or_initialize_by(params)

      cluster = q.kind.cluster
      cmd = cmd_from_quota(q)

      # TODO: record the result somewhere
      status =
        case (exit_code = SyncUtil.run_on_cluster(cluster, cmd))
        when 0
          :success
        when 1
          enqueue_retry(params, try)
          :retry
        else
          raise "failed after #{try} tries, exit code #{exit_code.inspect}"
        end
    ensure
      unless status == :retry
        # refetch the same quota (could have changed id/lock_version)
        Quota.with_quota_by(params) do |q|
          status == :success && q.current_value = q.desired_value
          q.syncing = false
        end
      end
    end

    private

    def enqueue_retry(params, try)
      raise "retries exhausted (#{try})" if try >= MAX_RETRIES

      params = params.merge('try' => try + 1)
      return if self.class.perform_in(RETRY_DELAY, params)

      raise "could not requeue job for try #{try + 1}"
    end

    def cmd_from_quota(q)
      raise 'subject invalid' if !q.subject && q.subject_id

      cluster = q.kind.cluster

      cmd = Shellwords.escape("/usr/octo/quotas/sync-#{q.kind.name_on_cluster}")

      project =
        case q.subject
        when Core::Project
          q.subject
        when Core::Member
          q.subject.project
        end

      access = project && project.accesses.find_by!(cluster: cluster)

      case q.subject
      when Core::Project
        cmd << " -g #{Shellwords.escape(access.project_group_name)}"
      when Core::Member
        cmd << " -u #{Shellwords.escape(q.subject.login)}"
      end

      if q.domain.is_a? Core::Partition
        cmd << " -p #{Shellwords.escape(q.domain.name)}"
      end

      cmd << " #{q.desired_value}"

      cmd
    end
  end
end
