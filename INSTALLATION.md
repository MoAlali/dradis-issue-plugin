# INSTALLATION GUIDE

## Plugin Installation for Production Dradis

### 1. **Plugin Structure** ✅
Your plugin now has the complete structure:
```
dradis-issue-plugin/
├── init.rb                           # ← REQUIRED: Plugin registration
├── lib/
│   ├── dradis-user_issue_stats.rb   # Main plugin loader
│   └── dradis/plugins/user_issue_stats/
│       ├── engine.rb                 # Rails engine
│       ├── version.rb               # Version management
│       ├── configuration.rb         # Security settings
│       ├── controllers/
│       │   └── user_issue_stats_controller.rb
│       └── views/
│           └── user_issue_stats/
│               └── index.html.erb
├── config/
│   └── routes.rb                    # URL routing
└── SECURITY_GUIDE.md               # Security documentation
```

### 2. **Installation Methods**

#### **Method A: Gem Installation (Recommended)**
```bash
# 1. Build the gem
gem build dradis-user_issue_stats.gemspec

# 2. Install the gem
gem install dradis-user_issue_stats-1.0.0.gem

# 3. Add to Dradis Gemfile
echo 'gem "dradis-user_issue_stats"' >> /path/to/dradis/Gemfile

# 4. Bundle install
cd /path/to/dradis
bundle install

# 5. Restart Dradis
bundle exec rails restart
```

#### **Method B: Local Development**
```bash
# 1. Add to Dradis Gemfile with local path
echo 'gem "dradis-user_issue_stats", path: "/path/to/dradis-issue-plugin"' >> /path/to/dradis/Gemfile

# 2. Bundle install
cd /path/to/dradis
bundle install

# 3. Restart Dradis
bundle exec rails restart
```

#### **Method C: Plugin Directory (If Dradis supports it)**
```bash
# 1. Copy plugin to Dradis plugins directory
cp -r /path/to/dradis-issue-plugin /path/to/dradis/plugins/

# 2. Ensure init.rb is present
ls /path/to/dradis/plugins/dradis-issue-plugin/init.rb

# 3. Restart Dradis
cd /path/to/dradis
bundle exec rails restart
```

### 3. **Verification Steps**

#### **Check Plugin is Loaded:**
```bash
# In Dradis console
bundle exec rails console
> Dradis::Plugins.registered
# Should include 'user_issue_stats'
```

#### **Check Routes:**
```bash
# Check available routes
bundle exec rails routes | grep user_issue_stats
# Should show: GET /stats user_issue_stats#index
```

#### **Access Dashboard:**
```
Navigate to: https://your-dradis-instance/stats
```

### 4. **Configuration**

#### **Security Configuration:**
Edit `lib/dradis/plugins/user_issue_stats/configuration.rb`:

```ruby
# For production environments:
REQUIRE_AUTHENTICATION = true
REQUIRE_ADMIN_ROLE = true          # Admin-only access
MAX_ISSUES_TO_PROCESS = 5000       # Lower limit for performance
ENABLE_CACHING = true              # Enable caching
```

#### **URL Configuration:**
Edit `config/routes.rb` if you want different URL:
```ruby
Dradis::Plugins::UserIssueStats::Engine.routes.draw do
  root to: 'user_issue_stats#index'
  # Available at: /stats/ (default)
end
```

### 5. **Post-Installation Testing**

#### **Security Test:**
1. ✅ Login as regular user → Should only see authorized projects
2. ✅ Login as admin → Should see all projects  
3. ✅ Logout → should redirect to login
4. ✅ Test date filtering → Should work without errors

#### **Performance Test:**
1. ✅ Load dashboard → Should load < 3 seconds
2. ✅ Filter large date range → Should be limited to 1 year
3. ✅ Check memory usage → Should remain stable

#### **Error Handling Test:**
1. ✅ Invalid date formats → Should show error message
2. ✅ Database errors → Should fail gracefully
3. ✅ Large datasets → Should not crash

### 6. **Troubleshooting**

#### **Plugin Not Loading:**
```bash
# Check if init.rb exists
ls /path/to/plugin/init.rb

# Check Gemfile includes plugin
grep user_issue_stats /path/to/dradis/Gemfile

# Check bundle includes plugin
bundle list | grep user_issue_stats
```

#### **Route Not Found:**
```bash
# Check engine is mounted in main routes
grep -r "UserIssueStats" /path/to/dradis/config/routes.rb

# Manual mount in main application routes.rb:
mount Dradis::Plugins::UserIssueStats::Engine => '/stats'
```

#### **Permission Errors:**
```bash
# Check user has correct permissions
# In Rails console:
user = User.find(1)
user.admin?  # Should return true for admin access
```

### 7. **Success Indicators** ✅

When properly installed, you should see:
- ✅ `/stats` URL accessible
- ✅ User statistics displayed
- ✅ Date filtering works
- ✅ Security restrictions active
- ✅ No error messages in logs
- ✅ Performance remains good

## **The `init.rb` file is ESSENTIAL** - without it, Dradis won't recognize your plugin!
