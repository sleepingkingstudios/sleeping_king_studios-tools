# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  # Mixin to allow defining subclasses of Data classes.
  module HeritableData
    # Methods prepended onto the singleton class when including HeritableData.
    module ClassMethods
      # Compares `self` and `other`.
      #
      # @param other [Object] the object to compare.
      #
      # @return [true] if self is a subclass of other, or if the prototype chain
      #   of self includes other.
      # @return [false] if self and other are the same class, if other is a
      #   subclass of self, or if the prototype chain of other includes self.
      # @return [nil] if none of the above is true.
      def <(other)
        (self <=> other)&.then { |cmp| cmp == -1 }
      end

      # Compares `self` and `other`.
      #
      # @param other [Object] the object to compare.
      #
      # @return [true] if self and other are the same class, if self is a
      #   subclass of other, or if the prototype chain of self includes other.
      # @return [false] if other is a subclass of self, or if the prototype
      #   chain of other includes self.
      # @return [nil] if none of the above is true.
      def <=(other)
        (self <=> other)&.then { |cmp| cmp < 1 }
      end

      # Compares `self` and `other`.
      #
      # @param other [Object] the object to compare.
      #
      # @return [-1] if self is a subclass of other, or if the prototype chain
      #   of self includes other.
      # @return [0] if self and other are the same class.
      # @return [1] if self is a parent class of other, or if the prototype
      #   chain of other includes self.
      # @return [nil] if none of the above is true.
      def <=>(other)
        return super unless other.is_a?(Class)

        return -1 if other.equal?(Data)

        return 0 if other.equal?(self)

        return nil unless other.respond_to?(:prototypes_include?, true)

        return -1 if prototypes_include?(other)

        1 if other.prototypes_include?(self)
      end

      # @return [true] if the object is an instance of the data class or of any
      #   data class that has this data class in its prototype chain.
      def ===(object)
        return true if super

        self > object.class ? true : false # rubocop:disable Style/IfWithBooleanLiteralBranches, Style/RedundantConditional
      end

      # Compares `self` and `other`.
      #
      # @param other [Object] the object to compare.
      #
      # @return [true] if other is a subclass of other, or if the prototype
      #   chain of other includes self.
      # @return [false] if self and other are the same class, if self is a
      #   subclass of other, or if the prototype chain of self includes other.
      # @return [nil] if none of the above is true.
      def >(other)
        (self <=> other)&.then { |cmp| cmp == 1 }
      end

      # Compares `self` and `other`.
      #
      # @param other [Object] the object to compare.
      #
      # @return [true] if self and other are the same class, if other is a
      #   subclass of other, or if the prototype chain of other includes self.
      # @return [false] if self is a subclass of other, or if the prototype
      #   chain of self includes other.
      # @return [nil] if none of the above is true.
      def >=(other)
        (self <=> other)&.then { |cmp| cmp > -1 }
      end

      # Defines a new Data class including the members/methods of this class.
      def define(*symbols, &methods)
        prototype = self

        Data.define(*members, *symbols) do
          include HeritableData

          @prototype = prototype

          self::Methods.include(prototype::Methods)
          self::Methods.class_exec(&methods) if methods
        end
      end

      # @return [Class] the Data class used to defined this class.
      def prototype = @prototype || Data

      protected

      def prototypes_include?(other)
        each_prototype.include?(other)
      end

      private

      def each_prototype
        return enum_for(:each_prototype) unless block_given?

        data_class = self

        while data_class != Data
          yield data_class

          data_class = data_class.prototype
        end
      end
    end

    class << self
      private

      def included(other)
        super

        unless other.const_defined?(:Methods, false)
          other.const_set(:Methods, Module.new)
        end

        other.include(other.const_get(:Methods))
        other.singleton_class.prepend(ClassMethods)
      end
    end

    # Checks if the object class inherits from type.
    #
    # @param type [Module] the type to check.
    #
    # @return [true] if the object class inherits from type, or if the prototype
    #   chain of the object class includes type.
    def is_a?(type)
      super || self.class < type || false
    end
    alias kind_of? is_a?
  end
end
