module Quotas
  module SyncUtil
    def self.run_on_cluster(cluster, cmd)
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
