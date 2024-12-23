<p align="center">
  <img src="./docs/images/railsclock_logo.png" alt="RailsClock Logo" width="400"/>
</p>

# RailsClocks

[![Gem Version](https://badge.fury.io/rb/railsclocks.svg)](https://badge.fury.io/rb/railsclocks)
[![Build Status](https://github.com/yourusername/railsclocks/workflows/CI/badge.svg)](https://github.com/yourusername/railsclocks/actions)
[![Maintainability](https://api.codeclimate.com/v1/badges/YOUR_BADGE/maintainability)](https://codeclimate.com/github/yourusername/railsclocks)
[![Coverage Status](https://coveralls.io/repos/github/yourusername/railsclocks/badge.svg?branch=main)](https://coveralls.io/github/yourusername/railsclocks?branch=main)

## About

A Rails engine for recording, replaying, and debugging HTTP requests with their database interactions in real-time.

## Key Features

- 🔍 **Request Monitoring**
  - Automatic HTTP request recording
  - Database query tracking
  - Headers and parameters logging
  - Session data capture

- 🎯 **Smart Filtering**
  - Configurable sampling rates
  - Path exclusion patterns
  - Parameter filtering
  - Header sanitization

- 🔄 **Request Replay**
  - Exact request reproduction
  - Database state tracking
  - Error handling
  - Related request linking

- 📊 **Performance Analytics**
  - Response time tracking
  - Error rate monitoring
  - Request volume analysis
  - SQL query profiling

## Quick Start

1. Add to your Gemfile:
```ruby
gem 'railsclocks'
```

2. Install and run migrations:
```bash
rails generate railsclocks:install
rails db:migrate
```

3. Configure in `config/initializers/railsclocks.rb`:
```ruby
RailsClocks.configure do |config|
  config.enabled = true
  config.sample_rate = 1.0
  config.excluded_paths = [/assets/, /packs/]
end
```

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `enabled` | `true` | Enable/disable request recording |
| `sample_rate` | `1.0` | Percentage of requests to record |
| `excluded_paths` | `[/assets/, /packs/]` | Paths to ignore |
| `max_request_size_bytes` | `1.megabyte` | Maximum request size |
| `retention_period` | `30.days` | Data retention period |

## API Usage

```ruby
# Get recorded requests
requests = RailsClocks::RecordedRequest.recent

# Find specific request
request = RailsClocks::RecordedRequest.find_by(uuid: 'uuid')

# Replay request
result = request.replay

# Analyze performance
stats = RailsClocks::API.analyze_performance(period: 24.hours)
```

## Dashboard

Access the dashboard at `/railsclocks` to:
- View recorded requests
- Analyze performance metrics
- Replay specific requests
- Monitor error rates

## Security

RailsClocks includes:
- Parameter filtering
- Header sanitization
- Authorization controls
- Data retention policies

## Performance Impact

- Configurable sampling rate
- Minimal overhead (~1-2ms per request)
- Automatic data cleanup
- Compressed storage

## Contributing

1. Fork the repository
2. Create your feature branch
3. Run tests: `bundle exec rspec`
4. Submit a pull request

## Support

- 📖 [Documentation](https://github.com/tanzil7890/railsclocks/docs)
- 🐛 [Issue Tracker](https://github.com/tanzil7890/railsclocks/issues)
- 💬 [Discussions](https://github.com/tanzil7890/railsclocks/discussions)

## License

Released under the MIT License. See [LICENSE](LICENSE) for details.
