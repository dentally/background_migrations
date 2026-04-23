module BackgroundMigrations
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/background_migrations.rake"
    end

    generators do
      require "generators/background_migrations/install/install_generator"
    end
  end
end
