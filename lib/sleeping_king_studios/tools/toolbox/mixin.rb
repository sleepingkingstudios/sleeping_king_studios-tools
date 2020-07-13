# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  # Implements recursive inheritance of both class and instance methods.
  module Mixin
    # @api private
    def self.mixin?(mod)
      return false unless mod.is_a?(Module)

      mod.singleton_class.include?(self)
    end

    # @api private
    def included(other)
      return super unless defined?(self::ClassMethods)

      if SleepingKingStudios::Tools::Toolbox::Mixin.mixin?(other)
        unless other.constants(false).include?(:ClassMethods)
          other.const_set(:ClassMethods, Module.new)
        end

        other::ClassMethods.include(self::ClassMethods)
      else
        other.extend self::ClassMethods
      end

      super
    end
  end
end
