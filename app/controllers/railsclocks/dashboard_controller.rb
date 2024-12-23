module RailsClocks
  class DashboardController < ApplicationController
    def index
      @recent_requests = RecordedRequest.recent.limit(10)
      @request_count = RecordedRequest.count
      @performance_stats = API.analyze_performance(period: 24.hours)
      @error_rate = calculate_error_rate
      @avg_response_time = calculate_avg_response_time
    end

    private

    def calculate_error_rate
      total = RecordedRequest.where("recorded_at >= ?", 24.hours.ago).count
      errors = RecordedRequest.where("recorded_at >= ? AND status_code >= ?", 24.hours.ago, 400).count
      total.zero? ? 0 : (errors.to_f / total * 100).round(2)
    end

    def calculate_avg_response_time
      RecordedRequest.where("recorded_at >= ?", 24.hours.ago).average(:duration)&.round(2) || 0
    end
  end
end 