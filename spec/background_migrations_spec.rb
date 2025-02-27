# frozen_string_literal: true

RSpec.describe BackgroundMigrations do
  it "has a version number" do
    expect(BackgroundMigrations::VERSION).not_to be nil
  end

  it "runs a normal migration normally" do
    migrate(NormalMigration)
    expect(ActiveRecord::Base.connection.table_exists?(:normal_migrations)).to be true
    expect(ActiveRecord::SchemaMigration.where(version: 1).count).to eq(1)
  end

  it "runs background migrations that shouldn't be backgrounded" do
    migrate(AutomaticallyRunBackgroundMigration)
    expect(ActiveRecord::Base.connection.table_exists?(:automatically_run_background_migrations)).to be true
    expect(ActiveRecord::SchemaMigration.where(version: 2).count).to eq(1)
  end

  it "marks background migrations as run but doesn't run the actual migration" do
    migrate(ManuallyRunBackgroundMigration)
    expect(ActiveRecord::Base.connection.table_exists?(:manually_run_background_migrations)).to be false
    expect(ActiveRecord::SchemaMigration.where(version: 3).count).to eq(1)
  end

  it "adds the migration to the pending background migrations table" do
    migrate(ManuallyRunBackgroundMigration)
    expect(BackgroundMigrations::PendingMigration.where(version: 3).count).to eq(1)
  end

  it "breaks if a BackgroundMigration defines the change method" do
    create_breaking_migration = proc do
      Class.new(TestMigration) do
        include BackgroundMigrations

        background_migration { false }

        def change
          create_table :breaking_migrations do |t|
            t.string :name
          end
        end
      end
    end
    expect { create_breaking_migration.call }.to raise_error("BackgroundMigrations cannot define the change method, please use `up` and `down` instead")
    expect(ActiveRecord::Base.connection.table_exists?(:breaking_migrations)).to be false
  end

  describe "Runner" do
    it "runs a pending migration" do
      migrate(ManuallyRunBackgroundMigration)
      expect(ActiveRecord::Base.connection.table_exists?(:manually_run_background_migrations)).to be false
      BackgroundMigrations::Runner.run("3")
      expect(ActiveRecord::Base.connection.table_exists?(:manually_run_background_migrations)).to be true
    end

    it "clears the migration from the pending migrations table" do
      migrate(ManuallyRunBackgroundMigration)
      expect(BackgroundMigrations::PendingMigration.where(version: 3).count).to eq(1)
      BackgroundMigrations::Runner.run("3")
      expect(BackgroundMigrations::PendingMigration.where(version: 3).count).to eq(0)
    end

    it "doesn't run the background migration if it's not pending" do
      expect { BackgroundMigrations::Runner.run("3") }.to raise_error("No pending background migration found for 3")
    end

    it "ensure the runner isn't running after it succeeds" do
      migrate(ManuallyRunBackgroundMigration)
      expect(BackgroundMigrations::Runner.running).to be false
      BackgroundMigrations::Runner.run("3")
      expect(BackgroundMigrations::Runner.running).to be false
    end
  end
end
