# frozen_string_literal: true

require 'forwardable'

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Abstract base class for Tools classes.
  class Base
    class << self
      extend Forwardable
    end

    UNDEFINED = SleepingKingStudios::Tools::UNDEFINED
    private_constant :UNDEFINED

    # @return [SleepingKingStudios::Tools::Base] a memoized instance of the
    #   tools class.
    #
    # @deprecated v1.3.0 Use Toolbelt.instance instead.
    def self.instance
      SleepingKingStudios::Tools::Toolbelt.instance.core_tools.deprecate(
        "#{name}.instance",
        message: 'Use Toolbelt.instance instead.'
      )

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
