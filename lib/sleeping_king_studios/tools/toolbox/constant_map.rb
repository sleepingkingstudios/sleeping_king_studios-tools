# frozen_string_literal: true

require 'sleeping_king_studios/tools/string_tools'
require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  # Provides an enumerable interface for defining a group of constants.
  class ConstantMap < Module
    # @param constants [Hash] The constants to define.
    def initialize(constants)
      super()

      constants.each do |const_name, const_value|
        const_set(const_name, const_value)

        define_reader(const_name)
      end
    end

    # Returns a hash with the names and values of the defined constants.
    #
    # @return [Hash] The defined constants.
    def all
      constants.each.with_object({}) do |const_name, hsh|
        hsh[const_name] = const_get(const_name)
      end
    end

    # Iterates through the defined constants, yielding the name and value of
    # each constant to the block.
    #
    # @yieldparam key [Symbol] The name of the symbol.
    # @yieldparam value [Object] The value of the symbol.
    def each(&block)
      all.each(&block)
    end

    # Freezes the constant map and recursively freezes every constant value
    # using ObjectTools#deep_freeze. Also pre-emptively defines any reader
    # methods that are not already undefined.
    #
    # @see ObjectTools#deep_freeze
    def freeze
      constants.each do |const_name|
        object_tools.deep_freeze const_get(const_name)
      end

      super
    end

    private

    def define_reader(const_name, reader_name = nil)
      reader_name ||= string_tools.underscore(const_name.to_s).intern

      define_singleton_method(reader_name) { const_get const_name }
    end

    def object_tools
      ::SleepingKingStudios::Tools::ObjectTools
    end

    def string_tools
      ::SleepingKingStudios::Tools::StringTools
    end
  end
end
