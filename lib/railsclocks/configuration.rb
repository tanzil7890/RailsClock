module RailsClocks
  class Configuration
    attr_accessor :enabled,
                  :sample_rate,
                  :excluded_paths,
                  :max_request_size_bytes,
                  :log_level,
                  :storage_strategy,
                  :retention_period,
                  :compression_enabled,
                  :filtered_parameters,
                  :filtered_headers,
                  :authorization_proc

    def initialize
      @enabled = true
      @sample_rate = 1.0 # Record all requests by default
      @excluded_paths = [/assets/, /packs/, /cable/, /healthcheck/]
      @max_request_size_bytes = 1.megabyte
      @log_level = :info
      @storage_strategy = :file # Options: :file, :database
      @retention_period = 30.days
      @compression_enabled = true
      @filtered_parameters = ['password', 'token', 'secret']
      @filtered_headers = ['cookie', 'authorization']
      @authorization_proc = ->(_user) { true } # Allow all by default
    end

    def validate!
      validate_sample_rate
      validate_retention_period
      validate_max_request_size
      validate_storage_strategy
    end

    private

    def validate_sample_rate
      return if (0..1).include?(@sample_rate)
      raise ArgumentError, "sample_rate must be between 0 and 1"
    end

    def validate_retention_period
      return if @retention_period.is_a?(ActiveSupport::Duration)
      raise ArgumentError, "retention_period must be a duration (e.g., 30.days)"
    end

    def validate_max_request_size
      return if @max_request_size_bytes.is_a?(Integer) && @max_request_size_bytes.positive?
      raise ArgumentError, "max_request_size_bytes must be a positive integer"
    end

    def validate_storage_strategy
      return if [:file, :database].include?(@storage_strategy)
      raise ArgumentError, "storage_strategy must be :file or :database"
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
      configuration.validate!
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end 