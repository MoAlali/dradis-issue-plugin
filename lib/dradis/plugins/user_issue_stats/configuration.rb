module Dradis
  module Plugins
    module UserIssueStats
      # Configuration for security and performance
      class Configuration
        # Security settings
        REQUIRE_AUTHENTICATION = true
        REQUIRE_ADMIN_ROLE = false # Set to true for admin-only access
        MAX_ISSUES_TO_PROCESS = 10000 # Prevent memory issues
        MAX_DATE_RANGE_DAYS = 365 # Limit date range
        
        # Performance settings
        ENABLE_CACHING = true
        CACHE_DURATION = 5.minutes
        
        # Data safety settings
        MAX_TEXT_LENGTH = 5000 # Limit text processing
        SANITIZE_OUTPUT = true
        LOG_SECURITY_EVENTS = true
        
        # Feature toggles (can disable features if needed)
        ENABLE_CROSS_PROJECT_VIEW = true
        ENABLE_USER_DETAILS = true
        ENABLE_PROJECT_BREAKDOWN = true
        
        class << self
          def safe_mode?
            Rails.env.production?
          end
          
          def max_issues
            safe_mode? ? 5000 : MAX_ISSUES_TO_PROCESS
          end
          
          def cache_enabled?
            ENABLE_CACHING && Rails.cache.present?
          end
        end
      end
    end
  end
end
