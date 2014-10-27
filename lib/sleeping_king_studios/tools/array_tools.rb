# lib/sleeping_king_studios/tools/array_tools.rb

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Tools for working with arrays and lists.
  module ArrayTools
    extend self

    # @overload count_values(values)
    #   Counts the number of times each value appears in the array.
    #
    #   @example
    #     ArrayTools.count_values([1, 1, 1, 2, 2, 3])
    #     #=> { 1 => 3, 2 => 2, 3 => 1 }
    #
    #   @param [Array<Object>] values The values to count.
    #
    #   @return [Hash{Object, Integer}] The number of times each value appears
    #     in the array.
    #
    # @overload count_values(values, &block)
    #   Calls the block with each item and counts the number of times each
    #   result appears.
    #
    #   @example
    #     ArrayTools.count_values([1, 1, 1, 2, 2, 3]) { |i| i ** 2 }
    #     #=> { 1 => 3, 4 => 2, 9 => 1 }
    #
    #   @param [Array<Object>] values The values to count.
    #
    #   @return [Hash{Object, Integer}] The number of times each result appears
    #     in the array.
    #
    #   @yield item An item in the array to be converted to a countable result.
    def count_values values, &block
      values.each.with_object({}) do |item, hsh|
        value = block_given? ? block.call(item) : item
        hsh[value] = hsh.fetch(value, 0) + 1
      end # each
    end # method count_values

    # Accepts a list of values and returns a human-readable string of the
    # values, with the format based on the number of items.
    #
    # @example With Zero Items
    #   ArrayTools.humanize_list([])
    #   #=> ''
    #
    # @example With One Item
    #   ArrayTools.humanize_list(['spam'])
    #   #=> 'spam'
    #
    # @example With Two Items
    #   ArrayTools.humanize_list(['spam', 'eggs'])
    #   #=> 'spam and eggs'
    #
    # @example With Three Or More Items
    #   ArrayTools.humanize_list(['spam', 'eggs', 'bacon', 'spam'])
    #   #=> 'spam, eggs, bacon, and spam'
    #
    # @param [Array<String>] values The list of values to format. Will be
    #   coerced to strings using #to_s.
    #
    # @return [String] The formatted string.
    def humanize_list values
      case values.count
      when 0
        ''
      when 1
        values.first.to_s
      when 2
        "#{values.first} and #{values.last}"
      else
        "#{values[0...-1].join(', ')}, and #{values.last}"
      end # case
    end # method humanize_list
  end # module
end # module
