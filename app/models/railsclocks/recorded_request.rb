module RailsClocks
  class RecordedRequest < ActiveRecord::Base
    include APIAttributes
    
    self.table_name = 'railsclocks_recorded_requests'

    # Validations
    validates :uuid, presence: true, uniqueness: true
    validates :recorded_at, presence: true
    validates :request_method, presence: true
    validates :path, presence: true

    # Scopes
    scope :recent, -> { order(recorded_at: :desc) }
    scope :with_errors, -> { where('status_code >= ?', 400) }
    scope :successful, -> { where('status_code < ?', 400) }
    scope :within_period, ->(period) { where('recorded_at >= ?', period.ago) }

    # Search scope
    scope :search, ->(params = {}) {
      requests = all

      requests = requests.where(request_method: params[:method]) if params[:method].present?
      requests = requests.where('path LIKE ?', "%#{params[:path]}%") if params[:path].present?
      requests = requests.where('recorded_at >= ?', params[:from]) if params[:from].present?
      requests = requests.where('recorded_at <= ?', params[:to]) if params[:to].present?
      requests = requests.where('duration >= ?', params[:min_duration]) if params[:min_duration].present?
      requests = requests.where('duration <= ?', params[:max_duration]) if params[:max_duration].present?
      requests = requests.with_errors if params[:with_errors].present?

      requests.recent
    }

    # Instance methods
    def replay
      ReplayService.new(self).replay
    rescue StandardError => e
      { success: false, error: e.message }
    end

    def duration_in_ms
      duration.to_f.round(2)
    end

    def error?
      status_code.to_i >= 400
    end

    def success?
      !error?
    end

    def filtered_params
      return {} unless params.present?
      
      params.except(
        'controller',
        'action',
        'format',
        *RailsClocks.configuration.filtered_parameters
      )
    end

    def filtered_headers
      return {} unless headers.present?
      
      headers.except(
        'rack.session',
        'rack.session.options',
        *RailsClocks.configuration.filtered_headers
      )
    end

    # Class methods
    class << self
      def record_request(env, response, duration)
        return unless should_record?(env)

        create!(
          uuid: SecureRandom.uuid,
          request_method: env['REQUEST_METHOD'],
          path: env['PATH_INFO'],
          query_string: env['QUERY_STRING'],
          headers: extract_headers(env),
          params: extract_params(env),
          session_data: extract_session(env),
          cookies: extract_cookies(env),
          status_code: response[0],
          duration: duration,
          recorded_at: Time.current,
          active_record_events: extract_sql_events
        )
      rescue StandardError => e
        Rails.logger.error "Failed to record request: #{e.message}"
        nil
      end

      private

      def should_record?(env)
        return false unless RailsClocks.configuration.enabled
        return false if excluded_path?(env['PATH_INFO'])
        
        rand <= RailsClocks.configuration.sample_rate
      end

      def excluded_path?(path)
        RailsClocks.configuration.excluded_paths.any? { |pattern| pattern === path }
      end

      def extract_headers(env)
        env.select { |k, v| k.start_with?('HTTP_') }
           .transform_keys { |k| k.sub('HTTP_', '').downcase }
      end

      def extract_params(env)
        request = ActionDispatch::Request.new(env)
        request.params.to_h
      rescue => e
        Rails.logger.error "Failed to extract params: #{e.message}"
        {}
      end

      def extract_session(env)
        env['rack.session']&.to_h || {}
      end

      def extract_cookies(env)
        request = ActionDispatch::Request.new(env)
        request.cookies
      rescue => e
        Rails.logger.error "Failed to extract cookies: #{e.message}"
        {}
      end

      def extract_sql_events
        ActiveSupport::Notifications.events_for('sql.active_record')
          .map { |event| format_sql_event(event) }
      end

      def format_sql_event(event)
        {
          sql: event.payload[:sql],
          name: event.payload[:name],
          duration: event.duration,
          timestamp: event.time.iso8601
        }
      end
    end
  end
end
