# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module BackgroundMigrations
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      desc "Creates a migration for the background migrations pending table"

      def create_migration_file
        migration_template(
          "create_background_migrations_pending_migrations.rb.erb",
          "db/migrate/create_background_migrations_pending_migrations.rb"
        )
      end

      def self.next_migration_number(dirname)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      private

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end
    end
  end
end
