
namespace :background_migrations do
  desc "List all pending background migrations"
  task list_pending_migrations: :environment do
    puts BackgroundMigrations::PendingMigration.all.pluck(:version)
  end

  desc "Run pending background migration"
  task :run_pending_migration, [:version] => :environment do |_t, args|
    BackgroundMigrations::Runner.run(args[:version])
  end

  desc "Move a migration to the background (marks it as run but doesn't actually run it)"
  task :move_migration_to_background, [:version] => :environment do |_t, args|
    BackgroundMigrations::PendingMigration.move_migration_to_background(args[:version])
  end
end
