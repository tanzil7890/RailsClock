module RailsClocks
  class API
    class << self
      def search(params)
        scope = RecordedRequest.recent
        
        scope = apply_filters(scope, params)
        scope = apply_pagination(scope, params)
        
        scope
      end
      
      def analyze_performance(period: 24.hours, group_by: :path)
        scope = RecordedRequest
          .where("recorded_at >= ?", period.ago)
          
        case group_by
        when :path
          scope.group(:path)
        when :method
          scope.group(:request_method)
        when :hour
          scope.group("DATE_TRUNC('hour', recorded_at)")
        end
          .select(build_performance_select(group_by))
          .order("avg_duration DESC")
      end

      def replay_request(uuid)
        request = RecordedRequest.find_by!(uuid: uuid)
        ReplayService.new(request).replay
      end

      def export_data(format: :json, **params)
        requests = search(params)
        
        case format
        when :json
          requests.to_json
        when :csv
          generate_csv(requests)
        else
          raise ArgumentError, "Unsupported format: #{format}"
        end
      end

      private

      def apply_filters(scope, params)
        scope = scope.where(request_method: params[:method]) if params[:method]
        scope = scope.where("path LIKE ?", "%#{params[:path]}%") if params[:path]
        scope = scope.where("recorded_at >= ?", params[:from]) if params[:from]
        scope = scope.where("recorded_at <= ?", params[:to]) if params[:to]
        scope = scope.where("duration >= ?", params[:min_duration]) if params[:min_duration]
        scope = scope.where("duration <= ?", params[:max_duration]) if params[:max_duration]
        
        if params[:with_errors]
          scope = scope.where("status_code >= ?", 400)
        end

        scope
      end

      def apply_pagination(scope, params)
        page = params[:page] || 1
        per_page = params[:per_page] || 25
        
        scope.page(page).per(per_page)
      end

      def build_performance_select(group_by)
        select_clause = []
        
        select_clause << case group_by
        when :path
          "path as group_key"
        when :method
          "request_method as group_key"
        when :hour
          "DATE_TRUNC('hour', recorded_at) as group_key"
        end

        select_clause += [
          "AVG(duration) as avg_duration",
          "COUNT(*) as count",
          "MAX(duration) as max_duration",
          "MIN(duration) as min_duration",
          "PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY duration) as p95_duration"
        ]

        select_clause.join(", ")
      end

      def generate_csv(requests)
        require 'csv'
        
        CSV.generate do |csv|
          csv << ['UUID', 'Method', 'Path', 'Duration', 'Recorded At', 'Status']
          
          requests.each do |request|
            csv << [
              request.uuid,
              request.request_method,
              request.path,
              request.duration,
              request.recorded_at,
              request.status_code
            ]
          end
        end
      end
    end
  end
end 