# lib/sleeping_king_studios/tools/array_tools.rb

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Tools for working with arrays and lists.
  module ArrayTools
    extend self

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
