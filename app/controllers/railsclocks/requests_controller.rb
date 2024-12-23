module RailsClocks
  class RequestsController < ApplicationController
    def index
      @requests = API.search(search_params)
      @total_count = @requests.total_count
      @error_count = @requests.where("status_code >= ?", 400).count
    end

    def show
      @request = RecordedRequest.find_by!(uuid: params[:id])
      @sql_queries = @request.active_record_events
      @related_requests = find_related_requests
    end

    def replay
      @request = RecordedRequest.find_by!(uuid: params[:id])
      result = @request.replay

      respond_to do |format|
        format.html { 
          flash[:notice] = result[:success] ? "Request replayed successfully" : "Replay failed: #{result[:error]}"
          redirect_to request_path(@request)
        }
        format.json { render json: result }
      end
    end

    def performance
      @stats = API.analyze_performance(
        period: params.fetch(:period, 24.hours),
        group_by: params.fetch(:group_by, :path)
      )
    end

    private

    def search_params
      params.permit(:method, :path, :from, :to, :min_duration, :max_duration, 
                   :with_errors, :page, :per_page)
    end

    def find_related_requests
      RecordedRequest
        .where(path: @request.path)
        .where.not(uuid: @request.uuid)
        .recent
        .limit(5)
    end
  end
end 