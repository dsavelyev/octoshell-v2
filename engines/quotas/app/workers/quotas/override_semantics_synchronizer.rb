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

      status = run_script_on_cluster(cluster, cmd, try, id)
    ensure
      unless status == :retry
        status == :success && osd.current_priority = osd.desired_priority
        osd.syncing = false
        osd.save!
      end
    end
  end
end
