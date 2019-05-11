Core::Project.class_eval do
  has_many :quotas, class_name: "Quotas::Quota", as: :subject, dependent: :destroy
end
