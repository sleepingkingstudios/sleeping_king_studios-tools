# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  # Implements recursive inheritance of both class and instance methods.
  module Mixin
    # Checks if the given module is itself a Mixin.
    #
    # @param othermod [Object] the object or module to inspect.
    #
    # @return [true, false] true if the other object is a Module that extends
    #   Mixin; otherwise false.
    def self.mixin?(othermod)
      return false unless othermod.is_a?(Module)

      othermod.singleton_class.include?(self)
    end

    private

    # @api public
    #
    # Callback invoked whenever the receiver is included in another module.
    #
    # @param othermod [Module] the other class or module in which the mixin is
    #   included.
    #
    # @return [void]
    def included(othermod)
      return super unless defined?(self::ClassMethods)

      if SleepingKingStudios::Tools::Toolbox::Mixin.mixin?(othermod)
        unless othermod.constants(false).include?(:ClassMethods)
          othermod.const_set(:ClassMethods, Module.new)
        end

        othermod::ClassMethods.include(self::ClassMethods)
      else
        othermod.extend self::ClassMethods
      end

      super
    end

    # @api public
    #
    # Callback invoked whenever the receiver is prepended into another module.
    #
    # @param othermod [Module] the other class or module in which the mixin is
    #   prepended.
    #
    # @return [void]
    def prepended(othermod)
      return super unless defined?(self::ClassMethods)

      if SleepingKingStudios::Tools::Toolbox::Mixin.mixin?(othermod)
        unless othermod.constants(false).include?(:ClassMethods)
          othermod.const_set(:ClassMethods, Module.new)
        end

        othermod::ClassMethods.prepend(self::ClassMethods)
      else
        othermod.singleton_class.prepend(self::ClassMethods)
      end

      super
    end
  end
end
