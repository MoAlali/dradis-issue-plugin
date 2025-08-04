module Dradis
  module Plugins
    module UserIssueStats
      class UserIssueStatsController < ApplicationController
        def index
          # Get all projects for comprehensive user stats
          @all_projects = Project.all
          
          # Fetch ALL issues across ALL projects (not just current project)
          @issues = Issue.all
          
          # Apply date range filter if provided
          if params[:from].present? && params[:to].present?
            from_date = Date.parse(params[:from])
            to_date = Date.parse(params[:to])
            @issues = @issues.where(created_at: from_date.beginning_of_day..to_date.end_of_day)
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
        end
        
        private
        
        def count_issues_by_severity(issues, severity)
          issues.select { |issue| issue_has_severity?(issue, severity) }.count
        end
        
        def issue_has_severity?(issue, severity)
          # Check in issue text content for severity markers
          text_content = issue.text.to_s.downcase
          severity_patterns = {
            'critical' => /critical|severity:\s*critical|priority:\s*critical/i,
            'high' => /high|severity:\s*high|priority:\s*high/i,
            'medium' => /medium|severity:\s*medium|priority:\s*medium/i,
            'low' => /low|severity:\s*low|priority:\s*low/i,
            'info' => /info|informational|severity:\s*info/i
          }
          
          pattern = severity_patterns[severity.downcase]
          pattern && text_content.match?(pattern)
        end
        
        def extract_status_from_issue(issue)
          # Look for status markers in issue text
          text_content = issue.text.to_s
          
          # Common status patterns
          status_match = text_content.match(/status:\s*([^\n\r]+)/i) ||
                        text_content.match(/state:\s*([^\n\r]+)/i) ||
                        text_content.match(/#\[Status\]\s*([^\n\r]+)/i)
          
          status_match ? status_match[1].strip : nil
        end
        
        def get_issue_author(issue)
          # Try to get the author from the issue's author field
          if issue.respond_to?(:author) && issue.author.present?
            return issue.author
          end
          
          # Try to get from created_by or user association
          if issue.respond_to?(:created_by) && issue.created_by.present?
            return issue.created_by
          end
          
          # Try to extract from issue text content
          text_content = issue.text.to_s
          
          # Look for author patterns in text
          author_match = text_content.match(/author:\s*([^\n\r]+)/i) ||
                        text_content.match(/created.?by:\s*([^\n\r]+)/i) ||
                        text_content.match(/reporter:\s*([^\n\r]+)/i) ||
                        text_content.match(/#\[Author\]\s*([^\n\r]+)/i)
          
          if author_match
            return author_match[1].strip
          end
          
          # Fallback: try to get from associated note or evidence
          if issue.respond_to?(:notes) && issue.notes.any?
            first_note = issue.notes.first
            if first_note.respond_to?(:author)
              return first_note.author
            end
          end
          
          # Final fallback
          'Unknown User'
        end
        
        def get_issue_project_name(issue)
          # Try to get project from issue's node association
          if issue.respond_to?(:node) && issue.node && issue.node.respond_to?(:project)
            return issue.node.project.name if issue.node.project
          end
          
          # Try direct project association
          if issue.respond_to?(:project) && issue.project
            return issue.project.name
          end
          
          # Try to extract from issue text content
          text_content = issue.text.to_s
          project_match = text_content.match(/project:\s*([^\n\r]+)/i) ||
                         text_content.match(/#\[Project\]\s*([^\n\r]+)/i)
          
          if project_match
            return project_match[1].strip
          end
          
          # Fallback
          'Unknown Project'
        end
      end
    end
  end
end
