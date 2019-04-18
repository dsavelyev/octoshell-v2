module Quotas
  class QuotaKind < ActiveRecord::Base
    translates :name, :unit, :comment
    validates_translated :name, :unit, :comment, presence: true

    has_many :cluster_quota_kinds, inverse_of: :quota_kind
  end
end
