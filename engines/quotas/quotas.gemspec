$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "quotas/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "quotas"
  s.version     = Quotas::VERSION
  s.authors     = ["Dmitry Savelyev"]
  s.email       = ["ds2012.65@gmail.com"]
  s.homepage    = "https://github.com/octoshell/octoshell-v2"
  s.summary     = "Quota management engine for Octoshell"
  s.description = "Quota management engine for Octoshell"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.11"

  s.test_files = Dir["spec/**/*"]
  s.add_development_dependency "rspec-rails"
end
