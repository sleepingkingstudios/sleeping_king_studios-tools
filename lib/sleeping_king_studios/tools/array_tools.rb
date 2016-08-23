# lib/sleeping_king_studios/tools/array_tools.rb

require 'sleeping_king_studios/tools'
require 'sleeping_king_studios/tools/object_tools'

module SleepingKingStudios::Tools
  # Tools for working with array-like enumerable objects.
  module ArrayTools
    extend self

    ARRAY_METHODS = [:[], :count, :each].freeze
    OTHER_METHODS = [:each_key, :each_pair].freeze

    # Returns true if the object is or appears to be an Array.
    #
    # @param ary [Object] The object to test.
    #
    # @return [Boolean] True if the object is an Array, otherwise false.
    def array? ary
      return true if Array === ary

      ARRAY_METHODS.each do |method_name|
        return false unless ary.respond_to?(method_name)
      end # each

      OTHER_METHODS.each do |method_name|
        return false if ary.respond_to?(method_name)
      end # each

      true
    end # method array?

    # Separates the array into two arrays, the first containing all items in the
    # original array that matches the provided block, and the second containing
    # all items in the original array that do not match the provided block.
    #
    # @example
    #   selected, rejected = ArrayTools.bisect([*0...10]) { |item| item.even? }
    #   selected
    #   #=> [0, 2, 4, 6, 8]
    #   rejected
    #   #=> [1, 3, 5, 7, 9]
    #
    # @param [Array<Object>] ary The array to bisect.
    #
    # @yieldparam item [Object] An item in the array to matched.
    #
    # @yieldreturn [Boolean] True if the item matches the criteria, otherwise
    #   false.
    #
    # @raise ArgumentError If the first argument is not an Array-like object or
    #   if no block is given.
    #
    # @return [Array<Array<Object>>] An array containing two arrays.
    def bisect ary, &block
      require_array! ary

      raise ArgumentError.new('no block given') unless block_given?

      selected, rejected = [], []

      ary.each do |item|
        (yield(item) ? selected : rejected) << item
      end # each

      [selected, rejected]
    end # method bisect

    # @overload count_values(ary)
    #   Counts the number of times each value appears in the enumerable object.
    #
    #   @example
    #     ArrayTools.count_values([1, 1, 1, 2, 2, 3])
    #     #=> { 1 => 3, 2 => 2, 3 => 1 }
    #
    #   @param [Array<Object>] ary The values to count.
    #
    #   @raise ArgumentError If the first argument is not an Array-like object.
    #
    #   @return [Hash{Object, Integer}] The number of times each value appears
    #     in the enumerable object.
    #
    # @overload count_values(ary, &block)
    #   Calls the block with each item and counts the number of times each
    #   result appears.
    #
    #   @example
    #     ArrayTools.count_values([1, 1, 1, 2, 2, 3]) { |i| i ** 2 }
    #     #=> { 1 => 3, 4 => 2, 9 => 1 }
    #
    #   @param [Array<Object>] ary The values to count.
    #
    #   @yieldparam item [Object] An item in the array to matched.
    #
    #   @raise ArgumentError If the first argument is not an Array-like object.
    #
    #   @return [Hash{Object, Integer}] The number of times each result
    #     appears.
    def count_values ary, &block
      require_array! ary

      ary.each.with_object({}) do |item, hsh|
        value = block_given? ? block.call(item) : item

        hsh[value] = hsh.fetch(value, 0) + 1
      end # each
    end # method count_values

    # Creates a deep copy of the object by returning a new Array with deep
    # copies of each array item.
    #
    # @param [Array<Object>] ary The array to copy.
    #
    # @return [Array] The copy of the array.
    def deep_dup ary
      require_array! ary

      ary.map { |obj| ObjectTools.deep_dup obj }
    end # method deep_dup

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
    # @param [Array<String>] ary The list of values to format. Will be
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
    # @raise ArgumentError If the first argument is not an Array-like object.
    #
    # @return [String] The formatted string.
    def humanize_list ary, options = {}
      require_array! ary

      separator = options.fetch(:separator, ', ')
      last_separator = options.fetch(:last_separator, ' and ')

      case ary.count
      when 0
        ''
      when 1
        ary.first.to_s
      when 2
        "#{ary[0]}#{last_separator}#{ary[1]}"
      else
        if last_separator =~ /\A,?\s*/
          last_separator = last_separator.sub /\A,?\s*/, separator
        else
          last_separator = "#{separator}#{last_separator}"
        end # if-else

        "#{ary[0...-1].join(separator)}#{last_separator}#{ary.last}"
      end # case
    end # method humanize_list

    # Accepts an array, a start value, a number of items to delete, and zero or
    # more items to insert at that index. Deletes the specified number of items,
    # then inserts the given items at the index and returns the array of deleted
    # items.
    #
    # @example Deleting items from an Array
    #   values = %w(katana wakizashi tachi daito shoto)
    #   ArrayTools.splice values, 1, 2
    #   #=> ['wakizashi', 'tachi']
    #   values
    #   #=> ['katana', 'daito', 'shoto']
    #
    # @example Inserting items into an Array
    #   values = %w(longsword broadsword claymore)
    #   ArrayTools.splice values, 1, 0, 'zweihänder'
    #   #=> []
    #   values
    #   #=> ['longsword', 'zweihänder', 'broadsword', 'claymore']
    #
    # @example Inserting and deleting items
    #   values = %w(shortbow longbow crossbow)
    #   ArrayTools.splice values, 2, 1, 'arbalest', 'chu-ko-nu'
    #   #=> ['crossbow']
    #   values
    #   #=> ['shortbow', 'longbow', 'arbalest', 'chu-ko-nu']
    #
    # @param [Array<Object>] ary The array to splice.
    # @param [Integer] start The starting index to delete or insert values from
    #   or into. If negative, counts backward from the end of the array.
    # @param [Integer] delete_count The number of items to delete.
    # @param [Array<Object>] insert The items to insert, if any.
    #
    # @raise ArgumentError If the first argument is not an Array-like object.
    #
    # @return [Array<Object>] The deleted items, or an empty array if no items
    #   were deleted.
    def splice ary, start, delete_count, *insert
      require_array! ary

      start   = start < 0 ? start + ary.count : start
      range   = start...(start + delete_count)
      deleted = ary[range]

      ary[range] = insert

      deleted
    end # method splice

    private

    def require_array! value
      return if array?(value)

      raise ArgumentError, 'argument must be an array', caller[1..-1]
    end # method require_array
  end # module
end # module
