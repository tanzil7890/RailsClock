module RailsClocks
  module RequestsHelper
    def format_sql_query(query)
      return '-' if query.blank?
      
      content_tag :pre, class: 'sql-query' do
        query['sql']
      end
    end

    def format_path_with_query(request)
      return request.path if request.query_string.blank?
      "#{request.path}?#{request.query_string}"
    end

    def request_summary(request)
      "#{method_badge(request.request_method)} #{format_path_with_query(request)}"
    end

    def format_error_rate(rate)
      return '0%' if rate.zero?
      "#{rate}%"
    end

    def chart_data_for(stats)
      {
        labels: stats.map { |s| s[:timestamp].strftime('%H:%M') },
        values: stats.map { |s| s[:value] }
      }.to_json
    end
  end
end 