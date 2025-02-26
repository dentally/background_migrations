class ManuallyRunBackgroundMigration < TestMigration
  include BackgroundMigrations

  background_migration { true }

  def up
    create_table :manually_run_background_migrations do |t|
      t.string :name
    end
  end
end
