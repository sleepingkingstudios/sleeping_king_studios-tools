# frozen_string_literal: true

require 'forwardable'

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Abstract base class for Tools classes.
  class Base
    class << self
      extend Forwardable
    end

    # @return [SleepingKingStudios::Tools::Base] a memoized instance of the
    #   tools class.
    def self.instance
      @instance ||= new
    end

    # @param toolbelt [SleepingKingStudios::Tools::Toolbelt] the toolbelt this
    #   tools instance belongs to.
    def initialize(toolbelt: nil)
      @toolbelt = toolbelt
    end

    # @return [SleepingKingStudios::Tools::Toolbelt] the toolbelt this
    #   tools instance belongs to, or the global toolbelt singleton.
    def toolbelt
      @toolbelt ||= SleepingKingStudios::Tools::Toolbelt.global
    end
    alias tools toolbelt
  end
end
