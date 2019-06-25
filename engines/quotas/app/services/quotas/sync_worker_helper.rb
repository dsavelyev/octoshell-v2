module Quotas
  module SyncWorkerHelper
    included do
      class_attribute :max_tries, :retry_delay
    end

    private

    def enqueue_retry(params, try)
      raise "retries exhausted (#{try})" if try >= max_tries

      params = params.merge('try' => try + 1)
      return if self.class.perform_in(retry_delay, params)

      raise "could not requeue job for try #{try + 1}"
    end

    module_function

    def run_on_cluster(cluster, cmd)
      exit_code = nil

      Net::SSH.start(
        cluster.host,
        cluster.admin_login,
        key_data: [cluster.private_key]
      ) do |ssh|
        ssh.open_channel do |chan|
          chan.exec(cmd) do
            chan.on_request 'exit-status' do |_ch, data|
              exit_code = data.read_long
            end
          end
        end

        ssh.loop
      end

      exit_code
    end
  end
end
