# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Tools for working with array-like enumerable objects.
  class ArrayTools < SleepingKingStudios::Tools::Base # rubocop:disable Metrics/ClassLength
    UNDEFINED = Object.new.freeze
    private_constant :UNDEFINED

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
        :fetch,
        :humanize_list,
        :immutable?,
        :mutable?,
        :splice,
        :tally
    end

    # Returns true if the object is or appears to be an Array.
    #
    # This method checks for the method signatures of the object. An Array-like
    # method will define all of the the #[], #count, and #each methods, and
    # neither of the #each_key or #each_pair methods.
    #
    # @param obj [Object] the object to test.
    #
    # @return [Boolean] true if the object is an Array, otherwise false.
    #
    # @example
    #   ArrayTools.array?(nil)
    #   #=> false
    #
    #   ArrayTools.array?([])
    #   #=> true
    #
    #   ArrayTools.array?({})
    #   #=> false
    def array?(obj)
      return true if obj.is_a?(Array)

      ARRAY_METHODS.each do |method_name|
        return false unless obj.respond_to?(method_name)
      end

      OTHER_METHODS.each do |method_name|
        return false if obj.respond_to?(method_name)
      end

      true
    end

    # Partitions the array into matching and non-matching items.
    #
    # Separates the array into two arrays, the first containing all items in the
    # original array that matches the provided block, and the second containing
    # all items in the original array that do not match the provided block.
    #
    # @param ary [Array<Object>] the array to bisect.
    #
    # @yieldparam item [Object] an item in the array to matched.
    #
    # @yieldreturn [Boolean] true if the item matches the criteria, otherwise
    #   false.
    #
    # @return [Array<Array<Object>>] an array containing two arrays.
    #
    # @raise [ArgumentError] if the first argument is not an Array-like object,
    #   or if no block is given.
    #
    # @example
    #   selected, rejected = ArrayTools.bisect([*0...10]) { |item| item.even? }
    #   selected
    #   #=> [0, 2, 4, 6, 8]
    #   rejected
    #   #=> [1, 3, 5, 7, 9]
    def bisect(ary)
      require_array!(ary)

      raise ArgumentError, 'no block given' unless block_given?

      selected = []
      rejected = []

      ary.each do |item|
        (yield(item) ? selected : rejected) << item
      end

      [selected, rejected]
    end

    # Counts the number of times each item or result appears in the object.
    #
    # @overload count_values(ary)
    #   Counts the number of times each value appears in the enumerable object.
    #
    #   @param ary [Array<Object>] the values to count.
    #
    #   @return [Hash{Object=>Integer}] The number of times each value appears
    #     in the enumerable object.
    #
    #   @raise [ArgumentError] if the first argument is not an Array-like
    #     object.
    #
    #   @example
    #     ArrayTools.count_values([1, 1, 1, 2, 2, 3])
    #     #=> { 1 => 3, 2 => 2, 3 => 1 }
    #
    # @overload count_values(ary, &block)
    #   Calls the block and counts the number of times each result appears.
    #
    #   @param ary [Array<Object>] the values to count.
    #
    #   @yieldparam item [Object] an item in the array to matched.
    #
    #   @return [Hash{Object=>Integer}] the number of times each result
    #     appears.
    #
    #   @raise [ArgumentError] if the first argument is not an Array-like
    #     object.
    #
    #   @example
    #     ArrayTools.count_values([1, 1, 1, 2, 2, 3]) { |i| i ** 2 }
    #     #=> { 1 => 3, 4 => 2, 9 => 1 }
    def count_values(ary, &block)
      require_array!(ary)

      ary.each.with_object({}) do |item, hsh|
        value = block_given? ? block.call(item) : item

        hsh[value] = hsh.fetch(value, 0) + 1
      end
    end
    alias tally count_values

    # Creates a deep copy of the object.
    #
    # Iterates over the array and returns a new Array with deep copies of each
    # array item.
    #
    # @param ary [Array<Object>] the array to copy.
    #
    # @return [Array] the copy of the array.
    #
    # @raise [ArgumentError] if the first argument is not an Array-like object.
    #
    # @see ObjectTools#deep_dup.
    #
    # @example
    #   ary = ['one', 'two', 'three']
    #   cpy = ArrayTools.deep_dup ary
    #
    #   cpy << 'four'
    #   #=> ['one', 'two', 'three', 'four']
    #   ary
    #   #=> ['one', 'two', 'three']
    #
    #   cpy.first.sub!(/on/, 'vu')
    #   cpy
    #   #=> ['vun', 'two', 'three', 'four']
    #   ary
    #   #=> ['one', 'two', 'three']
    def deep_dup(ary)
      require_array!(ary)

      ary.map { |obj| toolbelt.object_tools.deep_dup obj }
    end

    # Freezes the array and performs a deep freeze on each array item.
    #
    # @param ary [Array] the object to freeze.
    #
    # @return [Array] the frozen array.
    #
    # @raise [ArgumentError] if the first argument is not an Array-like object.
    #
    # @see ObjectTools#deep_freeze.
    #
    # @example
    #   ary = ['one', 'two', 'three']
    #   ArrayTools.deep_freeze ary
    #
    #   ary.frozen?
    #   #=> true
    #   ary.first.frozen?
    #   #=> true
    def deep_freeze(ary)
      require_array!(ary)

      ary.freeze

      ary.each { |obj| toolbelt.object_tools.deep_freeze obj }
    end

    # @overload fetch(ary, index, default = nil)
    #   Retrieves the value at the specified index.
    #
    #   If the value does not exist, returns the default value, or raises an
    #   IndexError if there is no default value. If the object defines a native
    #   #fetch method, delegates to the native implementation.
    #
    #   @param ary [Array] the array or array-like object.
    #   @param index [Integer] the index to retrieve.
    #   @param default [Object] the default value.
    #
    #   @return [Object] the value at the specified index.
    #
    #   @raises [IndexError] if the array does not have a value at that index
    #     and there is no default value.
    #
    # @overload fetch(ary, index, &default)
    #   Retrieves the value at the specified index.
    #
    #   If the value does not exist, returns the value of the default block, or
    #   raises an IndexError if there is no default block. If the object defines
    #   a native #fetch method, delegates to the native implementation.
    #
    #   @param ary [Array] the array or array-like object.
    #   @param index [Integer] the index to retrieve.
    #
    #   @yield generates the default value if there is no value at the index.
    #
    #   @yieldparam index [Integer] the requested index.
    #
    #   @yieldreturn [Object] the default value.
    #
    #   @return [Object] the value at the specified index.
    #
    #   @raises [IndexError] if the array does not have a value at that index
    #     and there is no default value.
    def fetch(ary, index, default = UNDEFINED, &block)
      require_array!(ary)

      if ary.respond_to?(:fetch)
        return native_fetch(ary, index, default, &block)
      end

      size = ary.respond_to?(:size) ? ary.size : ary.count

      return ary[index] if index < size && index >= -size

      return block.call(index) if block_given?

      return default unless default == UNDEFINED

      raise IndexError,
        "index #{index} outside of array bounds: -#{size}...#{size}"
    end

    # @overload def humanize_list(ary, **options, &)
    #   Generates a human-readable string representation of the list items.
    #
    #   Accepts a list of values and returns a human-readable string of the
    #   values, with the format based on the number of items.
    #
    #   @param ary [Array<String>] the list of values to format. Will be
    #     coerced to strings using #to_s.
    #   @param options [Hash] optional configuration hash.
    #   @option options [String] :last_separator the value to use to separate
    #     the final pair of values. Defaults to " and " (note the leading and
    #     trailing spaces). Will be combined with the :separator for lists of
    #     length 3 or greater.
    #   @option options [String] :separator the value to use to separate pairs
    #     of values before the last in lists of length 3 or greater. Defaults to
    #     ", " (note the trailing space).
    #
    #   @return [String] the formatted string.
    #
    #   @raises [ArgumentError] if the first argument is not an Array-like
    #     object.
    #
    #   @example With Zero Items
    #     ArrayTools.humanize_list([])
    #     #=> ''
    #
    #   @example With One Item
    #     ArrayTools.humanize_list(['spam'])
    #     #=> 'spam'
    #
    #   @example With Two Items
    #     ArrayTools.humanize_list(['spam', 'eggs'])
    #     #=> 'spam and eggs'
    #
    #   @example With Three Or More Items
    #     ArrayTools.humanize_list(['spam', 'eggs', 'bacon', 'spam'])
    #     #=> 'spam, eggs, bacon, and spam'
    #
    #   @example With Three Or More Items And Options
    #     ArrayTools.humanize_list(
    #       ['spam', 'eggs', 'bacon', 'spam'],
    #       :last_separator => ' or '
    #     )
    #     #=> 'spam, eggs, bacon, or spam'
    def humanize_list(ary, **, &)
      require_array!(ary)

      return '' if ary.empty?

      size = ary.size
      ary  = ary.map(&) if block_given?

      return ary[0].to_s if size == 1

      separator, last_separator =
        options_for_humanize_list(size:, **)

      return "#{ary[0]}#{last_separator}#{ary[1]}" if size == 2

      "#{ary[0...-1].join(separator)}#{last_separator}#{ary.last}"
    end

    # Checks if the array and its contents are immutable.
    #
    # An array is considered immutable if the array itself is frozen and each
    # item in the array is immutable.
    #
    # @param ary [Array] the array to test.
    #
    # @return [Boolean] true if the array is immutable, otherwise false.
    #
    # @raise [ArgumentError] if the first argument is not an Array-like object.
    #
    # @see ArrayTools#mutable?
    #
    # @see ObjectTools#immutable?
    #
    # @example
    #   ArrayTools.immutable?([1, 2, 3])
    #   #=> false
    #
    #   ArrayTools.immutable?([1, 2, 3].freeze)
    #   #=> true
    #
    #   ArrayTools.immutable?([+'ichi', +'ni', +'san'])
    #   #=> false
    #
    #   ArrayTools.immutable?([+'ichi', +'ni', +'san'].freeze)
    #   #=> false
    #
    #   ArrayTools.immutable?(['ichi', 'ni', 'san'].freeze)
    #   #=> true
    def immutable?(ary)
      require_array!(ary)

      return false unless ary.frozen?

      ary.each do |item|
        return false unless toolbelt.object_tools.immutable?(item)
      end

      true
    end

    # Checks if the array or any of its contents are mutable.
    #
    # @param ary [Array] the array to test.
    #
    # @return [Boolean] true if the array or any of its items are mutable,
    #   otherwise false.
    #
    # @raise [ArgumentError] if the first argument is not an Array-like object.
    #
    # @see #immutable?
    def mutable?(ary)
      !immutable?(ary)
    end

    # Replaces a range of items in the array with the given items.
    #
    # @param ary [Array<Object>] the array to splice.
    # @param start [Integer] the starting index to delete or insert values from
    #   or into. If negative, counts backward from the end of the array.
    # @param delete_count [Integer] the number of items to delete.
    # @param insert [Array<Object>] the items to insert, if any.
    #
    # @return [Array<Object>] the deleted items, or an empty array if no items
    #   were deleted.
    #
    # @raise [ArgumentError] if the first argument is not an Array-like object.
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
    def splice(ary, start, delete_count, *insert)
      require_array!(ary)

      start  += ary.count if start.negative?
      range   = start...(start + delete_count)
      deleted = ary[range]

      ary[range] = insert

      deleted
    end

    private

    def native_fetch(ary, index, default, &)
      return ary.fetch(index, &) if default == UNDEFINED

      ary.fetch(index, default, &)
    end

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
