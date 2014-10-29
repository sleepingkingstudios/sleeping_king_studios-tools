# lib/sleeping_king_studios/tools/integer_tools.rb

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Tools for working with integers and fixnums.
  module IntegerTools
    extend self

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
    # @param [Integer] The integer to decompose.
    # @param [Integer] base The numeric base to represent the integer in.
    #   Defaults to 10.
    #
    # @return [Array<String>] The digits of the decomposed integer,
    #   represented as a bigendian array of strings.
    def digits integer, base: 10
      integer.to_s(base).split('')
    end # method digits
  end # module
end # module
