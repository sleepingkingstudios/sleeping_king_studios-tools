# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Helper object for quick access to all available tools.
  class Toolbelt < BasicObject
    # @return [SleepingKingStudios::Tools::Toolbelt] a memoized instance of the
    #   toolbelt class.
    def self.instance
      @instance ||= new
    end

    # @param deprecation_strategy [String] The name of the strategy used when
    #   deprecated code is called. Must be 'ignore', 'raise', or 'warn'.
    # @param inflector [Object] An object that conforms to the interface used
    #   by SleepingKingStudios::Tools::Toolbox::Inflector, such as
    #   ActiveSupport::Inflector .
    def initialize(deprecation_strategy: nil, inflector: nil)
      @array_tools   = ::SleepingKingStudios::Tools::ArrayTools.new
      @assertions    = ::SleepingKingStudios::Tools::Assertions.new
      @core_tools    =
        ::SleepingKingStudios::Tools::CoreTools.new(deprecation_strategy:)
      @hash_tools    = ::SleepingKingStudios::Tools::HashTools.new
      @integer_tools = ::SleepingKingStudios::Tools::IntegerTools.new
      @object_tools  = ::SleepingKingStudios::Tools::ObjectTools.new
      @string_tools  =
        ::SleepingKingStudios::Tools::StringTools.new(inflector:)
    end

    attr_reader :array_tools

    attr_reader :assertions

    attr_reader :core_tools

    attr_reader :hash_tools

    attr_reader :integer_tools

    attr_reader :object_tools

    attr_reader :string_tools

    alias ary array_tools
    alias hsh hash_tools
    alias int integer_tools
    alias obj object_tools
    alias str string_tools

    # @return [String] a human-readable representation of the object.
    def inspect
      "#<#{::Object.instance_method(:class).bind(self).call.name}>"
    end
    alias to_s inspect
  end
end
