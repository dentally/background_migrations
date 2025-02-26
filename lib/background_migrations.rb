# frozen_string_literal: true

require "logger"
require "active_support"
require "active_record"
require_relative "background_migrations/version"

module BackgroundMigrations
  class Error < StandardError; end

  extend ActiveSupport::Concern


  module ClassMethods
    def background_migration(&block)
      if block.call
        prepend(UpMethodHijacker)
      end
    end
  end

  module UpMethodHijacker
    def up(*args)

    end
  end
end
