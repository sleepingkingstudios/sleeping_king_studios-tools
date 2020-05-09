# frozen_string_literal: true

require 'sleeping_king_studios/tools/string_tools'
require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  # Provides an enumerable interface for defining a group of constants.
  module ConstantMap
    class << self
      # Creates a new ConstantMap.
      #
      # @param constants [Hash] The constants to define.
      def new(constants)
        mod = Module.new
        mod.extend self

        constants.each do |const_name, const_value|
          mod.const_set const_name, const_value
        end

        mod
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
        reader_name = const_name.downcase

        unless methods.include?(reader_name)
          define_reader(const_name, reader_name)
        end

        object_tools.deep_freeze const_get(const_name)
      end

      super
    end

    private

    def define_reader(const_name, reader_name = nil)
      reader_name ||= const_name.downcase

      define_singleton_method reader_name, -> { const_get const_name }
    end

    def method_missing(symbol, *args, &block)
      const_name = string_tools.underscore(symbol.to_s).upcase.intern

      if constants.include?(const_name)
        define_reader(const_name, symbol)

        return send(symbol, *args, &block)
      end

      super
    end

    def object_tools
      ::SleepingKingStudios::Tools::ObjectTools
    end

    def respond_to_missing?(symbol, include_all = false)
      const_name = string_tools.underscore(symbol.to_s).upcase.intern

      constants.include?(const_name) || super
    end

    def string_tools
      ::SleepingKingStudios::Tools::StringTools
    end
  end
end
