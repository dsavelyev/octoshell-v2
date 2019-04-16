module Quotas
  class ClusterQuotaKind < ActiveRecord::Base
    belongs_to :cluster, class_name: Core::Cluster
    belongs_to :quota_kind

    # nb the other side must be has_one
    belongs_to :semantics_data, polymorphic: true, dependent: :destroy

    has_many :quotas

    translates :comment

    validates :cluster, :quota_kind, presence: true
    validates_uniqueness_of :quota_kind, scope: :cluster

    validates_translated :comment, presence: true
    validates_inclusion_of :applies_to_partitions, in: [false, true]

    # semantics_data.class works too, but incurs a select
    def semantics_data_class
      semantics_data_type&.constantize || NilClass
    end
  end
end
