module Quotas
  module Retry
    def self.with_retries(tries: :infinite, on:)
      tries = tries == :infinite ? Float::INFINITY : tries

      attempts = 0
      begin
        attempts += 1
        yield
      rescue *on => exc
        raise exc unless attempts < tries

        sleep_seconds = 2 ** (attempts - 1)
        sleep_seconds *= 0.5 * (1 + rand())

        sleep(sleep_seconds)
        retry
      end
    end
  end
end
