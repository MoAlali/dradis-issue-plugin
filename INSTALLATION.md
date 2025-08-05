# INSTALLATION GUIDE

## Plugin Installation for Dradis

### **Plugin Structure** ✅
```
dradis-issue-plugin/
├── lib/
│   ├── dradis-user_issue_stats.rb        # Main plugin loader
│   └── dradis/
│       └── plugins/
│           ├── user_issue_stats.rb       # Plugin registration
│           └── user_issue_stats/
│               ├── engine.rb             # Rails engine with UI routes
│               ├── version.rb            # Version management
│               ├── controllers/
│               │   └── user_issue_stats_controller.rb
│               └── views/
│                   └── user_issue_stats/
│                       └── index.html.erb # Dashboard UI
└── config/
    └── routes.rb                         # URL routing configuration
```

### **Installation**

#### **Method 1: Gem Installation (Recommended)**
```bash
# Build and install the gem
gem build dradis-user_issue_stats.gemspec
gem install dradis-user_issue_stats-1.0.0.gem

# Add to Dradis Gemfile
echo 'gem "dradis-user_issue_stats"' >> /path/to/dradis/Gemfile

# Install and restart
cd /path/to/dradis
bundle install
bundle exec rails restart
```

#### **Method 2: Local Development**
```bash
# Add to Dradis Gemfile with local path
echo 'gem "dradis-user_issue_stats", path: "/path/to/dradis-issue-plugin"' >> /path/to/dradis/Gemfile

# Install and restart
cd /path/to/dradis
bundle install
bundle exec rails restart
```

### **Verification**
```bash
# Check plugin is loaded
bundle exec rails console
> Dradis::Plugins.registered

# Access dashboard
# Navigate to: https://your-dradis-instance/stats
```

### **Available Routes**
- `/stats` - Main dashboard
- `/stats/api/stats` - JSON API for live updates
- `/stats/api/user/:user_id/stats` - User-specific stats
- `/stats/api/project/:project_id/stats` - Project-specific stats
