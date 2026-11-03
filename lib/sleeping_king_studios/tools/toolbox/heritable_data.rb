# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  # Mixin to allow defining subclasses of Data classes.
  module HeritableData
    # Special thanks to `@havenwood` from the Ruby Discord on the solution here.
    DEFINE = Data.singleton_class.instance_method(:define)
    private_constant :DEFINE

    # Methods prepended onto the singleton class when including HeritableData.
    module ClassMethods
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
      def define(*symbols, &block)
        # @deprecated v2.0
        block = wrap_class_block(block)

        DEFINE
          .bind_call(self, *members, *symbols, &block)
          .include(HeritableData)
          .tap do |data_class|
            # @deprecated v2.0
            handle_deprecated_lifecycle_hooks(data_class)
          end
      end
      alias with define

      private

      # @deprecated v2.0
      def handle_deprecated_lifecycle_hooks(data_class)
        return if data_class.method(:included).owner == Module

        SleepingKingStudios::Tools::Toolbelt
          .instance
          .core_tools
          .deprecate(
            'Defining class methods or including modules using an `included` ' \
            'hook is deprecated. Define the methods or include the modules ' \
            'directly in the block.'
          )

        # Ensure legacy class methods defined via .included hook are defined for
        # the child class.
        data_class.send(:included, data_class)
      end

      # @deprecated v2.0
      def wrap_class_block(block)
        return block unless block&.lambda? && block.arity.zero?

        SleepingKingStudios::Tools::Toolbelt
          .instance
          .core_tools
          .deprecate(
            'Data.define with a lambda of arity zero is not supported. This ' \
            'will raise an ArgumentError starting in version 2.0.'
          )

        ->(mod) { mod.class_exec(&block) }
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
      def define(*symbols, parent_class: nil, &block) # rubocop:disable Metrics/MethodLength
        # @deprecated v2.0
        if parent_class
          SleepingKingStudios::Tools::Toolbelt
            .instance
            .core_tools
            .deprecate(
              'HeritableData.define with a parent class is deprecated and ' \
              'will be removed starting in version 2.0.'
            )

          return parent_class.define(*symbols, &block)
        end

        # @deprecated v2.0
        block = wrap_class_block(block)

        Data
          .define(*symbols, &block)
          .include(HeritableData)
          .tap do |data_class|
            # @deprecated v2.0
            handle_deprecated_lifecycle_hooks(data_class)
          end
      end
      alias with define

      private

      # @deprecated v2.0
      def handle_deprecated_lifecycle_hooks(data_class)
        return if data_class.method(:included).owner == Module

        SleepingKingStudios::Tools::Toolbelt
          .instance
          .core_tools
          .deprecate(
            'Defining class methods or including modules using an `included` ' \
            'hook is deprecated. Define the methods or include the modules ' \
            'directly in the block.'
          )

        # Ensure legacy class methods defined via .included hook are defined for
        # the child class.
        data_class.send(:included, data_class)
      end

      def included(other)
        super

        other.singleton_class.prepend(ClassMethods)
      end

      # @deprecated v2.0
      def wrap_class_block(block)
        return block unless block&.lambda? && block.arity.zero?

        SleepingKingStudios::Tools::Toolbelt
          .instance
          .core_tools
          .deprecate(
            'Data.define with a lambda of arity zero is not supported. This ' \
            'will raise an ArgumentError starting in version 2.0.'
          )

        ->(mod) { mod.class_exec(&block) }
      end
    end
  end
end
