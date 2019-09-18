module Quotas
  class QuotaVerifier
    include Sidekiq::Worker
    sidekiq_options queue: :synchronizer, retry: 0, backtrace: true

    include SyncWorkerBase

    self.max_tries = 5
    self.retry_delay = 5.minutes

    def perform(id_list, try = 1)
      retries = []
      have_failures = false

      id_list.each do |ids|
        Quota.with_quota_by(ids) do |q|
          cluster, cmd = QuotaSynchronizer.cluster_cmd_from_quota(q, mode=:get)

          exit_code, stdout = run_on_cluster(cluster, cmd)

          case exit_code
          when 0
            begin
              value = Integer(stdout)
            rescue ArgumentError
              have_failures = true
            else
              q.current_value = value
            end
          when 1
            retries << ids
          else
            have_failures = true
          end
        end

        enqueue_retry(retries, try + 1) if !retries.empty?
      end
    end
  end
end
