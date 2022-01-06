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

    # Returns the number of digits in the given integer when represented in the
    # specified base. Ignores minus sign for negative numbers.
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
    #
    # @param [Integer] integer The integer to analyze.
    # @param [Integer] base The numeric base to represent the integer in.
    #   Defaults to 10.
    #
    # @return [Integer] The number of digits.
    def count_digits(integer, base: 10)
      digits(integer.abs, base: base).count
    end

    # Decomposes the given integer into its digits when represented in the
    # given base.
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
    #
    # @param [Integer] integer The integer to decompose.
    # @param [Integer] base The numeric base to represent the integer in.
    #   Defaults to 10.
    #
    # @return [Array<String>] The digits of the decomposed integer,
    #   represented as a bigendian array of strings.
    def digits(integer, base: 10)
      integer.to_s(base).chars
    end

    # Returns true if the object is an Integer.
    #
    # @param int [Object] The object to test.
    #
    # @return [Boolean] True if the object is an Integer, otherwise false.
    def integer?(int)
      int.is_a?(Integer)
    end

    # Returns the singular or the plural value, depending on the provided
    # item count.
    #
    # @example
    #   "There are four #{StringTools.pluralize 4, 'light', 'lights'}!"
    #   #=> 'There are four lights!'
    #
    # @param [Integer] count The number of items.
    # @param [String] single The singular form of the word or phrase.
    # @param [String] plural The plural form of the word or phrase.
    #
    # @return [String] The single form if count == 1; otherwise the plural
    #   form.
    def pluralize(count, single, plural = nil)
      plural ||= StringTools.pluralize(single)

      count == 1 ? single : plural
    end

    # Represents an integer between 1 and 4999 (inclusive) as a Roman numeral.
    #
    # @example
    #   IntegerTools.romanize(4) #=> 'IV'
    #
    # @example
    #   IntegerTools.romanize(18) #=> 'XVIII'
    #
    # @example
    #   IntegerTools.romanize(499) #=> 'CDXCIX'
    #
    # @param [Integer] integer The integer to convert.
    # @param [Boolean] additive If true, then uses only additive Roman numerals
    #   (e.g. four will be converted to IIII instead of IV, and nine will be
    #   converted to VIIII instead of IX). Defaults to false.
    #
    # @return [String] The representation of the integer as a Roman numeral.
    #
    # @raise [RangeError] If the integer is less than 1 or greater than 4999.
    def romanize(integer, additive: false)
      check_romanize_range(integer)

      digits(integer)
        .reverse
        .map
        .with_index do |digit, index|
          romanize_digit(additive: additive, digit: digit.to_i, tens: index)
        end
        .reverse
        .join
    end

    private

    def check_romanize_range(integer)
      return if (ROMANIZE_MIN..ROMANIZE_MAX).include?(integer)

      error_message =
        "integer to romanize must be within range #{ROMANIZE_MIN} to" \
        " #{ROMANIZE_MAX}"

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
