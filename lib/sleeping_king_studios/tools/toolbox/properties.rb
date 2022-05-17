# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  module Properties
    BOOLEAN = ->(value) { value == true || value == false } # rubocop:disable Style/MultipleComparison
    private_constant :BOOLEAN

    # Class methods to extend onto the singleton class when extended.
    module ClassMethods
      # @api private
      def own_properties
        @own_properties ||= {}
      end

      # Defines and adds the property.
      #
      # Properties can be assigned a type, which is used to validate values
      # assigned to the property.
      #
      # - If the type is a Class or Module, then the value must be an instance
      #   of that Class or Module.
      # - If the type is a String or a Symbol, the value must be an instance of
      #   the Class or Module with that name.
      # - If the type is a Proc, then the value will be passed to the Proc, and
      #   the Proc must return a truthy value.
      #
      # A type of nil (the default) will skip validation of the value.
      #
      # A type of :boolean (or "boolean") has special behavior: the value must
      # be either true or false. In addition, boolean properties define a
      # predicate method by default.
      #
      # @param name [String, Symbol] The name of the property.
      # @param error_message [String] The message to display for a failed
      #   validation.
      # @param optional [true, false] If true, validation will be skipped for
      #   nil values.
      # @param predicate [true, false] If true, defines a predicate method for
      #   the property. Defaults to true for boolean properties, and false for
      #   all other property types.
      # @param read_only [true, false] If true, does not define a writer method
      #   for the property.
      # @param type [Class, Proc, String, Symbol] The expected property type,
      #   used to validate values for that property.
      def property( # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
        name,
        error_message: nil,
        optional:      false,
        predicate:     nil,
        read_only:     false,
        type:          nil
      )
        tools.assertions.validate_name(name, as: 'name')

        type      = resolve_type(type)
        message   = error_message || resolve_error_message(type)
        predicate = type == BOOLEAN if predicate.nil?
        property  = Property.new(
          error_message: message,
          name:          name.to_s,
          optional:      optional,
          predicate:     predicate,
          read_only:     read_only,
          type:          type
        )

        define_property_methods(property)

        own_properties[property.name] = property
      end

      def properties
        mod = SleepingKingStudios::Tools::Toolbox::Properties

        ancestors
          .each
          .select { |ancestor| ancestor < mod }
          .map(&:own_properties)
          .reduce(&:merge)
      end

      private

      def define_property_methods(property)
        unless const_defined?(:PropertyMethods, false)
          const_set(:PropertyMethods, Module.new)

          include const_get(:PropertyMethods)
        end

        define_property_reader(property)
      end

      def define_property_reader(property)
        reader_name = property.name

        const_get(:PropertyMethods).define_method(reader_name) do
          @properties[property.name]
        end
      end

      def resolve_error_message(type)
        return 'must be true or false' if type == BOOLEAN

        return 'is invalid' if type.nil? || type.is_a?(Proc)

        return "must be an instance of #{type.name}" if type.name

        named_ancestor = type.ancestors.find(&:name)

        return "must be an instance of #{type.inspect}" unless named_ancestor

        "must be an instance of #{type.inspect} (#{named_ancestor.name})"
      end

      def resolve_type(type)
        return type if type.nil? || type.is_a?(Module) || type.is_a?(Proc)

        tools.assertions.validate_name(
          type,
          message: 'type must be a Class or Module, the name of a Class or' \
                   ' Module, or a Proc'
        )

        type = type.to_s if type.is_a?(Symbol)
        type = tools.string_tools.camelize(type)

        return BOOLEAN if type == 'Boolean'

        Object.const_get(type)
      end

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end
    end

    # Value class for defined properties.
    class Property
      # @param error_message [String] The message to display for a failed
      #   validation.
      # @param name [String] The name of the property.
      # @param optional [true, false] If true, validation will be skipped for
      #   nil values.
      # @param predicate [true, false] If true, a predicate method is defined
      #   for the property.
      # @param read_only [true, false] If true, a writer method is not defined
      #   for the property.
      # @param type [#===] The expected type of the property.
      def initialize( # rubocop:disable Metrics/ParameterLists
        error_message:,
        name:,
        optional:,
        predicate:,
        read_only:,
        type:
      )
        @error_message = error_message
        @name          = name
        @optional      = optional
        @predicate     = predicate
        @read_only     = read_only
        @type          = type
      end

      # @return [String] the message to display for a failed validation.
      attr_reader :error_message

      # @return [String] the name of the property.
      attr_reader :name

      # @return [#===] the expected type of the property.
      attr_reader :type

      # @return [true, false] If true, the property represents a boolean value.
      def boolean?
        @boolean
      end

      # @return [true, false] if true, validation will be skipped for nil
      #   values.
      def optional?
        @optional
      end

      # @return [true, false] if true, a predicate method is defined for the
      #   property.
      def predicate?
        @predicate
      end

      # @return [true, false] if true, a writer method is not defined for the
      #   property.
      def read_only?
        @read_only
      end

      # Raises an exception if the value does not match the type.
      #
      # @param value [Object] The value to validate.
      #
      # @raise ArgumentError if the value does not match the expected type.
      def validate(value)
        return unless @type
        return if @optional && value.nil?
        return if validator.call(value)

        raise ArgumentError, "#{name} #{error_message}"
      end

      private

      def validator
        return @validator if @validator

        @validator = type.is_a?(Proc) ? type : ->(value) { value.is_a?(type) }
      end
    end

    class << self
      def new(*property_names, **property_tuples)
        mod = Module.new do
          include SleepingKingStudios::Tools::Toolbox::Properties
        end

        property_names.each do |property_name|
          mod.property(property_name)
        end

        property_tuples.each do |property_name, property_options|
          if property_options.is_a?(Hash)
            mod.property(property_name, **property_options)
          else
            mod.property(property_name, type: property_options)
          end
        end

        mod
      end

      private

      def included(other)
        super

        other.extend ClassMethods
      end
    end

    def initialize(**properties)
      @properties = {}

      self.class.properties.each_key do |property_name|
        @properties[property_name.to_s] = properties[property_name.intern]
      end
    end

    attr_reader :properties
  end
end
