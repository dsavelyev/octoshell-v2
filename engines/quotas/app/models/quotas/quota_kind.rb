module Quotas
  class QuotaKind < ActiveRecord::Base
    translates :name, :unit, :comment
    validates_translated :name, :unit, :comment, presence: true
    validates :name_en, uniqueness: true, unless: proc { |k| k.name_en.nil? }
    validates :name_ru, uniqueness: true, unless: proc { |k| k.name_ru.nil? }

    has_many :cluster_quota_kinds, inverse_of: :quota_kind
  end
end
