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
        'nil' =>
          'must be nil',
        'not_nil' =>
          'must not be nil',
        # @note: This value will be changed in a future version.
        'presence' =>
          "can't be blank"
      }
      .transform_keys { |key| "sleeping_king_studios.tools.assertions.#{key}" }
      .freeze
    private_constant :ERROR_MESSAGES
    # rubocop:enable Layout/HashAlignment

    # Utility for grouping multiple assertion statements.
    #
    # @example
    #   rocket = Struct.new(:fuel, :launched).new(0.0, true)
    #   aggregator = SleepingKingStudios::Tools::Assertions::Aggregator.new
    #   aggregator.empty?
    #   #=> true
    #
    #   aggregator.assert(message: 'is out of fuel') { rocket.fuel > 0 }
    #   aggregator.assert(message: 'has already launched') { !rocket.launched }
    #   aggregator.empty?
    #   #=> false
    #   aggregator.failure_message
    #   #=> 'is out of fuel, has already launched'
    class Aggregator < Assertions
      extend Forwardable

      def initialize
        super

        @failures = []
      end

      # @!method <<(message)
      #   Appends the message to the failure messages.
      #
      #   @param message [String] the message to append.
      #
      #   @return [Array] the updated failure messages.
      #
      #   @see Array#<<.

      # @!method clear
      #   Removes all items from the failure messages.
      #
      #   @return [Array] the empty failure messages.
      #
      #   @see Array#clear.

      # @!method count
      #   Returns a count of the failure message.
      #
      #   @return [Integer] the number of failure messages.
      #
      #   @see Array#count.

      # @!method each
      #   Iterates over the failure messages.
      #
      #   @overload each
      #     Returns an enumerator that iterates over the failure messages.
      #
      #     @return [Enumerator] an enumerator over the messages.
      #
      #     @see Enumerable#each.
      #
      #   @overload each(&block)
      #     Yields each failure message to the block.
      #
      #     @yieldparam message [String] the current failure message.
      #
      #     @see Enumerable#each.

      # @!method empty?
      #   Checks if there are any failure messages.
      #
      #   @return [true, false] true if there are no failure messages; otherwise
      #     false.
      #
      #   @see Enumerable#empty?

      # @!method size
      #   Returns a count of the failure message.
      #
      #   @return [Integer] the number of failure messages.
      #
      #   @see Array#size.
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

      # Generates a combined failure message from the configured messages.
      #
      # @return [String] the combined messages for each failed assertion.
      #
      # @example With an empty aggregator.
      #   aggregator = SleepingKingStudios::Tools::Assertions::Aggregator.new
      #
      #   aggregator.failure_message
      #   #=> ''
      #
      # @example With an aggregator with failure messages.
      #   aggregator = SleepingKingStudios::Tools::Assertions::Aggregator.new
      #   aggrgator << 'rocket is out of fuel'
      #   aggrgator << 'rocket is not pointed toward space'
      #
      #   aggregator.failure_message
      #   #=> 'rocket is out of fuel, rocket is not pointed toward space'
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
    # @yield the block to evaluate.
    # @yieldreturn [Object] the returned value of the block.
    #
    # @return [void]
    #
    # @raise [AssertionError] if the block does not return a truthy value.
    #
    # @example
    #   Assertions.assert { true == false }
    #   #=> raises an AssertionError with message 'block returned a falsy value'
    #
    #   Assertions.assert { true == true }
    #   #=> does not raise an exception
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
    # @return [void]
    #
    # @raise [AssertionError] if the value is not nil and either does not respond
    #   to #empty? or value.empty returns false.
    #
    # @example
    #   Assertions.assert_blank(nil)
    #   #=> does not raise an exception
    #
    #   Assertions.assert_blank(Object.new)
    #   #=> raises an AssertionError with message 'value must be nil or empty'
    #
    #   Assertions.assert_blank([])
    #   #=> does not raise an exception
    #
    #   Assertions.assert_blank([1, 2, 3])
    #   #=> raises an AssertionError with message 'value must be nil or empty'
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
    # @param optional [true, false] if true, allows nil values.
    #
    # @return [void]
    #
    # @raise [AssertionError] if the value is not true or false.
    #
    # @example
    #   Assertions.assert_boolean(nil)
    #   #=> raises an AssertionError with message 'value must be true or false'
    #
    #   Assertions.assert_boolean(Object.new)
    #   #=> raises an AssertionError with message 'value must be true or false'
    #
    #   Assertions.assert_boolean(false)
    #   #=> does not raise an exception
    #
    #   Assertions.assert_boolean(true)
    #   #=> does not raise an exception
    def assert_boolean(
      value,
      as:          'value',
      error_class: AssertionError,
      message:     nil,
      optional:    false
    )
      return if optional && value.nil?

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
    # @param optional [true, false] if true, allows nil values.
    #
    # @return [void]
    #
    # @raise [AssertionError] if the value is not a Class.
    #
    # @example
    #   Assertions.assert_class(Object.new)
    #   #=> raises an AssertionError with message 'value is not a class'
    #
    #   Assertions.assert_class(String)
    #   #=> does not raise an exception
    def assert_class(
      value,
      as:          'value',
      error_class: AssertionError,
      message:     nil,
      optional:    false
    )
      return if optional && value.nil?

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
    # @yieldparam aggregator [Aggregator] the aggregator object.
    #
    # @return [void]
    #
    # @raise [AssertionError] if any of the assertions fail.
    #
    # @example
    #   Assertions.assert_group do |group|
    #     group.assert_name(nil, as: 'label')
    #     group.assert_instance_of(0.0, expected: Integer, as: 'quantity')
    #   end
    #   # raises an AssertionError with message: "label can't be blank, quantity is not an instance of Integer"
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
    # @return [void]
    #
    # @raise [ArgumentError] if the expected class is not a Class.
    # @raise [AssertionError] if the value is not an instance of the expected
    #   class.
    #
    # @example
    #   Assertions.assert_instance_of(:foo, expected: String)
    #   #=> raises an AssertionError with message 'value is not an instance of String'
    #
    #   Assertions.assert_instance_of('foo', expected: String)
    #   #=> does not raise an exception
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
    # @return [void]
    #
    # @raise [AssertionError] if the value does not match the expected object.
    #
    # @example
    #   Assertions.assert_matches('bar', expected: /foo/)
    #   #=> raises an AssertionError with message 'value does not match the pattern /foo/'
    #
    #   Assertions.assert_matches('foo', expected: /foo/)
    #   #=> does not raise an exception
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
    # @return [void]
    #
    # @raise [AssertionError] if the value is not a String or a Symbol, or if
    #   the value is empty.
    #
    # @example
    #   Assertions.assert_name(nil)
    #   #=> raises an AssertionError with message "value can't be blank"
    #
    #   Assertions.assert_name(Object.new)
    #   #=> raises an AssertionError with message 'value is not a String or a Symbol'
    #
    #   Assertions.assert_name('')
    #   #=> raises an AssertionError with message "value can't be blank"
    #
    #   Assertions.assert_name('foo')
    #   #=> does not raise an exception
    #
    #   Assertions.assert_name(:bar)
    #   #=> does not raise an exception
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

    # Asserts that the value is nil.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param error_class [Class] the exception class to raise on a failure.
    # @param message [String] the exception message to raise on a failure.
    #
    # @return [void]
    #
    # @raise [AssertionError] if the value is not nil.
    #
    # @example
    #   Assertions.assert_nil(nil)
    #   #=> does not raise an exception
    #
    #   Assertions.assert_nil(Object.new)
    #   #=> raises an AssertionError with message 'value must be nil'
    def assert_nil(
      value,
      as:          'value',
      error_class: AssertionError,
      message:     nil
    )
      return if value.nil?

      message ||= error_message_for(
        'sleeping_king_studios.tools.assertions.nil',
        as:
      )

      handle_error(error_class:, message:)
    end

    # Asserts that the value is not nil.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param error_class [Class] the exception class to raise on a failure.
    # @param message [String] the exception message to raise on a failure.
    #
    # @return [void]
    #
    # @raise [AssertionError] if the value is nil.
    #
    # @example
    #   Assertions.assert_not_nil(nil)
    #   #=> raises an AssertionError with message 'value must not be nil'
    #
    #   Assertions.assert_not_nil(Object.new)
    #   #=> does not raise an exception
    def assert_not_nil(
      value,
      as:          'value',
      error_class: AssertionError,
      message:     nil
    )
      return unless value.nil?

      message ||= error_message_for(
        'sleeping_king_studios.tools.assertions.not_nil',
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
    # @param optional [true, false] if true, allows nil values.
    #
    # @return [void]
    #
    # @raise [AssertionError] if the value is nil, or if the value responds to
    #   #empty? and value.empty is true.
    #
    # @example
    #   Assertions.assert_presence(nil)
    #   #=> raises an AssertionError with message "can't be blank"
    #
    #   Assertions.assert_presence(Object.new)
    #   #=> does not raise an exception
    #
    #   Assertions.assert_presence([])
    #   #=> raises an AssertionError with message "can't be blank"
    #
    #   Assertions.assert_presence([1, 2, 3])
    #   #=> does not raise an exception
    def assert_presence( # rubocop:disable Metrics/MethodLength
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
    #
    # @example
    #   scope = 'sleeping_king_studios.tools.assertions.blank'
    #
    #   assertions.error_message_for(scope)
    #   #=> 'value must be nil or empty'
    #   assertions.error_message_for(scope, as: false)
    #   #=> 'must be nil or empty'
    #   assertions.error_message_for(scope, as: 'item')
    #   #=> 'item must be nil or empty'
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
    # @return [void]
    #
    # @raise [ArgumentError] if the block does not return a truthy value.
    #
    # @example
    #   Assertions.validate { true == false }
    #   #=> raises an ArgumentError with message 'block returned a falsy value'
    #
    #   Assertions.validate { true == true }
    #   #=> does not raise an exception
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
    # @return [void]
    #
    # @raise [ArgumentError] if the value is not nil and either does not respond
    #   to #empty? or value.empty returns false.
    #
    # @example
    #   Assertions.validate_blank(nil)
    #   #=> does not raise an exception
    #
    #   Assertions.validate_blank(Object.new)
    #   #=> raises an ArgumentError with message 'value must be nil or empty'
    #
    #   Assertions.validate_blank([])
    #   #=> does not raise an exception
    #
    #   Assertions.validate_blank([1, 2, 3])
    #   #=> raises an ArgumentError with message 'value must be nil or empty'
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
    # @param optional [true, false] if true, allows nil values.
    #
    # @return [void]
    #
    # @raise [ArgumentError] if the value is not true or false.
    #
    # @example
    #   Assertions.validate_boolean(nil)
    #   #=> raises an ArgumentError with message 'value must be true or false'
    #
    #   Assertions.validate_boolean(Object.new)
    #   #=> raises an ArgumentError with message 'value must be true or false'
    #
    #   Assertions.validate_boolean(false)
    #   #=> does not raise an exception
    #
    #   Assertions.validate_boolean(true)
    #   #=> does not raise an exception
    def validate_boolean(value, as: 'value', message: nil, optional: false)
      assert_boolean(
        value,
        as:,
        error_class: ArgumentError,
        message:,
        optional:
      )
    end

    # Asserts that the value is a Class.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param message [String] the exception message to raise on a failure.
    # @param optional [true, false] if true, allows nil values.
    #
    # @return [void]
    #
    # @raise [ArgumentError] if the value is not a Class.
    #
    # @example
    #   Assertions.validate_class(Object.new)
    #   #=> raises an ArgumentError with message 'value is not a class'
    #
    #   Assertions.validate_class(String)
    #   #=> does not raise an exception
    def validate_class(value, as: 'value', message: nil, optional: false)
      assert_class(
        value,
        as:,
        error_class: ArgumentError,
        message:,
        optional:
      )
    end

    # Evaluates a series of validations and combines all failures.
    #
    # @param message [String] the exception message to raise on a failure.
    #
    # @yield the validations to evaluate.
    # @yieldparam aggregator [Aggregator] the aggregator object.
    #
    # @return [void]
    #
    # @raise [ArgumentError] if any of the validations fail.
    #
    # @example
    #   Assertions.validate_group do |group|
    #     group.validate_name(nil, as: 'label')
    #     group.validate_instance_of(0.0, expected: Integer, as: 'quantity')
    #   end
    #   # raises an ArgumentError with message: "label can't be blank, quantity is not an instance of Integer"
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
    # @return [void]
    #
    # @raise [ArgumentError] if the value is not an instance of the expected
    #   class.
    #
    # @example
    #   Assertions.validate_instance_of(:foo, expected: String)
    #   #=> raises an AssertionError with message 'value is not an instance of String'
    #
    #   Assertions.validate_instance_of('foo', expected: String)
    #   #=> does not raise an exception
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
    # @return [void]
    #
    # @raise [ArgumentError] if the value does not match the expected object.
    #
    # @example
    #   Assertions.validate_matches('bar', expected: /foo/)
    #   #=> raises an ArgumentError with message 'value does not match the pattern /foo/'
    #
    #   Assertions.validate_matches('foo', expected: /foo/)
    #   #=> does not raise an exception
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
    # @return [void]
    #
    # @raise [ArgumentError] if the value is not a String or a Symbol, or if the
    #   value is empty.
    #
    # @example
    #   Assertions.validate_name(nil)
    #   #=> raises an ArgumentError with message "value can't be blank"
    #
    #   Assertions.validate_name(Object.new)
    #   #=> raises an AssertionError with message 'value is not a String or a Symbol'
    #
    #   Assertions.validate_name('')
    #   #=> raises an ArgumentError with message "value can't be blank"
    #
    #   Assertions.validate_name('foo')
    #   #=> does not raise an exception
    #
    #   Assertions.validate_name(:bar)
    #   #=> does not raise an exception
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

    # Asserts that the value is nil.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param message [String] the exception message to raise on a failure.
    #
    # @return [void]
    #
    # @raise [ArgumentError] if the value is not nil.
    #
    # @example
    #   Assertions.validate_nil(nil)
    #   #=> does not raise an exception
    #
    #   Assertions.validate_nil(Object.new)
    #   #=> raises an ArgumentError with message 'value must be nil'
    def validate_nil(
      value,
      as:      'value',
      message: nil
    )
      assert_nil(
        value,
        as:,
        error_class: ArgumentError,
        message:
      )
    end

    # Asserts that the value is not nil.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param message [String] the exception message to raise on a failure.
    #
    # @return [void]
    #
    # @raise [ArgumentError] if the value is nil.
    #
    # @example
    #   Assertions.validate_not_nil(nil)
    #   #=> raises an ArgumentError with message 'value must not be nil'
    #
    #   Assertions.validate_not_nil(Object.new)
    #   #=> does not raise an exception
    def validate_not_nil(
      value,
      as:      'value',
      message: nil
    )
      assert_not_nil(
        value,
        as:,
        error_class: ArgumentError,
        message:
      )
    end

    # Asserts that the value is not nil and not empty.
    #
    # @param value [Object] the value to assert on.
    # @param as [String] the name of the asserted value.
    # @param message [String] the exception message to raise on a failure.
    # @param optional [true, false] if true, allows nil values.
    #
    # @return [void]
    #
    # @raise [ArgumentError] if the value is nil, or if the value responds to
    #   #empty? and value.empty is true.
    #
    # @example
    #   Assertions.validate_presence(nil)
    #   #=> raises an ArgumentError with message "can't be blank"
    #
    #   Assertions.validate_presence(Object.new)
    #   #=> does not raise an exception
    #
    #   Assertions.validate_presence([])
    #   #=> raises an ArgumentError with message "can't be blank"
    #
    #   Assertions.validate_presence([1, 2, 3])
    #   #=> does not raise an exception
    def validate_presence(value, as: 'value', message: nil, optional: false)
      assert_presence(
        value,
        as:,
        error_class: ArgumentError,
        message:,
        optional:
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
