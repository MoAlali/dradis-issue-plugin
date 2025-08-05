require 'dradis/plugins/user_issue_stats'

Dradis::Plugins.register(
  'user_issue_stats',
  Dradis::Plugins::UserIssueStats
)
