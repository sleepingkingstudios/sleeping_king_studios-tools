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
    class << self
      semaphore = Thread::Mutex.new

      # @!method global()
      #   Returns a singleton instance of the messages registry, instantiating
      #   the instance if needed.
      #
      #   @return [Registry] the messages registry singleton.
      define_method :global do
        semaphore.synchronize { @global ||= new }
      end
      alias instance global
    end

    # @param deprecation_caller_depth [Integer] the number of backtrace lines to
    #   display when outputting a deprecation warning.
    # @param deprecation_strategy [String] the name of the strategy used when
    #   deprecated code is called. Must be 'ignore', 'raise', or 'warn'.
    # @param inflector [Object] service object for inflecting strings. The
    #   inflector must be an object that conforms to the interface used by
    #   by SleepingKingStudios::Tools::Toolbox::Inflector, such as an instance
    #   of ActiveSupport::Inflector .
    # @param messages_registry [SleepingKingStudios::Tools::Messages::Registry]
    #   the strategies registry to use for the tool. Defaults to the value of
    #   Registry.global.
    def initialize(
      deprecation_caller_depth: nil,
      deprecation_strategy:     nil,
      inflector:                nil,
      messages_registry:        nil
    )
      @deprecation_caller_depth = deprecation_caller_depth
      @deprecation_strategy     = deprecation_strategy
      @inflector                = inflector
      @messages_registry        = messages_registry
    end

    # @return [SleepingKingStudios::Tools::ArrayTools] tools for working with
    #   array-like enumerable objects.
    def array_tools
      @array_tools ||= ::SleepingKingStudios::Tools::ArrayTools.new(toolbelt:)
    end
    alias ary array_tools

    # @return [SleepingKingStudios::Tools::Assertions] methods for asserting on
    #   the state of a function or application.
    def assertions
      @assertions ||= ::SleepingKingStudios::Tools::Assertions.new(toolbelt:)
    end

    # @return [SleepingKingStudios::Tools::CoreTools] tools for working with an
    #   application or working environment.
    def core_tools
      @core_tools ||= ::SleepingKingStudios::Tools::CoreTools.new(
        deprecation_caller_depth:,
        deprecation_strategy:,
        toolbelt:
      )
    end

    # @return [SleepingKingStudios::Tools::HashTools] tools for working with
    #   hash-like enumerable objects.
    def hash_tools
      @hash_tools ||= ::SleepingKingStudios::Tools::HashTools.new(toolbelt:)
    end
    alias hsh hash_tools

    # @return [String] a human-readable representation of the object.
    def inspect
      "#<#{::Object.instance_method(:class).bind(self).call.name}>"
    end
    alias to_s inspect

    # @return [SleepingKingStudios::Tools::IntegerTools] tools for working with
    #   integers.
    def integer_tools
      @integer_tools = ::SleepingKingStudios::Tools::IntegerTools.new(toolbelt:)
    end
    alias int integer_tools

    # @return [SleepingKingStudios::Tools::Messages] methods for generating
    #   human-readable messages.
    def messages
      @messages ||= ::SleepingKingStudios::Tools::Messages.new(
        registry: messages_registry,
        toolbelt:
      )
    end

    # @return [SleepingKingStudios::Tools::ObjectTools] low-level tools for
    #   working with objects.
    def object_tools
      @object_tools ||= ::SleepingKingStudios::Tools::ObjectTools.new(toolbelt:)
    end
    alias obj object_tools

    # @return [SleepingKingStudios::Tools::ObjectTools] tools for working with
    #   strings.
    def string_tools
      @string_tools ||= ::SleepingKingStudios::Tools::StringTools.new(
        inflector:,
        toolbelt:
      )
    end
    alias str string_tools

    private

    attr_reader :deprecation_caller_depth

    attr_reader :deprecation_strategy

    attr_reader :inflector

    attr_reader :messages_registry

    def toolbelt = self
  end
end
