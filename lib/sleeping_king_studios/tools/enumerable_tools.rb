# lib/sleeping_king_studios/tools/enumerable_tools.rb

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Tools for working with enumerable objects, such as arrays and hashes.
  module EnumerableTools
    extend self

    # @overload count_values(values)
    #   Counts the number of times each value appears in the enumerable object.
    #
    #   @example
    #     ArrayTools.count_values([1, 1, 1, 2, 2, 3])
    #     #=> { 1 => 3, 2 => 2, 3 => 1 }
    #
    #   @param [Array<Object>] values The values to count.
    #
    #   @return [Hash{Object, Integer}] The number of times each value appears
    #     in the enumerable object.
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
    #   @return [Hash{Object, Integer}] The number of times each result
    #     appears.
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
    # @example With Three Or More Items And Options
    #   ArrayTools.humanize_list(['spam', 'eggs', 'bacon', 'spam'], :last_separator => ' or ')
    #   #=> 'spam, eggs, bacon, or spam'
    #
    # @param [Array<String>] values The list of values to format. Will be
    #   coerced to strings using #to_s.
    # @param [Hash] options Optional configuration hash.
    # @option options [String] :last_separator The value to use to separate
    #   the final pair of values. Defaults to " and " (note the leading and
    #   trailing spaces). Will be combined with the :separator for lists of
    #   length 3 or greater.
    # @option options [String] :separator The value to use to separate pairs
    #   of values before the last in lists of length 3 or greater. Defaults to
    #   ", " (note the trailing space).
    #
    # @return [String] The formatted string.
    def humanize_list values, options = {}
      separator = options.fetch(:separator, ', ')
      last_separator = options.fetch(:last_separator, ' and ')

      case values.count
      when 0
        ''
      when 1
        values.first.to_s
      when 2
        "#{values[0]}#{last_separator}#{values[1]}"
      else
        if last_separator =~ /\A,?\s*/
          last_separator = last_separator.sub /\A,?\s*/, separator
        else
          last_separator = "#{separator}#{last_separator}"
        end # if-else

        "#{values[0...-1].join(separator)}#{last_separator}#{values.last}"
      end # case
    end # method humanize_list
  end # module
end # module
