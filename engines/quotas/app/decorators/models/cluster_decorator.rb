Core::Cluster.class_eval do
  has_many :cluster_quota_kinds, class_name: "Quotas::ClusterQuotaKind", inverse_of: :cluster, dependent: :destroy
  has_many :quotas, class_name: "Quotas::Quota", as: :domain, dependent: :destroy
end
