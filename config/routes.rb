Dradis::Plugins::UserIssueStats::Engine.routes.draw do
  # Main dashboard route
  root to: 'user_issue_stats#index'
  
  # Dashboard with optional date filtering
  get 'dashboard', to: 'user_issue_stats#index'
  
  # API endpoints for dynamic updates (optional)
  get 'api/stats', to: 'user_issue_stats#api_stats'
  get 'api/user/:user_id/stats', to: 'user_issue_stats#user_stats'
  get 'api/project/:project_id/stats', to: 'user_issue_stats#project_stats'
end
