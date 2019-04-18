module Quotas
  class OverrideSemanticsData < ActiveRecord::Base
    DEFAULT_PRIORITY = %i[member project global].freeze
    VALID_SCOPES = Set.new(DEFAULT_PRIORITY).freeze

    serialize :priority

    has_one :cluster_quota_kind, as: :semantics_data

    after_initialize do
      priority ||= DEFAULT_PRIORITY
    end

    validates :priority, :state, presence: true
    validate do |sem|
      prio_set = sem.priority.to_set

      if prio_set != VALID_SCOPES
        errors[:priority] << 'does not match the set of valid scopes'
      elsif prio_set.length != sem.priority.length
        errors[:priority] << 'has duplicate values'
      end
    end
  end
end
