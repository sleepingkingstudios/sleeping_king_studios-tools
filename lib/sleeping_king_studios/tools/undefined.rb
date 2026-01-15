# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Immutable empty object used to represent undefined method parameters.
  #
  # Use an instance of Undefined as a value object to distinguish between an
  # optional method parameter that is passed a nil value from a method parameter
  # that is not passed.
  #
  # @example
  #   UNDEFINED = Undefined.new
  #   private_constant :UNDEFINED
  #
  #   def parameter_passed?(parameter = UNDEFINED)
  #     parameter != UNDEFINED
  #   end
  #
  #   parameter_passed?      #=> false
  #   parameter_passed?(nil) #=> true
  class Undefined < BasicObject
    # @return [String] a string containing a human-readable representation of
    #   the object.
    def inspect
      ::Object.instance_method(:inspect).bind(self).call
    end

    # @param mod [Module] the class or module to compare.
    #
    # @return [true, false] true if the object is an instance of the given
    #   class.
    def instance_of?(mod)
      ::Object.instance_method(:instance_of?).bind(self).call(mod)
    end

    # @param mod [Module] the class or module to compare.
    #
    # @return [true, false] true if the given class is an ancestor of the
    #   object.
    def is_a?(mod)
      ::Object.instance_method(:is_a?).bind(self).call(mod)
    end
    alias kind_of? is_a?

    ::Object.instance_method(:singleton_class).bind(self).call.freeze

    freeze
  end
end
