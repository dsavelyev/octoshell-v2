module Quotas
  class OverrideSemantics
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def self.data_from_hash(h)
      OverrideSemanticsData.new(h)
    end

    def synchronize!
      data.syncing = true
      data.save!

      OverrideSemanticsSynchronizer.perform_async(data.id)
    end
  end
end
