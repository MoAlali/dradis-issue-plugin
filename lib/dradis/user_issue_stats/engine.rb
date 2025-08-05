module Dradis
  module UserIssueStats
    class Engine < ::Rails::Engine
      isolate_namespace Dradis::UserIssueStats

      Dradis::Plugins::register(
        name: 'User Issue Stats',
        author: 'Daniel Martin',
        description: 'User Issue Statistics Dashboard for comprehensive issue tracking and analysis across projects.',
        version: '1.0.0'
      )

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
