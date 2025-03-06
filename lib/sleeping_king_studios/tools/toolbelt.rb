# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Helper object for quick access to all available tools.
  #
  # Specific tools can be accessed by name. For example, to access the
  # configured instance of ArrayTools, call Toolbelt#array_tools. Certain tools
  # also define a shorthand - for example, the array_tools instance can also be
  # accessed using Toolbelt#ary.
  #
  # @example
  #   toolbelt = SleepingKingStudios::Tools::Toolbelt.new
  #
  #   toolbelt.array_tools.pluralize('light')
  #   #=> 'lights'
  class Toolbelt < BasicObject
    # @return [SleepingKingStudios::Tools::Toolbelt] a memoized instance of the
    #   toolbelt class.
    def self.instance
      @instance ||= new
    end

    # @param deprecation_caller_depth [Integer] the number of backtrace lines to
    #   display when outputting a deprecation warning.
    # @param deprecation_strategy [String] the name of the strategy used when
    #   deprecated code is called. Must be 'ignore', 'raise', or 'warn'.
    # @param inflector [Object] service object for inflecting strings. The
    #   inflector must be an object that conforms to the interface used by
    #   by SleepingKingStudios::Tools::Toolbox::Inflector, such as an instance
    #   of ActiveSupport::Inflector .
    def initialize( # rubocop:disable Metrics/MethodLength
      deprecation_caller_depth: nil,
      deprecation_strategy:     nil,
      inflector:                nil
    )
      @array_tools   = ::SleepingKingStudios::Tools::ArrayTools.new
      @assertions    = ::SleepingKingStudios::Tools::Assertions.new
      @core_tools    =
        ::SleepingKingStudios::Tools::CoreTools.new(
          deprecation_caller_depth:,
          deprecation_strategy:
        )
      @hash_tools    = ::SleepingKingStudios::Tools::HashTools.new
      @integer_tools = ::SleepingKingStudios::Tools::IntegerTools.new
      @object_tools  = ::SleepingKingStudios::Tools::ObjectTools.new
      @string_tools  =
        ::SleepingKingStudios::Tools::StringTools.new(inflector:)
    end

    # @return [SleepingKingStudios::Tools::ArrayTools] tools for working with
    #   array-like enumerable objects.
    attr_reader :array_tools
    alias ary array_tools

    # @return [SleepingKingStudios::Tools::Assertions] methods for asserting on
    #   the state of a function or application.
    attr_reader :assertions

    # @return [SleepingKingStudios::Tools::CoreTools] tools for working with an
    #   application or working environment.
    attr_reader :core_tools

    # @return [SleepingKingStudios::Tools::HashTools] tools for working with
    #   hash-like enumerable objects.
    attr_reader :hash_tools
    alias hsh hash_tools

    # @return [SleepingKingStudios::Tools::IntegerTools] tools for working with
    #   integers.
    attr_reader :integer_tools
    alias int integer_tools

    # @return [SleepingKingStudios::Tools::ObjectTools] low-level tools for
    #   working with objects.
    attr_reader :object_tools
    alias obj object_tools

    # @return [SleepingKingStudios::Tools::ObjectTools] tools for working with
    #   strings.
    attr_reader :string_tools
    alias str string_tools

    # @return [String] a human-readable representation of the object.
    def inspect
      "#<#{::Object.instance_method(:class).bind(self).call.name}>"
    end
    alias to_s inspect
  end
end
