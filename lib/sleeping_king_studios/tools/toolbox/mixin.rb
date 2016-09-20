# lib/sleeping_king_studios/tools/toolbox/mixin.rb

require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  # Implements recursive inheritance of both class and instance methods.
  module Mixin
    # @api private
    def self.mixin? mod
      return false unless mod.is_a?(Module)

      mod.singleton_class.include?(self)
    end # class method mixin?

    # @api private
    def included other
      return super unless defined?(self::ClassMethods)

      if SleepingKingStudios::Tools::Toolbox::Mixin.mixin?(other)
        unless other.constants(false).include?(:ClassMethods)
          other.const_set(:ClassMethods, Module.new)
        end # unless

        other::ClassMethods.send :include, self::ClassMethods
      else
        other.extend self::ClassMethods
      end # if-else

      super
    end # method included
  end # module
end # module
