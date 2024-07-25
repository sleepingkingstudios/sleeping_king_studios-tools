# frozen_string_literal: true

require 'forwardable'

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Methods for asserting on the state of a function or application.
  class Assertions < Base # rubocop:disable Metrics/ClassLength
    # rubocop:disable Layout/HashAlignment
    ERROR_MESSAGES =
      {
        'blank' =>
          'must be nil or empty',
        'block' =>
          'block returned a falsy value',
        'boolean' =>
          'must be true or false',
        'class' =>
          'is not a Class',
        'instance_of' =>
          'is not an instance of %<expected>s',
        'instance_of_anonymous' =>
          'is not an instance of %<expected>s (%<parent>s)',
        'matches' =>
          'does not match the expected value',
        'matches_proc' =>
          'does not match the Proc',
        'matches_regexp' =>
          'does not match the pattern %<pattern>s',
        'name' =>
          'is not a String or a Symbol',
        # @note: This value will be changed in a future version.
        'presence' =>
          "can't be blank"
      }
      .transform_keys { |key| "sleeping_king_studios.tools.assertions.#{key}" }
      .freeze
    private_constant :ERROR_MESSAGES
    # rubocop:enable Layout/HashAlignment

    # Utility for grouping multiple assertion statements.
    class Aggregator < Assertions
      extend Forwardable

      def initialize
        super

        @failures = []
      end

      def_delegators :@failures,
        :<<,
        :clear,
        :count,
        :each,
        :empty?,
        :size

      # (see SleepingKingStudios::Tools::Assertions#assert_group)
      def assert_group(error_class: AssertionError, message: nil, &assertions)
        return super if message

        raise ArgumentError, 'no block given' unless block_given?

        assertions.call(self)
      end
      alias aggregate assert_group

      # @return [String] the combined messages for each failed assertion.
      def failure_message
        failures.join(', ')
      end

      private

      attr_reader :failures

      def handle_error(message:, **_)
        failures << message

        message
      end
    end

    # Error class for handling a failed assertion.
    class AssertionError < StandardError; end

    # @return [Class] the class used to aggregate grouped assertion failures.
    def aggregator_class
      Aggregator
    end

    # Asserts that the block returns a truthy value.
    #
    # @param error_class [Class] the exception class to raise on a failure.
    # @param message [String] the exception message to raise on a failure.
    #
    # @yield The block to evaluate.
    # @yieldreturn [Object] the returned value of the block.
    #
    # @raise AssertionError if the block does not return a truthy value.
    def assert(error_class: AssertionError, message: nil, &block)
      return if block.call

      message ||= error_message_for(
        'sleeping_king_studios.tools.assertions.block',
        as: false
      )

      handle_error(error_class:, message:)
    end

    # Asserts that the value is either nil or empty.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param error_class [Class] the exception class to raise on a failure.
    # @param message [String] the exception message to raise on a failure.
    #
    # @raise AssertionError if the value is not nil and either does not respond
    #   to #empty? or value.empty returns false.
    def assert_blank(
      value,
      as:          'value',
      error_class: AssertionError,
      message:     nil
    )
      return if value.nil?
      return if value.respond_to?(:empty?) && value.empty?

      message ||= error_message_for(
        'sleeping_king_studios.tools.assertions.blank',
        as:
      )

      handle_error(error_class:, message:)
    end

    # Asserts that the value is either true or false.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param error_class [Class] the exception class to raise on a failure.
    # @param message [String] the exception message to raise on a failure.
    #
    # @raise AssertionError if the value is not a Class.
    def assert_boolean(
      value,
      as:          'value',
      error_class: AssertionError,
      message:     nil
    )
      return if value.equal?(true) || value.equal?(false)

      message ||= error_message_for(
        'sleeping_king_studios.tools.assertions.boolean',
        as:
      )

      handle_error(error_class:, message:)
    end

    # Asserts that the value is a Class.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param error_class [Class] the exception class to raise on a failure.
    # @param message [String] the exception message to raise on a failure.
    #
    # @raise AssertionError if the value is not a Class.
    def assert_class(
      value,
      as:          'value',
      error_class: AssertionError,
      message:     nil
    )
      return if value.is_a?(Class)

      message ||= error_message_for(
        'sleeping_king_studios.tools.assertions.class',
        as:
      )

      handle_error(error_class:, message:)
    end

    # Evaluates a series of assertions and combines all failures.
    #
    # @param error_class [Class] the exception class to raise on a failure.
    # @param message [String] the exception message to raise on a failure.
    #
    # @yield the assertions to evaluate.
    # @yieldparam [Aggregator] the aggregator object.
    #
    # @raise AssertionError if any of the assertions fail.
    def assert_group(error_class: AssertionError, message: nil, &assertions)
      raise ArgumentError, 'no block given' unless block_given?

      aggregator = aggregator_class.new

      assertions.call(aggregator)

      return if aggregator.empty?

      message ||= aggregator.failure_message

      handle_error(error_class:, message:)
    end
    alias aggregate assert_group

    # Asserts that the value is an example of the given Class.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param error_class [Class] the exception class to raise on a failure.
    # @param expected [Class] the expected class.
    # @param message [String] the exception message to raise on a failure.
    # @param optional [true, false] if true, allows nil values.
    #
    # @raise ArgumentError if the expected class is not a Class.
    # @raise AssertionError if the value is not an instance of the expected
    #   class.
    def assert_instance_of( # rubocop:disable Metrics/ParameterLists
      value,
      expected:,
      as:          'value',
      error_class: AssertionError,
      message:     nil,
      optional:    false
    )
      unless expected.is_a?(Class)
        raise ArgumentError, 'expected must be a Class'
      end

      return if optional && value.nil?
      return if value.is_a?(expected)

      message ||= error_message_for_instance_of(as:, expected:)

      handle_error(error_class:, message:)
    end

    # Asserts that the value matches the expected object using #===.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param error_class [Class] the exception class to raise on a failure.
    # @param expected [#===] the expected object.
    # @param message [String] the exception message to raise on a failure.
    # @param optional [true, false] if true, allows nil values.
    #
    # @raise AssertionError if the value does not match the expected object.
    def assert_matches( # rubocop:disable Metrics/ParameterLists
      value,
      expected:,
      as:          'value',
      error_class: AssertionError,
      message:     nil,
      optional:    false
    )
      return if optional && value.nil?
      return if expected === value # rubocop:disable Style/CaseEquality

      message ||= error_message_for_matches(as:, expected:)

      handle_error(error_class:, message:)
    end

    # Asserts that the value is a non-empty String or Symbol.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param error_class [Class] the exception class to raise on a failure.
    # @param message [String] the exception message to raise on a failure.
    # @param optional [true, false] if true, allows nil values.
    #
    # @raise AssertionError if the value is not a String or a Symbol, or if the
    #   value is empty.
    def assert_name( # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      value,
      as:          'value',
      error_class: AssertionError,
      message:     nil,
      optional:    false
    )
      if value.nil?
        return if optional

        message ||= error_message_for(
          'sleeping_king_studios.tools.assertions.presence',
          as:
        )

        return handle_error(error_class:, message:)
      end

      unless value.is_a?(String) || value.is_a?(Symbol)
        message ||= error_message_for(
          'sleeping_king_studios.tools.assertions.name',
          as:
        )

        return handle_error(error_class:, message:)
      end

      return unless value.empty?

      message ||= error_message_for(
        'sleeping_king_studios.tools.assertions.presence',
        as:
      )

      handle_error(error_class:, message:)
    end

    # Asserts that the value is not nil and not empty.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param error_class [Class] the exception class to raise on a failure.
    # @param message [String] the exception message to raise on a failure.
    #
    # @raise AssertionError if the value is nil, or if the value responds to
    #   #empty? and value.empty is true.
    def assert_presence(
      value,
      as:          'value',
      error_class: AssertionError,
      message: nil
    )
      if value.nil?
        message ||= "#{as} can't be blank"

        handle_error(error_class:, message:)
      end

      return unless value.respond_to?(:empty?) && value.empty?

      message ||= error_message_for(
        'sleeping_king_studios.tools.assertions.presence',
        as:
      )

      handle_error(error_class:, message:)
    end

    # Generates an error message for a failed validation.
    #
    # @param scope [String] the message scope.
    # @param options [Hash] additional options for generating the message.
    #
    # @option options as [String] the name of the validated property. Defaults
    #   to 'value'.
    # @option options expected [Object] the expected object, if any.
    #
    # @return [String] the generated error message.
    def error_message_for(scope, as: 'value', **options)
      message =
        ERROR_MESSAGES
        .fetch(scope.to_s) { return "Error message missing: #{scope}" }
        .then { |raw| format(raw, **options) }

      join_error_message(as:, message:)
    end

    # Asserts that the block returns a truthy value.
    #
    # @param message [String] the exception message to raise on a failure.
    #
    # @yield The block to evaluate.
    # @yieldreturn [Object] the returned value of the block.
    #
    # @raise ArgumentError if the block does not return a truthy value.
    def validate(message: nil, &block)
      assert(
        error_class: ArgumentError,
        message:,
        &block
      )
    end

    # Asserts that the value is either nil or empty.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param message [String] the exception message to raise on a failure.
    #
    # @raise ArgumentError if the value is not nil and either does not respond
    #   to #empty? or value.empty returns false.
    def validate_blank(value, as: 'value', message: nil)
      assert_blank(
        value,
        as:,
        error_class: ArgumentError,
        message:
      )
    end

    # Asserts that the value is either true or false.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param message [String] the exception message to raise on a failure.
    #
    # @raise ArgumentError if the value is not a Class.
    def validate_boolean(value, as: 'value', message: nil)
      assert_boolean(
        value,
        as:,
        error_class: ArgumentError,
        message:
      )
    end

    # Asserts that the value is a Class.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param message [String] the exception message to raise on a failure.
    #
    # @raise ArgumentError if the value is not a Class.
    def validate_class(value, as: 'value', message: nil)
      assert_class(
        value,
        as:,
        error_class: ArgumentError,
        message:
      )
    end

    # Evaluates a series of validations and combines all failures.
    #
    # @param message [String] the exception message to raise on a failure.
    #
    # @yield the validations to evaluate.
    # @yieldparam [Aggregator] the aggregator object.
    #
    # @raise ArgumentError if any of the validations fail.
    def validate_group(message: nil, &validations)
      assert_group(
        error_class: ArgumentError,
        message:,
        &validations
      )
    end

    # Asserts that the value is an example of the given Class.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param expected [Class] the expected class.
    # @param message [String] the exception message to raise on a failure.
    # @param optional [true, false] if true, allows nil values.
    #
    # @raise ArgumentError if the value is not an instance of the expected
    #   class.
    def validate_instance_of(
      value,
      expected:,
      as:       'value',
      message:  nil,
      optional: false
    )
      assert_instance_of(
        value,
        as:,
        error_class: ArgumentError,
        expected:,
        message:,
        optional:
      )
    end

    # Asserts that the value matches the expected object using #===.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param expected [#===] the expected object.
    # @param message [String] the exception message to raise on a failure.
    # @param optional [true, false] if true, allows nil values.
    #
    # @raise ArgumentError if the value does not match the expected object.
    def validate_matches(
      value,
      expected:,
      as:       'value',
      message:  nil,
      optional: false
    )
      assert_matches(
        value,
        as:,
        error_class: ArgumentError,
        expected:,
        message:,
        optional:
      )
    end

    # Asserts that the value is a non-empty String or Symbol.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param message [String] the exception message to raise on a failure.
    # @param optional [true, false] if true, allows nil values.
    #
    # @raise ArgumentError if the value is not a String or a Symbol, or if the
    #   value is empty.
    def validate_name(
      value,
      as:       'value',
      message:  nil,
      optional: false
    )
      assert_name(
        value,
        as:,
        error_class: ArgumentError,
        message:,
        optional:
      )
    end

    # Asserts that the value is not nil and not empty.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param message [String] the exception message to raise on a failure.
    #
    # @raise ArgumentError if the value is nil, or if the value responds to
    #   #empty? and value.empty is true.
    def validate_presence(value, as: 'value', message: nil)
      assert_presence(
        value,
        as:,
        error_class: ArgumentError,
        message:
      )
    end

    private

    def error_message_for_instance_of(expected:, **options) # rubocop:disable Metrics/MethodLength
      if expected.name
        return error_message_for(
          'sleeping_king_studios.tools.assertions.instance_of',
          expected:,
          **options
        )
      end

      error_message_for(
        'sleeping_king_studios.tools.assertions.instance_of_anonymous',
        expected:,
        parent:   expected.ancestors.find(&:name),
        **options
      )
    end

    def error_message_for_matches(expected:, **options) # rubocop:disable Metrics/MethodLength
      case expected
      when Module
        error_message_for_instance_of(expected:, **options)
      when Proc
        error_message_for(
          'sleeping_king_studios.tools.assertions.matches_proc',
          **options
        )
      when Regexp
        error_message_for(
          'sleeping_king_studios.tools.assertions.matches_regexp',
          pattern: expected.inspect,
          **options
        )
      else
        error_message_for(
          'sleeping_king_studios.tools.assertions.matches',
          **options
        )
      end
    end

    def handle_error(error_class:, message:)
      raise error_class, message, caller(2..)
    end

    def join_error_message(as:, message:)
      return message unless as

      "#{as} #{message}"
    end
  end
end
