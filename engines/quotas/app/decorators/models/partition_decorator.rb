Core::Partition.class_eval do
  has_many :quotas, class_name: "Quotas::Quota", as: :domain
end
