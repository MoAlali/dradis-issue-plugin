module Dradis
  module UserIssueStats
    class UserIssueStatsController < ApplicationController
        # Add security checks
        before_action :authenticate_user!
        before_action :check_read_permissions
        
        def index
          begin
            # SAFE: Only get projects user has access to
            @accessible_projects = get_user_accessible_projects
            
            # SAFE: Only fetch issues from accessible projects, not ALL issues
            @issues = get_accessible_issues
            
            # Apply date range filter if provided (with validation)
            if params[:from].present? && params[:to].present?
              begin
                from_date = Date.parse(params[:from])
                to_date = Date.parse(params[:to])
                
                # Validate date range
                if from_date > to_date
                  flash[:error] = "From date cannot be after To date"
                  redirect_to request.path and return
                end
                
                # Limit date range to prevent excessive queries
                if (to_date - from_date).to_i > 365
                  flash[:warning] = "Date range limited to 1 year maximum"
                  to_date = from_date + 365.days
                end
                
                @issues = @issues.where(created_at: from_date.beginning_of_day..to_date.end_of_day)
              rescue ArgumentError
                flash[:error] = "Invalid date format"
                redirect_to request.path and return
              end
            end
          
          # Overall counts
          @high_count = count_issues_by_severity(@issues, 'High')
          @critical_count = count_issues_by_severity(@issues, 'Critical')
          @medium_count = count_issues_by_severity(@issues, 'Medium')
          @low_count = count_issues_by_severity(@issues, 'Low')
          @info_count = count_issues_by_severity(@issues, 'Info')
          
          @total = @issues.count
          
          # Group issues by user with their severity counts across ALL projects
          @user_stats = {}
          @user_project_details = {}
          
          @issues.each do |issue|
            user = get_issue_author(issue) || 'Unknown User'
            project_name = get_issue_project_name(issue)
            
            # Initialize user stats if not exists
            @user_stats[user] ||= {
              total: 0,
              critical: 0,
              high: 0,
              medium: 0,
              low: 0,
              info: 0,
              projects: Set.new
            }
            
            # Track which projects this user has worked on
            @user_stats[user][:projects].add(project_name) if project_name
            
            # Initialize project details for this user
            @user_project_details[user] ||= {}
            @user_project_details[user][project_name] ||= {
              total: 0,
              critical: 0,
              high: 0,
              medium: 0,
              low: 0,
              info: 0
            }
            
            # Increment total counts (user overall)
            @user_stats[user][:total] += 1
            
            # Increment project-specific counts
            @user_project_details[user][project_name][:total] += 1
            
            # Increment severity-specific counts (both overall and project-specific)
            if issue_has_severity?(issue, 'Critical')
              @user_stats[user][:critical] += 1
              @user_project_details[user][project_name][:critical] += 1
            elsif issue_has_severity?(issue, 'High')
              @user_stats[user][:high] += 1
              @user_project_details[user][project_name][:high] += 1
            elsif issue_has_severity?(issue, 'Medium')
              @user_stats[user][:medium] += 1
              @user_project_details[user][project_name][:medium] += 1
            elsif issue_has_severity?(issue, 'Low')
              @user_stats[user][:low] += 1
              @user_project_details[user][project_name][:low] += 1
            elsif issue_has_severity?(issue, 'Info')
              @user_stats[user][:info] += 1
              @user_project_details[user][project_name][:info] += 1
            end
          end
          
          # Convert project sets to arrays and sort users by total issue count
          @user_stats.each { |user, stats| stats[:projects] = stats[:projects].to_a.sort }
          @user_stats = @user_stats.sort_by { |user, stats| -stats[:total] }.to_h
          
          # Group issues by status if available
          @status_counts = {}
          @issues.each do |issue|
            status = extract_status_from_issue(issue) || 'Unknown'
            @status_counts[status] = (@status_counts[status] || 0) + 1
          end
        rescue => e
          # Log error but don't expose details to user
          Rails.logger.error "UserIssueStats Error: #{e.message}"
          flash[:error] = "Unable to load statistics. Please try again."
          redirect_to root_path
        end
        
        private
        
        # Security: Check if user has permission to view statistics
        def check_read_permissions
          unless current_user&.can?(:read, :statistics) || current_user&.admin?
            flash[:error] = "Access denied: Insufficient permissions"
            redirect_to root_path
          end
        end
        
        # Security: Only get projects user has access to
        def get_user_accessible_projects
          if current_user&.admin?
            Project.all
          else
            # Only projects user is a member of or has access to
            current_user.projects rescue []
          end
        end
        
        # Security: Only get issues from accessible projects
        def get_accessible_issues
          accessible_project_ids = @accessible_projects.map(&:id)
          
          if accessible_project_ids.any?
            # Use joins to be more efficient and secure
            Issue.joins(:node).where(nodes: { project_id: accessible_project_ids })
          else
            Issue.none # Return empty relation if no access
          end
        end
        
        def count_issues_by_severity(issues, severity)
          # Limit processing to prevent performance issues
          limited_issues = issues.limit(10000) # Prevent excessive processing
          limited_issues.select { |issue| issue_has_severity?(issue, severity) }.count
        end
        
        def issue_has_severity?(issue, severity)
          return false unless issue&.text.present?
          
          # Safely check text content with size limit
          text_content = issue.text.to_s.truncate(5000).downcase # Limit text size
          
          severity_patterns = {
            'critical' => /critical|severity:\s*critical|priority:\s*critical/i,
            'high' => /high|severity:\s*high|priority:\s*high/i,
            'medium' => /medium|severity:\s*medium|priority:\s*medium/i,
            'low' => /low|severity:\s*low|priority:\s*low/i,
            'info' => /info|informational|severity:\s*info/i
          }
          
          pattern = severity_patterns[severity.downcase]
          pattern && text_content.match?(pattern)
        rescue => e
          Rails.logger.warn "Error parsing issue severity: #{e.message}"
          false
        end
        
        def extract_status_from_issue(issue)
          return 'Unknown' unless issue&.text.present?
          
          # Safely extract status with size limit
          text_content = issue.text.to_s.truncate(1000)
          
          # Common status patterns
          status_match = text_content.match(/status:\s*([^\n\r]+)/i) ||
                        text_content.match(/state:\s*([^\n\r]+)/i) ||
                        text_content.match(/#\[Status\]\s*([^\n\r]+)/i)
          
          if status_match
            # Sanitize the status value
            status_match[1].strip.gsub(/[^\w\s-]/, '').truncate(50)
          else
            'Unknown'
          end
        rescue => e
          Rails.logger.warn "Error extracting issue status: #{e.message}"
          'Unknown'
        end
        
        def get_issue_author(issue)
          return 'Unknown User' unless issue.present?
          
          # Try to get the author from the issue's author field
          if issue.respond_to?(:author) && issue.author.present?
            return sanitize_user_name(issue.author)
          end
          
          # Try to get from created_by or user association
          if issue.respond_to?(:created_by) && issue.created_by.present?
            return sanitize_user_name(issue.created_by)
          end
          
          # Try to extract from issue text content (limited)
          if issue.text.present?
            text_content = issue.text.to_s.truncate(1000)
            
            # Look for author patterns in text
            author_match = text_content.match(/author:\s*([^\n\r]+)/i) ||
                          text_content.match(/created.?by:\s*([^\n\r]+)/i) ||
                          text_content.match(/reporter:\s*([^\n\r]+)/i) ||
                          text_content.match(/#\[Author\]\s*([^\n\r]+)/i)
            
            if author_match
              return sanitize_user_name(author_match[1].strip)
            end
          end
          
          # Fallback: try to get from associated note or evidence (safely)
          if issue.respond_to?(:notes) && issue.notes.any?
            first_note = issue.notes.first
            if first_note.respond_to?(:author) && first_note.author.present?
              return sanitize_user_name(first_note.author)
            end
          end
          
          # Final fallback
          'Unknown User'
        rescue => e
          Rails.logger.warn "Error getting issue author: #{e.message}"
          'Unknown User'
        end
        
        def get_issue_project_name(issue)
          return 'Unknown Project' unless issue.present?
          
          # Try to get project from issue's node association
          if issue.respond_to?(:node) && issue.node && issue.node.respond_to?(:project)
            project = issue.node.project
            return sanitize_project_name(project.name) if project
          end
          
          # Try direct project association
          if issue.respond_to?(:project) && issue.project
            return sanitize_project_name(issue.project.name)
          end
          
          # Fallback
          'Unknown Project'
        rescue => e
          Rails.logger.warn "Error getting project name: #{e.message}"
          'Unknown Project'
        end
        
        # Security: Sanitize user names to prevent XSS
        def sanitize_user_name(name)
          return 'Unknown User' unless name.present?
          ActionController::Base.helpers.sanitize(name.to_s.truncate(100))
        end
        
        # Security: Sanitize project names to prevent XSS
        def sanitize_project_name(name)
          return 'Unknown Project' unless name.present?
          ActionController::Base.helpers.sanitize(name.to_s.truncate(100))
        end
      end
    end
  end
