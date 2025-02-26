# frozen_string_literal: true

require "sqlite3"
require "background_migrations"

TestMigration = ActiveRecord::Migration[ActiveRecord.version.to_s.to_f]
Dir.glob(File.join(File.dirname(__FILE__), "fixtures", "db", "*.rb")).each { |f| puts "Requiring #{f}"; require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
    ActiveRecord::SchemaMigration.create_table
  end

  config.include(
    Module.new do
      def migrate(migration, version = nil)
        migration = migration.new unless migration.is_a?(ActiveRecord::Migration)
        file_name = Object.const_source_location(migration.class.name).first.split("/").last
        version_from_file = file_name.split("_").first.to_i
        migration.version = version || version_from_file
        ActiveRecord::Migrator.new(:up, [migration], ActiveRecord::SchemaMigration, migration.version).migrate
      end
    end
  )
end
