# frozen_string_literal: true

require "logger"
require "active_support"
require "active_record"
require_relative "background_migrations/version"

module BackgroundMigrations
  class Error < StandardError; end
  # Your code goes here...
end
