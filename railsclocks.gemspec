require_relative "lib/railsclocks/version"

Gem::Specification.new do |spec|
  spec.name        = "railsclocks"
  spec.version     = RailsClocks::VERSION
  spec.authors     = ["Your Name"]
  spec.email       = ["your.email@example.com"]
  spec.homepage    = "https://github.com/yourusername/railsclocks"
  spec.summary     = "Historical debugging & replay for Rails apps"
  spec.description = "A Rails engine that records requests and DB changes for debugging and replay. Supports configurable sampling and exclusion paths."
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.glob("{lib,app}/**/*") + %w[README.md LICENSE.txt]
  
  spec.add_dependency "rails", ">= 6.0.0"
  spec.add_dependency "activerecord", ">= 6.0.0"
  spec.add_dependency "request_store"
  
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rspec-rails"

  
  spec.add_dependency "kaminari" # For pagination
  spec.add_dependency "csv" # For CSV export

  spec.add_dependency "sass-rails"
  spec.add_dependency "webpacker", ">= 5.0"
  spec.add_dependency "turbolinks", "~> 5"

  spec.add_dependency "chart-js-rails"
end 