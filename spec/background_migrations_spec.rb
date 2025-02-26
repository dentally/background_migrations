# frozen_string_literal: true

RSpec.describe BackgroundMigrations do
  it "has a version number" do
    expect(BackgroundMigrations::VERSION).not_to be nil
  end

  it "runs a normal migration normally" do
    migrate(NormalMigration)
    expect(ActiveRecord::Base.connection.table_exists?(:normal_migrations)).to be true
  end
end
