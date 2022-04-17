# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Tools for working with array-like enumerable objects.
  class ArrayTools < SleepingKingStudios::Tools::Base
    # Expected methods that an Array-like object should implement.
    ARRAY_METHODS = %i[[] count each].freeze

    # Methods that an Array-like object should *not* implement.
    OTHER_METHODS = %i[each_key each_pair].freeze

    class << self
      def_delegators :instance,
        :array?,
        :bisect,
        :count_values,
        :deep_dup,
        :deep_freeze,
        :humanize_list,
        :immutable?,
        :mutable?,
        :splice,
        :tally
    end

    # Returns true if the object is or appears to be an Array.
    #
    # @param ary [Object] The object to test.
    #
    # @return [Boolean] True if the object is an Array, otherwise false.
    def array?(ary)
      return true if ary.is_a?(Array)

      ARRAY_METHODS.each do |method_name|
        return false unless ary.respond_to?(method_name)
      end

      OTHER_METHODS.each do |method_name|
        return false if ary.respond_to?(method_name)
      end

      true
    end

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
    def bisect(ary)
      require_array! ary

      raise ArgumentError, 'no block given' unless block_given?

      selected = []
      rejected = []

      ary.each do |item|
        (yield(item) ? selected : rejected) << item
      end

      [selected, rejected]
    end

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
    def count_values(ary, &block)
      require_array! ary

      ary.each.with_object({}) do |item, hsh|
        value = block_given? ? block.call(item) : item

        hsh[value] = hsh.fetch(value, 0) + 1
      end
    end
    alias tally count_values

    # Creates a deep copy of the object by returning a new Array with deep
    # copies of each array item.
    #
    # @param [Array<Object>] ary The array to copy.
    #
    # @return [Array] The copy of the array.
    def deep_dup(ary)
      require_array! ary

      ary.map { |obj| ObjectTools.deep_dup obj }
    end

    # Freezes the array and performs a deep freeze on each array item.
    #
    # @param [Array] ary The object to freeze.
    def deep_freeze(ary)
      require_array! ary

      ary.freeze

      ary.each { |obj| ObjectTools.deep_freeze obj }
    end

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
    #   ArrayTools.humanize_list(
    #     ['spam', 'eggs', 'bacon', 'spam'],
    #     :last_separator => ' or '
    #   )
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
    def humanize_list(ary, **options, &block)
      require_array! ary

      return '' if ary.empty?

      size = ary.size
      ary  = ary.map(&block) if block_given?

      return ary[0].to_s if size == 1

      separator, last_separator =
        options_for_humanize_list(size: size, **options)

      return "#{ary[0]}#{last_separator}#{ary[1]}" if size == 2

      "#{ary[0...-1].join(separator)}#{last_separator}#{ary.last}"
    end

    # Returns true if the array is immutable, i.e. the array is frozen and each
    # array item is immutable.
    #
    # @param ary [Array] The array to test.
    #
    # @return [Boolean] True if the array is immutable, otherwise false.
    #
    # @see ObjectTools#immutable?
    def immutable?(ary)
      require_array! ary

      return false unless ary.frozen?

      ary.each { |item| return false unless ObjectTools.immutable?(item) }

      true
    end

    # Returns true if the array is mutable.
    #
    # @param ary [Array] The array to test.
    #
    # @return [Boolean] True if the array is mutable, otherwise false.
    #
    # @see #immutable?
    def mutable?(ary)
      !immutable?(ary)
    end

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
    #   ArrayTools.splice values, 1, 0, 'zweihander'
    #   #=> []
    #   values
    #   #=> ['longsword', 'zweihander', 'broadsword', 'claymore']
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
    def splice(ary, start, delete_count, *insert)
      require_array! ary

      start   = start.negative? ? start + ary.count : start
      range   = start...(start + delete_count)
      deleted = ary[range]

      ary[range] = insert

      deleted
    end

    private

    def options_for_humanize_list(
      size:,
      last_separator: ' and ',
      separator: ', '
    )
      return [separator, last_separator] if size < 3

      last_separator =
        if last_separator =~ /\A,?\s*/
          last_separator.sub(/\A,?\s*/, separator)
        else
          "#{separator}#{last_separator}"
        end

      [separator, last_separator]
    end

    def require_array!(value)
      return if array?(value)

      raise ArgumentError, 'argument must be an array', caller[1..]
    end
  end
end
