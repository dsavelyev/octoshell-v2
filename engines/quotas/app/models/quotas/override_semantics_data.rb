module Quotas
  class OverrideSemanticsData < ActiveRecord::Base
    serialize :priority

    has_one :cluster_quota_kind, as: :semantics_data

    after_initialize do
      priority ||= self.class.default_priority
    end

    validates :priority, :state, presence: true
    validate do |sem|
      prio_set = sem.priority.to_set

      if prio_set != self.class.valid_scopes
        errors[:priority] << 'does not match the set of valid scopes'
      elsif prio_set.length != sem.priority.length
        errors[:priority] << 'has duplicate values'
      end
    end

    class <<self
      def valid_scopes
        Set.new(default_priority)
      end

      def default_priority
        %i[member project global]
      end
    end
  end
end
