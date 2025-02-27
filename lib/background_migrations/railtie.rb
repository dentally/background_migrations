module BackgroundMigrations
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/background_migrations.rake"
    end
  end
end
