module Quotas
  class OverrideSemanticsData < ActiveRecord::Base
    DEFAULT_PRIORITY = %i[member project global].freeze
    VALID_SCOPES = Set.new(DEFAULT_PRIORITY).freeze

    serialize :current_priority
    serialize :desired_priority

    after_initialize if: :new_record? do
      self.current_priority ||= DEFAULT_PRIORITY
      self.desired_priority ||= DEFAULT_PRIORITY
    end

    has_one :cluster_quota_kind, as: :semantics_data

    validates :current_priority, :desired_priority, :state, presence: true

    validate do |sem|
      prio_set = sem.current_priority.to_set

      if prio_set != VALID_SCOPES
        errors[:current_priority] << t('quotas.override_semantics.priority_set_mismatch')
      elsif prio_set.length != sem.current_priority.length
        errors[:current_priority] << t('quotas.override_semantics.priority_duplicates')
      end
    end
  end
end
