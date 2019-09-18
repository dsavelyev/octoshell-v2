module Quotas
  module SyncWorkerBase
    def self.included(base)
      base.class_eval do
        class_attribute :max_tries, :retry_delay
      end
    end

    private

    def enqueue_retry(args, try)
      raise "retries exhausted (#{try})" if try >= max_tries

      return if self.class.perform_in(retry_delay, *args, try + 1)

      raise "could not requeue job for try #{try + 1}"
    end

    module_function

    def run_on_cluster(cluster, cmd)
      exit_code = nil
      stdout = ""

      Net::SSH.start(
        cluster.host,
        cluster.admin_login,
        key_data: [cluster.private_key],
        non_interactive: true
      ) do |ssh|
        ssh.open_channel do |chan|
          chan.exec(cmd) do
            chan.on_request 'exit-status' do |_ch, data|
              exit_code = data.read_long
            end

            chan.on_data do |_ch, data|
              stdout << data
            end
          end
        end

        ssh.loop
      end

      {:exit_code => exit_code, :stdout => stdout}
    end
  end
end
