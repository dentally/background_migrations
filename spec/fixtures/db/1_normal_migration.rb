class NormalMigration < TestMigration
  def change
    create_table :normal_migrations do |t|
      t.string :name
    end
  end
end
