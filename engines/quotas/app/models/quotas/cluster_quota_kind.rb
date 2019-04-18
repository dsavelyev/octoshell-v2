module Quotas
  class ClusterQuotaKind < ActiveRecord::Base
    belongs_to :cluster, class_name: "Core::Cluster", inverse_of: :cluster_quota_kinds
    belongs_to :quota_kind, inverse_of: :cluster_quota_kinds

    # nb: the other side must be has_one
    belongs_to :semantics_data, polymorphic: true, dependent: :destroy

    has_many :quotas, foreign_key: :kind_id, inverse_of: :kind

    translates :comment

    validates :cluster, :quota_kind, presence: true
    validates_uniqueness_of :quota_kind, scope: :cluster

    validates_translated :comment, presence: true
    validates_inclusion_of :applies_to_partitions, in: [false, true]

    # semantics_data.class works too, but incurs a select
    def semantics_data_class
      semantics_data_type&.constantize || NilClass
    end

    def semantics
      semantics_type.constantize.new(semantics_data)
    end

    def quotas_where_semantics(h)
      quotas.merge(semantics.quotas_where(h))
    end
  end
end
