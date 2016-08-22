# lib/sleeping_king_studios/tools/integer_tools.rb

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Tools for working with integers and fixnums.
  module IntegerTools
    extend self

    # Minimum integer value that can be converted to a roman numeral.
    ROMANIZE_MIN = 1

    # Maximum integer value that can be converted to a roman numeral.
    ROMANIZE_MAX = 4999

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
    def count_digits integer, base: 10
      digits(integer.abs, :base => base).count
    end # method count_digits

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
    def digits integer, base: 10
      integer.to_s(base).split('')
    end # method digits

    # Returns true if the object is an Integer.
    #
    # @param int [Object] The object to test.
    #
    # @return [Boolean] True if the object is an Integer, otherwise false.
    def integer? int
      Integer === int
    end # method array?

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
    def pluralize count, single, plural
      1 == count ? single : plural
    end # method pluralize

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
    def romanize integer, additive: false
      # Validate input value.
      unless (ROMANIZE_MIN..ROMANIZE_MAX).include? integer
        raise RangeError.new "integer to romanize must be within range #{ROMANIZE_MIN} to #{ROMANIZE_MAX}"
      end # unless

      # Define conversion rules.
      rules = [
        '',
        '%one',
        '%one%one',
        '%one%one%one',
        additive ? '%one%one%one%one' : '%one%five',
        '%five',
        '%five%one',
        '%five%one%one',
        '%five%one%one%one',
        additive ? '%five%one%one%one%one' : '%one%ten',
        '%ten'
      ] # end array

      # Define numeral values.
      numerals = [
        %w(I V X),
        %w(X L C),
        %w(C D M),
        ['M', 'MMM', '']
      ] # end array numerals

      # Generate string representation.
      digits(integer).reverse.map.with_index do |digit, index|
        rules[digit.to_i]
          .gsub('%one',  numerals[index][0])
          .gsub('%five', numerals[index][1])
          .gsub('%ten',  numerals[index][2])
      end.reverse.join ''
    end # method romanize
  end # module
end # module
