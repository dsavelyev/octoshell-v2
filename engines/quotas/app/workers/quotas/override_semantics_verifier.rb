module Quotas
  class OverrideSemanticsVerifier
    include Sidekiq::Worker
    sidekiq_options queue: :synchronizer, retry: 0, backtrace: true

    include SyncWorkerBase

    self.max_tries = 5
    self.retry_delay = 5.minutes

    def perform(id, try = 1)
      valid_scopes = OverrideSemanticsData::VALID_SCOPES

      osd = OverrideSemanticsData.find(id)
      cqk = osd.cluster_quota_kind
      cluster = cqk.cluster

      cmd = Shellwords.escape("/usr/octo/quotas/get-semantics-#{cqk.name_on_cluster}")

      exit_code, stdout = run_on_cluster(cluster, cmd)

      status =
        case exit_code
        when 0
          prio = stdout.split(",").map(&:to_sym)
          if prio.length == valid_scopes.length && Set.new(prio) == valid_scopes
            osd.current_priority = prio
            :success
          else
            :failure
          end
        when 1
          enqueue_retry(id, try + 1)
          :retry
        else
          :failure
        end

      osd.save! if osd.changed?
    end
  end
end
