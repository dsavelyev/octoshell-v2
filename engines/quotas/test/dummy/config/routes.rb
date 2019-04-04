Rails.application.routes.draw do

  mount Quotas::Engine => "/quotas"
end
