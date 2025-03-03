# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Tools for working with integers.
  class IntegerTools < SleepingKingStudios::Tools::Base
    # Minimum integer value that can be converted to a roman numeral.
    ROMANIZE_MIN = 1

    # Maximum integer value that can be converted to a roman numeral.
    ROMANIZE_MAX = 4999

    ROMANIZE_NUMERALS = [
      %w[I V X].freeze,
      %w[X L C].freeze,
      %w[C D M].freeze,
      ['M', 'MMM', ''].freeze
    ].freeze
    private_constant :ROMANIZE_NUMERALS

    ROMANIZE_RULES = [
      '',
      '1',
      '11',
      '111',
      '15',
      '5',
      '51',
      '511',
      '5111',
      '1a',
      'a'
    ].freeze
    private_constant :ROMANIZE_RULES

    ROMANIZE_RULES_ADDITIVE = [
      '',
      '1',
      '11',
      '111',
      '1111',
      '5',
      '51',
      '511',
      '5111',
      '51111',
      'a'
    ].freeze
    private_constant :ROMANIZE_RULES_ADDITIVE

    class << self
      def_delegators :instance,
        :count_digits,
        :digits,
        :integer?,
        :pluralize,
        :romanize
    end

    # Returns the number of digits in the given integer and base.
    #
    # This method ignores minus sign for negative numbers. You can use the :base
    # parameter to configure the numeric base for the string representation.
    #
    # @param integer [Integer] the integer to analyze.
    # @param base [Integer] the numeric base to represent the integer in.
    #   Defaults to 10.
    #
    # @return [Integer] the number of digits.
    #
    # @example With a positive number.
    #   IntegerTools.count_digits(31)
    #   #=> 2
    #
    # @example With a negative number.
    #   IntegerTools.count_digits(-141)
    #   #=> 3
    #
    # @example With a binary number.
    #   IntegerTools.count_digits(189, :base => 2)
    #   #=> 8
    #
    # @example With a hexadecimal number.
    #   IntegerTools.count_digits(16724838, :base => 16)
    #   #=> 6
    def count_digits(integer, base: 10)
      digits(integer.abs, base:).count
    end

    # Decomposes the given integer into its digits in the given base.
    #
    # @param integer [Integer] the integer to decompose.
    # @param base [Integer] the numeric base to represent the integer in.
    #   Defaults to 10.
    #
    # @return [Array<String>] the digits of the decomposed integer,
    #   represented as a bigendian array of strings.
    #
    # @example With a number in base 10.
    #   IntegerTools.digits(15926)
    #   #=> ['1', '5', '9', '2', '6']
    #
    # @example With a binary number.
    #   IntegerTools.digits(189, :base => 2)
    #   #=> ['1', '0', '1', '1', '1', '1', '0', '1']
    #
    # @example With a hexadecimal number.
    #   IntegerTools.digits(16724838)
    #   #=> ['f', 'f', '3', '3', '6', '6']
    def digits(integer, base: 10)
      integer.to_s(base).chars
    end

    # Returns true if the object is an Integer.
    #
    # @param int [Object] the object to test.
    #
    # @return [Boolean] true if the object is an Integer, otherwise false.
    #
    # @example
    #   IntegerTools.integer?(nil)
    #   #=> false
    #   IntegerTools.integer?([])
    #   #=> false
    #   IntegerTools.integer?({})
    #   #=> false
    #   IntegerTools.integer?(1)
    #   #=> true
    def integer?(int)
      int.is_a?(Integer)
    end

    # Returns the singular or the plural value, depending on the provided count.
    #
    # If the plural form is not given, passes the singular form to
    # StringTools#pluralize.
    #
    # @param count [Integer] the number of items.
    # @param single [String] the singular form of the word or phrase.
    # @param plural [String] the plural form of the word or phrase.
    #
    # @return [String] The single form if count == 1; otherwise the plural
    #   form.
    #
    # @example
    #   IntegerTools.pluralize 4, 'light'
    #   #=> 'lights'
    #
    #   IntegerTools.pluralize 3, 'cow', 'kine'
    #   #=> 'kine'
    def pluralize(count, single, plural = nil)
      plural ||= StringTools.pluralize(single)

      count == 1 ? single : plural
    end

    # Represents an integer between 1 and 4999 (inclusive) as a Roman numeral.
    #
    # @param integer [Integer] the integer to convert.
    # @param additive [Boolean] if true, then uses only additive Roman numerals
    #   (e.g. four will be converted to IIII instead of IV, and nine will be
    #   converted to VIIII instead of IX). Defaults to false.
    #
    # @return [String] the representation of the integer as a Roman numeral.
    #
    # @raise [RangeError] if the integer is less than 1 or greater than 4999.
    #
    # @example
    #   IntegerTools.romanize(4) #=> 'IV'
    #
    # @example
    #   IntegerTools.romanize(18) #=> 'XVIII'
    #
    # @example
    #   IntegerTools.romanize(499) #=> 'CDXCIX'
    def romanize(integer, additive: false)
      check_romanize_range(integer)

      digits(integer)
        .reverse
        .map
        .with_index do |digit, index|
          romanize_digit(additive:, digit: digit.to_i, tens: index)
        end
        .reverse
        .join
    end

    private

    def check_romanize_range(integer)
      return if (ROMANIZE_MIN..ROMANIZE_MAX).include?(integer)

      error_message =
        "integer to romanize must be within range #{ROMANIZE_MIN} to " \
        "#{ROMANIZE_MAX}"

      raise RangeError, error_message, caller(1..-1)
    end

    def romanize_digit(additive:, digit:, tens:)
      rules    = (additive ? ROMANIZE_RULES_ADDITIVE : ROMANIZE_RULES)
      rule     = rules[digit]
      numerals = ROMANIZE_NUMERALS[tens]

      rule
        .gsub('1', numerals[0])
        .gsub('5', numerals[1])
        .gsub('a', numerals[2])
    end
  end
end
