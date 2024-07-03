# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Methods for asserting on the state of a function or application.
  class Assertions < Base # rubocop:disable Metrics/ClassLength
    # Error class for handling a failed assertion.
    class AssertionError < StandardError; end

    # Asserts that the block returns a truthy value.
    #
    # @param error_class [Class] The exception class to raise on a failure.
    # @param message [String] The exception message to raise on a failure.
    #
    # @yield The block to evaluate.
    # @yieldreturn [Object] The returned value of the block.
    #
    # @raise AssertionError if the block does not return a truthy value.
    def assert(error_class: AssertionError, message: nil, &block)
      return if block.call

      raise error_class,
        message || 'block returned a falsy value',
        caller(1..-1)
    end

    # Asserts that the value is either true or false.
    #
    # @param value [Object] The value to assert on.
    # @param as [String] The name of the asserted value.
    # @param error_class [Class] The exception class to raise on a failure.
    # @param message [String] The exception message to raise on a failure.
    #
    # @raise AssertionError if the value is not a Class.
    def assert_boolean(
      value,
      as:          'value',
      error_class: AssertionError,
      message:     nil
    )
      return if value.equal?(true) || value.equal?(false)

      raise error_class,
        message || "#{as} must be true or false",
        caller(1..-1)
    end

    # Asserts that the value is a Class.
    #
    # @param value [Object] The value to assert on.
    # @param as [String] The name of the asserted value.
    # @param error_class [Class] The exception class to raise on a failure.
    # @param message [String] The exception message to raise on a failure.
    #
    # @raise AssertionError if the value is not a Class.
    def assert_class(
      value,
      as:          'value',
      error_class: AssertionError,
      message:     nil
    )
      return if value.is_a?(Class)

      raise error_class,
        message || "#{as} is not a Class",
        caller(1..-1)
    end

    # Asserts that the value is an example of the given Class.
    #
    # @param value [Object] The value to assert on.
    # @param as [String] The name of the asserted value.
    # @param error_class [Class] The exception class to raise on a failure.
    # @param expected [Class] The expected class.
    # @param message [String] The exception message to raise on a failure.
    # @param optional [true, false] If true, allows nil values.
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

      raise error_class,
        message || "#{as} is not an instance of #{class_name(expected)}",
        caller(1..-1)
    end

    # Asserts that the value matches the expected object using #===.
    #
    # @param value [Object] The value to assert on.
    # @param as [String] The name of the asserted value.
    # @param error_class [Class] The exception class to raise on a failure.
    # @param expected [#===] The expected object.
    # @param message [String] The exception message to raise on a failure.
    # @param optional [true, false] If true, allows nil values.
    #
    # @raise AssertionError if the value does not match the expected object.
    def assert_matches( # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/ParameterLists
      value,
      expected:,
      as:          'value',
      error_class: AssertionError,
      message:     nil,
      optional:    false
    )
      return if optional && value.nil?
      return if expected === value # rubocop:disable Style/CaseEquality

      message ||=
        case expected
        when Module
          "#{as} is not an instance of #{class_name(expected)}"
        when Proc
          "#{as} does not match the Proc"
        when Regexp
          "#{as} does not match the pattern #{expected.inspect}"
        else
          "#{as} does not match the expected value"
        end

      raise error_class, message, caller(1..-1)
    end

    # Asserts that the value is a non-empty String or Symbol.
    #
    # @param value [Object] The value to assert on.
    # @param as [String] The name of the asserted value.
    # @param error_class [Class] The exception class to raise on a failure.
    # @param message [String] The exception message to raise on a failure.
    # @param optional [true, false] If true, allows nil values.
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

        raise error_class, message || "#{as} can't be blank", caller(1..-1)
      end

      unless value.is_a?(String) || value.is_a?(Symbol)
        raise error_class,
          message || "#{as} is not a String or a Symbol",
          caller(1..-1)
      end

      return unless value.empty?

      raise error_class, message || "#{as} can't be blank", caller(1..-1)
    end

    # Asserts that the block returns a truthy value.
    #
    # @param message [String] The exception message to raise on a failure.
    #
    # @yield The block to evaluate.
    # @yieldreturn [Object] The returned value of the block.
    #
    # @raise ArgumentError if the block does not return a truthy value.
    def validate(message: nil, &block)
      assert(
        error_class: ArgumentError,
        message:     message,
        &block
      )
    end

    # Asserts that the value is either true or false.
    #
    # @param value [Object] The value to assert on.
    # @param as [String] The name of the asserted value.
    # @param message [String] The exception message to raise on a failure.
    #
    # @raise AssertionError if the value is not a Class.
    def validate_boolean(value, as: 'value', message: nil)
      assert_boolean(
        value,
        as:          as,
        error_class: ArgumentError,
        message:     message
      )
    end

    # Asserts that the value is a Class.
    #
    # @param value [Object] The value to assert on.
    # @param as [String] The name of the asserted value.
    # @param message [String] The exception message to raise on a failure.
    #
    # @raise ArgumentError if the value is not a Class.
    def validate_class(value, as: 'value', message: nil)
      assert_class(
        value,
        as:          as,
        error_class: ArgumentError,
        message:     message
      )
    end

    # Asserts that the value is an example of the given Class.
    #
    # @param value [Object] The value to assert on.
    # @param as [String] The name of the asserted value.
    # @param expected [Class] The expected class.
    # @param message [String] The exception message to raise on a failure.
    # @param optional [true, false] If true, allows nil values.
    #
    # @raise ArgumentError if the expected class is not a Class.
    # @raise AssertionError if the value is not an instance of the expected
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
        as:          as,
        error_class: ArgumentError,
        expected:    expected,
        message:     message,
        optional:    optional
      )
    end

    # Asserts that the value matches the expected object using #===.
    #
    # @param value [Object] The value to assert on.
    # @param as [String] The name of the asserted value.
    # @param expected [#===] The expected object.
    # @param message [String] The exception message to raise on a failure.
    # @param optional [true, false] If true, allows nil values.
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
        as:          as,
        error_class: ArgumentError,
        expected:    expected,
        message:     message,
        optional:    optional
      )
    end

    # Asserts that the value is a non-empty String or Symbol.
    #
    # @param value [Object] The value to assert on.
    # @param as [String] The name of the asserted value.
    # @param message [String] The exception message to raise on a failure.
    # @param optional [true, false] If true, allows nil values.
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
        as:          as,
        error_class: ArgumentError,
        message:     message,
        optional:    optional
      )
    end

    private

    def class_name(expected)
      return expected.name if expected.name

      "#{expected.inspect} (#{expected.ancestors.find(&:name).name})"
    end
  end
end
