class AutomaticallyRunBackgroundMigration < TestMigration
  # include BackgroundMigrations

  # background_migration { false }

  def change
    create_table :automatically_run_background_migrations do |t|
      t.string :name
    end
  end
end
