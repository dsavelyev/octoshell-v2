module Quotas
  class OverrideSemantics
    include Semantics

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def self.data_from_hash(h)
      OverrideSemanticsData.new(h)
    end

    def synchronize!
      return false if @data.syncing

      @data.syncing = true
      @data.save!

      #OverrideSemanticsSynchronizer.perform_async(id: @data.id)
    end
  end
end
