module RailsClocks
  class ReplayService
    def initialize(recorded_request)
      @recorded_request = recorded_request
    end

    def replay
      ActiveRecord::Base.transaction do
        begin
          env = build_rack_env
          status, headers, response = Rails.application.call(env)
          
          {
            status: status,
            headers: headers,
            response: response_body(response),
            success: true
          }
        rescue => e
          Rails.logger.error("Replay Error: #{e.message}")
          {
            error: e.message,
            backtrace: e.backtrace,
            success: false
          }
        ensure
          raise ActiveRecord::Rollback # Don't persist changes from replay
        end
      end
    end

    private

    def build_rack_env
      {
        'REQUEST_METHOD' => @recorded_request.request_method,
        'PATH_INFO' => @recorded_request.path,
        'QUERY_STRING' => @recorded_request.query_string.to_s,
        'rack.input' => StringIO.new,
        'rack.url_scheme' => 'http',
        'SCRIPT_NAME' => '',
        'SERVER_NAME' => 'localhost',
        'SERVER_PORT' => '3000',
        'rack.version' => [1, 3],
        'rack.errors' => StringIO.new,
        'rack.multithread' => true,
        'rack.multiprocess' => false,
        'rack.run_once' => false,
        'rack.hijack?' => false,
        'CONTENT_TYPE' => 'application/json',
        'HTTP_COOKIE' => build_cookie_string,
      }.merge(build_headers)
    end

    def build_headers
      (@recorded_request.headers || {}).transform_keys do |key|
        "HTTP_#{key.upcase.gsub('-', '_')}"
      end
    end

    def build_cookie_string
      (@recorded_request.cookies || {}).map { |k, v| "#{k}=#{v}" }.join('; ')
    end

    def response_body(response)
      response.each.map(&:to_s).join
    end
  end
end 