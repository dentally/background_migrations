# frozen_string_literal: true

require "logger"
require "active_support"
require "active_record"
require_relative "background_migrations/version"

module BackgroundMigrations
  class Error < StandardError; end

  extend ActiveSupport::Concern

  cattr_accessor :logger
  self.logger = Logger.new(nil)

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

  module UpMethodHijacker
    def up(*args)
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
