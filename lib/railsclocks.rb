require "railsclocks/version"
require "railsclocks/engine"
require "railsclocks/configuration"
require "railsclocks/middleware"
require "railsclocks/api"
require "request_store"

module RailsClocks
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def enabled?
      configuration.enabled
    end

    def record_request(request_data)
      return unless enabled?
      RecordedRequest.create!(request_data)
    end

    def search(params = {})
      API.search(params)
    end

    def analyze_performance(period: 24.hours, group_by: :path)
      API.analyze_performance(period: period, group_by: group_by)
    end

    def replay_request(uuid)
      API.replay_request(uuid)
    end

    def export_data(format: :json, **params)
      API.export_data(format: format, **params)
    end
  end
end 