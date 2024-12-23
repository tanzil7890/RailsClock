RailsClocks.configure do |config|
  # Enable/disable request recording
  config.enabled = true

  # Record only a percentage of requests (1.0 = 100%, 0.1 = 10%)
  config.sample_rate = 1.0

  # Paths to exclude from recording
  config.excluded_paths = [
    /assets/,
    /packs/,
    /cable/,
    /healthcheck/
  ]

  # Maximum size of request data to store (in bytes)
  config.max_request_size_bytes = 1.megabyte
end 