# frozen_string_literal: true

require 'forwardable'

require 'sleeping_king_studios/tools/toolbelt'
require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  # Provides an enumerable interface for defining a group of constants.
  class ConstantMap < Module
    extend  Forwardable
    include Enumerable

    # @param constants [Hash] The constants to define.
    def initialize(constants)
      super()

      @to_h = constants.dup

      constants.each do |const_name, const_value|
        const_set(const_name, const_value)

        define_reader(const_name)
      end
    end

    def_delegators :@to_h,
      :each,
      :each_key,
      :each_pair,
      :each_value,
      :keys,
      :values

    # @!method each
    #   Iterates through the defined constants, yielding the name and value of
    #   each constant to the block.
    #
    #   @yieldparam key [Symbol] The name of the constant.
    #   @yieldparam value [Object] The value of the constant.

    # @!method each_key
    #   Iterates through the defined constants, yielding the name of each
    #   constant to the block.
    #
    #   @yieldparam key [Symbol] The name of the constant.

    # @!method each_pair
    #   Iterates through the defined constants, yielding the name and value of
    #   each constant to the block.
    #
    #   @yieldparam key [Symbol] The name of the constant.
    #   @yieldparam value [Object] The value of the constant.

    # @!method each_value
    #   Iterates through the defined constants, yielding the value of each
    #   constant to the block.
    #
    #   @yieldparam value [Object] The value of the constant.

    # @!method keys
    #   @return [Array] the names of the defined constants.

    # @!method values
    #   @return [Array] the values of the defined constants.

    # @return [Hash] The defined constants.
    attr_reader :to_h
    alias all to_h

    # Freezes the constant map and recursively freezes every constant value
    # using ObjectTools#deep_freeze.
    #
    # @see ObjectTools#deep_freeze
    def freeze
      super

      tools.hsh.deep_freeze(@to_h)

      self
    end

    private

    def define_reader(const_name)
      reader_name ||= tools.str.underscore(const_name.to_s).intern

      define_singleton_method(reader_name) { const_get const_name }
    end

    def tools
      ::SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
