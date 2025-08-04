module Dradis
  module Plugins
    module UserIssueStats
      class Engine < ::Rails::Engine
        isolate_namespace Dradis::Plugins::UserIssueStats

        initializer 'user_issue_stats.append_migrations' do |app|
          unless app.root.to_s.match(root.to_s)
            config.paths['db/migrate'].expanded.each do |expanded_path|
              app.config.paths['db/migrate'] << expanded_path
            end
          end
        end
      end
    end
  end
end
