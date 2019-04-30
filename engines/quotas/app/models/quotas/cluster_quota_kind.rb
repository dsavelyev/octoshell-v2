module Quotas
  class ClusterQuotaKind < ActiveRecord::Base
    belongs_to :cluster, class_name: "Core::Cluster", inverse_of: :cluster_quota_kinds
    belongs_to :quota_kind, inverse_of: :cluster_quota_kinds

    # nb: the other side must be has_one
    belongs_to :semantics_data, polymorphic: true, dependent: :destroy

    has_many :quotas, foreign_key: :kind_id, inverse_of: :kind

    translates :comment

    validates :cluster, presence: true
    validates :quota_kind, presence: true, uniqueness: { scope: :cluster }
    validates :name_on_cluster, presence: true, uniqueness: { scope: :cluster }
    validates :applies_to_partitions, inclusion: { in: [false, true] }
    validates_translated :comment, presence: true

    def semantics
      semantics_type.constantize.new(semantics_data)
    end

    def quotas_where_semantics(h)
      quotas.merge(semantics.quotas_where(h))
    end
  end
end
