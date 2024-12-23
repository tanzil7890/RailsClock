module RailsClocks
  module API
    class RequestsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :ensure_json_request

      def index
        @requests = RecordedRequest.search(search_params)
        render json: {
          requests: @requests.map(&:api_attributes),
          meta: {
            total_count: @requests.total_count,
            error_count: @requests.where("status_code >= ?", 400).count
          }
        }
      end

      def show
        @request = RecordedRequest.find_by!(uuid: params[:id])
        render json: {
          request: @request.api_attributes,
          sql_queries: @request.active_record_events,
          related_requests: find_related_requests.map(&:api_attributes)
        }
      end

      def replay
        @request = RecordedRequest.find_by!(uuid: params[:id])
        result = @request.replay

        render json: {
          success: result[:success],
          message: result[:success] ? "Request replayed successfully" : result[:error],
          data: result[:data]
        }
      end

      def performance
        stats = API.analyze_performance(
          period: params.fetch(:period, 24.hours),
          group_by: params.fetch(:group_by, :path)
        )

        render json: {
          performance_data: stats,
          meta: {
            period: params[:period],
            group_by: params[:group_by]
          }
        }
      end

      private

      def search_params
        params.permit(
          :method, :path, :from, :to, 
          :min_duration, :max_duration,
          :with_errors, :page, :per_page,
          status: []
        )
      end

      def find_related_requests
        RecordedRequest
          .where(path: @request.path)
          .where.not(uuid: @request.uuid)
          .recent
          .limit(5)
      end

      def ensure_json_request
        return if request.format.json?
        render json: { error: 'Only JSON requests are allowed' }, status: :not_acceptable
      end
    end
  end
end