module Dradis
  module Plugins
    module UserIssueStats
      class Engine < ::Rails::Engine
        isolate_namespace Dradis::Plugins::UserIssueStats

        include ::Dradis::Plugins::Base
        description 'User Issue Statistics Dashboard'

        provides :addon
      end
    end
  end
end
