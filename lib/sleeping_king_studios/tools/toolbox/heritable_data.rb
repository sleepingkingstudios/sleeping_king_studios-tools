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
      # @return [true] if self is a subclass of other, or if self inherits Data
      #   members and methods from other.
      # @return [false] if self and other are the same class, if other is a
      #   subclass of self, or if other inherits Data members and methods from
      #   self.
      # @return [nil] if none of the above is true.
      def <(other)
        (self <=> other)&.then { |cmp| cmp == -1 }
      end

      # Compares `self` and `other`.
      #
      # @param other [Object] the object to compare.
      #
      # @return [true] if self and other are the same class, if self is a
      #   subclass of other, or if self inherits Data members and methods from
      #   other.
      # @return [false] if other is a subclass of self, or if other inherits
      #   Data members and methods from self.
      # @return [nil] if none of the above is true.
      def <=(other)
        (self <=> other)&.then { |cmp| cmp < 1 }
      end

      # Compares `self` and `other`.
      #
      # @param other [Object] the object to compare.
      #
      # @return [-1] if self is a subclass of other, or if self inherits Data
      #   members and methods from other.
      # @return [0] if self and other are the same class.
      # @return [1] if self is a parent class of other, or if other inherits
      #   Data members and methods from self.
      # @return [nil] if none of the above is true.
      def <=>(other)
        return super unless other.is_a?(Class)

        return -1 if other.equal?(Data)
        return 0  if other.equal?(self)

        return nil unless other.const_defined?(:HeritableMethods)

        self::HeritableMethods <=> other::HeritableMethods
      end

      # @return [true] if the object is an instance of the data class, or if the
      #   object is an instance of a Data class that inherits members and
      #   methods from self.
      def ===(object)
        return true if super

        (self > object.class) || false
      end

      # Compares `self` and `other`.
      #
      # @param other [Object] the object to compare.
      #
      # @return [true] if other is a subclass of other, or if other inherits
      #   Data members and methods from self.
      # @return [false] if self and other are the same class, if self is a
      #   subclass of other, or if self inherits Data members and methods from
      #   other.
      # @return [nil] if none of the above is true.
      def >(other)
        (self <=> other)&.then { |cmp| cmp == 1 }
      end

      # Compares `self` and `other`.
      #
      # @param other [Object] the object to compare.
      #
      # @return [true] if self and other are the same class, if other is a
      #   subclass of other, or if other inherits Data members and methods from
      #   self.
      # @return [false] if self is a subclass of other, or if self inherits Data
      #   members and methods from other.
      # @return [nil] if none of the above is true.
      def >=(other)
        (self <=> other)&.then { |cmp| cmp > -1 }
      end

      # Defines a new Data class including the members/methods of this class.
      #
      # The defined data class will include HeritableData, and will be able to
      # define it's own Data types using this method.
      #
      # @param symbols [Array<Symbol>] additional Data members to define. Any
      #   members listed here will be appended to the members defined on the
      #   parent Data class.
      #
      # @yield additional methods to define on the new Data class.
      def define(*symbols, &)
        HeritableData.define(*symbols, parent_class: self, &)
      end
    end

    class << self
      # Defines a new heritable Data class.
      #
      # @param symbols [Array<Symbol>] Data members to define.
      # @param parent_class [Class] the parent class to inherit members and
      #   methods from.
      #
      # @yield additional methods to define on the new Data class.
      def define(*symbols, parent_class: nil, &methods)
        Data.define(*parent_class&.members, *symbols) do
          include HeritableData

          if parent_class
            self::HeritableMethods.include(parent_class::HeritableMethods)
          end

          self::HeritableMethods.class_exec(&methods) if methods
        end
      end

      private

      def included(other)
        super

        unless other.const_defined?(:HeritableMethods, false)
          other.const_set(:HeritableMethods, Module.new)
        end

        other.include(other.const_get(:HeritableMethods))
        other.singleton_class.prepend(ClassMethods)
      end
    end

    # Checks if the object class inherits from type.
    #
    # @param type [Module] the type to check.
    #
    # @return [true] if the object class inherits from type, or if the object
    #   class inherits members and methods from the given type.
    def is_a?(type)
      super || self.class < type || false
    end
    alias kind_of? is_a?
  end
end
