module Dradis
  module Plugins
    module UserIssueStats
      class UserIssueStatsController < ApplicationController
        def index
          # Example logic: fetch issues based on params[:date_range]
          @issues = Dradis::Plugins::Issues::Entry.all
          @high_count = @issues.where(severity: 'High').count
          @critical_count = @issues.where(severity: 'Critical').count
          @total = @issues.count
        end
      end
    end
  end
end
