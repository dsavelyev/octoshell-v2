module Quotas
  class QuotaSynchronizer
    include Sidekiq::Worker
    sidekiq_options queue: :synchronizer, retry: 0, backtrace: true

    include SyncWorkerBase

    # We use our own retry mechanism
    self.max_tries = 5
    self.retry_delay = 5.minutes

    def perform(id_list, try = 1)
      successes = []
      retries = []

      id_list.each do |ids|
        q = Quota.includes(:subject, :domain, kind: :cluster)
                 .find_or_initialize_by(ids)

        cluster, cmd = cluster_cmd_from_quota(q)

        case run_on_cluster(cluster, cmd)[:exit_code]
        when 0
          successes << [ids, q.desired_value]
        when 1
          retries << ids
        end
      end

      enqueue_retry(retries, try + 1) if !retries.empty?

    ensure
      failures = id_list - successes - retries

      successes.each do |[params, desired_value]|
        # refetch the same quota (could have changed id/lock_version)
        Quota.with_quota_by(params) do |q|
          q.current_value = desired_value
          q.syncing = false
        end
      end

      failures.each do |params|
        Quota.with_quota_by(params) do |q|
          q.syncing = false
        end
      end
    end

    module_function

    def cluster_cmd_from_quota(q, mode=:sync)
      if q.subject_id
        (subject = q.subject) || raise('subject id invalid')
        (project = q.project) || raise('project id invalid')
      end

      kind = q.kind
      kind || raise('quota kind id invalid')

      cluster = kind.cluster
      cluster || raise('cluster id invalid')

      domain = q.domain
      domain || raise('domain invalid')

      access = project && project.accesses.find_by!(cluster: cluster)

      cmd = Shellwords.escape("/usr/octo/quotas/#{mode.to_s}-#{kind.name_on_cluster}")

      case subject
      when Core::Project
        cmd << " -g #{Shellwords.escape(access.project_group_name)}"
      when Core::Member
        cmd << " -u #{Shellwords.escape(subject.login)}"
      end

      if domain.is_a? Core::Partition
        cmd << " -p #{Shellwords.escape(domain.name)}"
      end

      if mode == :sync
        cmd << " #{q.desired_value || "nil"}"
      end

      [cluster, cmd]
    end
  end
end
