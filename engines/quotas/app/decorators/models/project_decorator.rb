Core::Project.class_eval do
  has_many :quotas, as: :subject, class_name: Quotas::Quota
end
