module RailsClocks
  module APIAttributes
    extend ActiveSupport::Concern

    def api_attributes
      {
        uuid: uuid,
        method: request_method,
        path: path,
        query_string: query_string,
        duration: duration,
        status_code: status_code,
        recorded_at: recorded_at,
        headers: filtered_headers,
        params: filtered_params
      }
    end

    private

    def filtered_headers
      headers.except('rack.session', 'rack.session.options')
    end

    def filtered_params
      params.except('controller', 'action')
    end
  end
end 