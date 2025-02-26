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
end
