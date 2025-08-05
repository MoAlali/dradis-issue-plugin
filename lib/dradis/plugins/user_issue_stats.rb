require 'dradis/plugins/user_issue_stats/engine'
require 'dradis/plugins/user_issue_stats/version'
require 'dradis/plugins/user_issue_stats/configuration'

module Dradis
  module Plugins
    module UserIssueStats
      # Plugin registration and initialization
      def self.meta
        package = Dradis::Plugins::UserIssueStats
        {
          :name => package::Engine::plugin_name,
          :description => 'User Issue Statistics Dashboard for Dradis Framework',
          :version => package.version
        }
      end
    end
  end
end
