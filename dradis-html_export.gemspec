# -*- encoding: utf-8 -*-

require File.expand_path('../lib/dradis/plugins/user_issue_stats/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name        = "dradis-user_issue_stats"
  spec.version     = Dradis::Plugins::UserIssueStats::VERSION
  spec.summary     = "Dradis plugin: User Issue Stats Dashboard"
  spec.files       = Dir["lib/**/*", "config/**/*"]
  spec.require_paths = ["lib"]
  spec.authors     = ['Daniel Martin']
  spec.license     = 'GPL-2'
end
