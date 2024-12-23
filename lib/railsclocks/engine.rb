module RailsClocks
  class Engine < ::Rails::Engine
    isolate_namespace RailsClocks

    initializer "railsclocks.middleware" do |app|
      app.middleware.use RailsClocks::Middleware
    end

    initializer "railsclocks.assets.precompile" do |app|
      app.config.assets.precompile += %w( railsclocks/application.css railsclocks/application.js )
    end
    
    config.after_initialize do |app|
      app.routes.append do
        mount RailsClocks::Engine => "/railsclocks"
      end
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end 