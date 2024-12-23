require 'securerandom'

module RailsClocks
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      return @app.call(env) unless should_record?(env)

      request = ActionDispatch::Request.new(env)
      request_id = SecureRandom.uuid
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      RequestStore.store[:railsclocks_events] = []
      RequestStore.store[:railsclocks_batch] ||= []
      
      subscribe_to_events(request_id)
      
      status, headers, response = @app.call(env)
      
      duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
      record_request(request, request_id, duration)
      
      [status, headers, response]
    rescue => e
      Rails.logger.error("RailsClocks Middleware Error: #{e.message}")
      raise
    ensure
      cleanup_subscriptions
    end

    private

    def should_record?(env)
      return false unless RailsClocks.enabled?
      
      request = Rack::Request.new(env)
      
      # Check if path is excluded
      return false if RailsClocks.configuration.excluded_paths.any? { |pattern| 
        pattern.match?(request.path) 
      }
      
      # Apply sampling
      rand <= RailsClocks.configuration.sample_rate
    end

    def subscribe_to_events(request_id)
      @subscribers = []
      
      @subscribers << ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        
        RequestStore.store[:railsclocks_events] << {
          name: 'sql.active_record',
          duration: event.duration,
          sql: event.payload[:sql],
          binds: event.payload[:binds]&.map { |attr| attr.value_before_type_cast },
          timestamp: event.time
        }
      end
    end

    def record_request(request, request_id, duration)
      request_data = {
        uuid: request_id,
        request_method: request.method,
        path: request.path,
        query_string: request.query_string,
        headers: filtered_headers(request.headers),
        params: filtered_params(request.params),
        session_data: filtered_session(request.session),
        cookies: filtered_cookies(request.cookies),
        active_record_events: RequestStore.store[:railsclocks_events],
        recorded_at: Time.current,
        duration: duration
      }

      RequestStore.store[:railsclocks_batch] << request_data

      # Flush batch if it reaches threshold
      if RequestStore.store[:railsclocks_batch].size >= RailsClocks.configuration.batch_size
        RailsClocks.record_requests(RequestStore.store[:railsclocks_batch])
        RequestStore.store[:railsclocks_batch] = []
      end
    end

    def cleanup_subscriptions
      @subscribers&.each do |subscriber|
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end
      RequestStore.store[:railsclocks_events] = nil
    end

    def filtered_headers(headers)
      headers.to_h.select { |k, _| k.start_with?('HTTP_') }
    end

    def filtered_params(params)
      params.to_h.except(*Rails.application.config.filter_parameters)
    end

    def filtered_session(session)
      session.to_h.except('session_id', '_csrf_token')
    end

    def filtered_cookies(cookies)
      cookies.to_h
    end
  end
end 