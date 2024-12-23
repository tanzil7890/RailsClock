module RailsClocks
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      
      source_root File.expand_path('templates', __dir__)
      
      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        ActiveRecord::Migration.next_migration_number(next_migration_number)
      end

      def create_migration_file
        migration_template(
          'create_railsclocks_recorded_requests.rb.erb',
          'db/migrate/create_railsclocks_recorded_requests.rb'
        )
      end

      def create_initializer
        template 'initializer.rb', 'config/initializers/railsclocks.rb'
      end
    end
  end
end 