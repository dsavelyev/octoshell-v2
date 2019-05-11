module Quotas
  class OverrideSemanticsData < ActiveRecord::Base
    DEFAULT_PRIORITY = %i[member project global].freeze
    VALID_SCOPES = Set.new(DEFAULT_PRIORITY).freeze

    serialize :current_priority
    serialize :desired_priority

    has_one :cluster_quota_kind, as: :semantics_data

    before_validation on: :create do
      current_priority ||= DEFAULT_PRIORITY
      desired_priority ||= DEFAULT_PRIORITY
    end

    validates :current_priority, :desired_priority, :state, presence: true

    validate do |sem|
      prio_set = sem.priority.to_set

      if prio_set != VALID_SCOPES
        errors[:priority] << t('quotas.override_semantics.priority_set_mismatch')
      elsif prio_set.length != sem.priority.length
        errors[:priority] << t('quotas.override_semantics.priority_duplicates')
      end
    end
  end
end
