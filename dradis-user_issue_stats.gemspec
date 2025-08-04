# -*- encoding: utf-8 -*-

require File.expand_path('../lib/dradis/plugins/user_issue_stats/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name        = "dradis-user_issue_stats"
  spec.version     = Dradis::Plugins::UserIssueStats::VERSION
  spec.summary     = "Dradis plugin: User Issue Stats Dashboard"
  spec.description = "A Dradis Framework plugin that provides comprehensive issue statistics and status tracking capabilities"
  spec.files       = Dir["lib/**/*", "config/**/*"]
  spec.require_paths = ["lib"]
  spec.authors     = ['Daniel Martin']
  spec.email       = ['daniel@example.com']
  spec.homepage    = 'https://github.com/your-username/dradis-user_issue_stats'
  spec.license     = 'GPL-2'

  spec.add_dependency 'dradis-plugins', '~> 4.0'
  spec.add_dependency 'rails', '>= 5.0'
  
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'database_cleaner'
end
