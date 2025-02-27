# frozen_string_literal: true

require "logger"
require "active_support"
require "active_record"
require_relative "background_migrations/version"

module BackgroundMigrations
  class Error < StandardError; end

  extend ActiveSupport::Concern

  cattr_accessor :logger
  self.logger = Object.const_defined?(:Rails) ? Rails.logger : Logger.new(nil)

  cattr_accessor :migrations_dir
  self.migrations_dir = Rails.root + "/db/migrate" if Object.const_defined?(:Rails)

  module ClassMethods
    def background_migration(&block)
      if block.call
        prepend(UpMethodHijacker)
      end
    end

    def method_added(method)
      super
      return unless method == :change

      raise "BackgroundMigrations cannot define the change method, please use `up` and `down` instead"
    end
  end

  class Runner
    cattr_accessor :running
    self.running = false

    def self.run(version)
      self.running = true
      version = version.to_s
      raise "Timestamp must be a number" unless version.match?(/^\d+$/)
      raise "No migration_dir set" unless BackgroundMigrations.migrations_dir

      file_names = Dir.foreach(BackgroundMigrations.migrations_dir).select { |f| f.match?(/^#{version}_/) }
      raise "No migration found for version #{version}" if file_names.empty?
      raise "Multiple migrations found for version #{version}" if file_names.size > 1

      PendingMigration.create_table
      pending_migration = PendingMigration.find_by(version: version)
      raise "No pending background migration found for #{version}" unless pending_migration

      file_name = File.basename(file_names.first, ".rb")
      klass_name = file_name.sub(/\d+_/, "").camelize

      require "#{BackgroundMigrations.migrations_dir}/#{file_name}"
      klass = klass_name.constantize
      klass.new.migrate(:up)
      pending_migration.destroy!
    ensure
      self.running = false
    end
  end

  module UpMethodHijacker
    def up(*args)
      return super if Runner.running

      BackgroundMigrations.logger.info("Skipping backgrounded migration #{self.class.name}")
      PendingMigration.create_table
      PendingMigration.create!(version: version)
    end
  end

  class PendingMigration < ActiveRecord::Base
    self.table_name = "background_migrations_pending"

    def self.create_table
      return if connection.table_exists?(table_name)

      connection.create_table(table_name) do |t|
        t.string :version, null: false
      end
    end
  end
end
