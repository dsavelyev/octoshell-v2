module Quotas
  class CumulativeSemantics
    include Semantics

    def initialize(_data)
    end

    def self.data_from_hash(_h)
      nil
    end

    def data
      nil
    end
  end
end
