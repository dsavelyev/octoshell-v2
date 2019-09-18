module Quotas
  class OverrideSemanticsSynchronizer
    include Sidekiq::Worker
    sidekiq_options queue: :synchronizer, retry: 0, backtrace: true

    include SyncWorkerHelper

    self.max_tries = 5
    self.retry_delay = 5.minutes

    def perform(id, try = 1)
      osd = OverrideSemanticsData.find(id)
      cqk = osd.cluster_quota_kind
      cluster = cqk.cluster

      cmd = Shellwords.escape("/usr/octo/quotas/sync-semantics-#{cqk.name_on_cluster}")
      cmd << " #{Shellwords.escape(osd.desired_priority.join(','))}"

      status =
        case (exit_code = run_on_cluster(cluster, cmd)[:exit_code])
        when 0
          :success
        when 1
          enqueue_retry(id, try + 1)
          :retry
        else
          raise "override semantics sync of #{id} failed with exit code #{exit_code.inspect}, cmd was #{cmd}"
        end
    ensure
      unless status == :retry
        status == :success && osd.current_priority = osd.desired_priority
        osd.syncing = false
        osd.save!
      end
    end
  end
end
