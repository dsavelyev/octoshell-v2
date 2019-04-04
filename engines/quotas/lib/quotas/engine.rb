require_relative '../../config/initializers/inflections'

module Quotas
  class Engine < ::Rails::Engine
    isolate_namespace Quotas

    config.to_prepare do
      Decorators.register! Engine.root, Rails.root
    end
  end
end
