
namespace :background_migrations do
  desc "List all pending background migrations"
  task list_pending_migrations: :environment do
    BackgroundMigrations::PendingMigration.print_pending_migrations(STDOUT)
  end

  desc "Run pending background migration"
  task :run_pending_migration, [:version] => :environment do |_t, args|
    BackgroundMigrations::Runner.run(args[:version])
  end
end
