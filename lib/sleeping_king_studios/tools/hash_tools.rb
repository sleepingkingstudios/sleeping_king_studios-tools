# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Tools for working with hash-like enumerable objects.
  class HashTools < SleepingKingStudios::Tools::Base
    # Expected methods that a Hash-like object should implement.
    HASH_METHODS = %i[[] count each each_key each_pair].freeze

    class << self
      def_delegators :instance,
        :convert_keys_to_strings,
        :convert_keys_to_symbols,
        :deep_dup,
        :deep_freeze,
        :generate_binding,
        :hash?,
        :immutable?,
        :mutable?,
        :stringify_keys,
        :symbolize_keys
    end

    # Returns a deep copy of the hash with the keys converted to strings.
    #
    # @param hsh [Hash] the hash to convert.
    #
    # @return [Hash] the converted copy of the hash.
    #
    # @raise [ArgumentError] if the first argument is not an Hash-like object.
    #
    # @example
    #   hsh = { :one => 1, :two => 2, :three => 3 }
    #   cpy = HashTools.convert_keys_to_strings(hsh)
    #   #=> { 'one' => 1, 'two' => 2, 'three' => 3 }
    #   hsh
    #   #=> { :one => 1, :two => 2, :three => 3 }
    #
    #   hsh = { :odd => { :one => 1, :three => 3 }, :even => { :two => 2, :four => 4 } }
    #   cpy = HashTools.convert_keys_to_strings(hsh)
    #   #=> { 'odd' => { 'one' => 1, 'three' => 3 }, 'even' => { 'two' => 2, 'four' => 4 } }
    #   hsh
    #   #=> { :odd => { :one => 1, :three => 3 }, :even => { :two => 2, :four => 4 } }
    def convert_keys_to_strings(hsh)
      require_hash!(hsh)

      hsh.each.with_object({}) do |(key, value), cpy|
        sym = key.to_s

        cpy[sym] = convert_value_to_stringified_hash(value)
      end
    end
    alias stringify_keys convert_keys_to_strings

    # Returns a deep copy of the hash with the keys converted to symbols.
    #
    # @param hsh [Hash] the hash to convert.
    #
    # @return [Hash] the converted copy of the hash.
    #
    # @raise [ArgumentError] if the first argument is not an Hash-like object.
    #
    # @example
    #   hsh = { 'one' => 1, 'two' => 2, 'three' => 3 }
    #   cpy = HashTools.convert_keys_to_symbols(hsh)
    #   #=> { :one => 1, :two => 2, :three => 3 }
    #   hsh
    #   #=> { 'one' => 1, 'two' => 2, 'three' => 3 }
    #
    #   hsh = { 'odd' => { 'one' => 1, 'three' => 3 }, 'even' => { 'two' => 2, 'four' => 4 } }
    #   cpy = HashTools.convert_keys_to_strings(hsh)
    #   #=> { :odd => { :one => 1, :three => 3 }, :even => { :two => 2, :four => 4 } }
    #   hsh
    #   #=> { 'odd' => { 'one' => 1, 'three' => 3 }, 'even' => { 'two' => 2, 'four' => 4 } }
    def convert_keys_to_symbols(hsh)
      require_hash!(hsh)

      hsh.each.with_object({}) do |(key, value), cpy|
        sym = key.to_s.intern

        cpy[sym] = convert_value_to_symbolic_hash(value)
      end
    end
    alias symbolize_keys convert_keys_to_symbols

    # Creates a deep copy of the Hash.
    #
    # @param hsh [Hash<Object>] the hash to copy.
    #
    # @return [Hash] the copy of the hash.
    #
    # @raise [ArgumentError] if the first argument is not an Hash-like object.
    #
    # @example
    #   hsh = { :one => 'one', :two => 'two', :three => 'three' }
    #   cpy = HashTools.deep_dup hsh
    #
    #   cpy.update :four => 'four'
    #   #=> { :one => 'one', :two => 'two', :three => 'three', :four => 'four' }
    #   hsh
    #   #=> { :one => 'one', :two => 'two', :three => 'three' }
    #
    #   cpy[:one].sub!(/on/, 'vu'); cpy
    #   #=> { :one => 'vun', :two => 'two', :three => 'three', :four => 'four' }
    #   hsh
    #   #=> { :one => 'one', :two => 'two', :three => 'three' }
    def deep_dup(hsh)
      require_hash!(hsh)

      hsh.each.with_object({}) do |(key, value), copy|
        copy[ObjectTools.deep_dup key] = ObjectTools.deep_dup(value)
      end
    end

    # Freezes the hash and performs a deep freeze on each hash key and value.
    #
    # @param hsh [Hash] the hash to freeze.
    #
    # @return [Hash] the frozen hash.
    #
    # @raise [ArgumentError] if the first argument is not an Hash-like object.
    #
    # @example
    #   hsh = { :one => 'one', :two => 'two', :three => 'three' }
    #   HashTools.deep_freeze hsh
    #
    #   hsh.frozen?
    #   #=> true
    #   hsh[:one].frozen?
    #   #=> true
    def deep_freeze(hsh)
      require_hash!(hsh)

      hsh.freeze

      hsh.each do |key, value|
        ObjectTools.deep_freeze key
        ObjectTools.deep_freeze value
      end
    end

    # Generates a Binding with the hash values as local variables.
    #
    # @return [Binding] the binding object.
    #
    # @raise [ArgumentError] if the first argument is not an Hash-like object.
    #
    # @example
    #   hsh     = { :one => 'one', :two => 'two', :three => 'three' }
    #   binding = HashTools.generate_binding(hsh)
    #   #=> Binding
    #
    #   binding.local_variable_defined?(:one)
    #   #=> true
    #   binding.local_variable_get(:one)
    #   #=> 'one'
    #   binding.eval('one')
    #   #=> 'one'
    def generate_binding(hsh)
      require_hash!(hsh)

      CoreTools.empty_binding.tap do |binding|
        hsh.each do |key, value|
          binding.local_variable_set key, value
        end
      end
    end

    # Returns true if the object is or appears to be a Hash.
    #
    # This method checks for the method signatures of the object. A Hash-like
    # method will define all of the the #[], #count, #each, #each_key, and
    # #each_value methods.
    #
    # @param obj [Object] the object to test.
    #
    # @return [Boolean] true if the object is a Hash, otherwise false.
    #
    # @example
    #   HashTools.hash?(nil)
    #   #=> false
    #   HashTools.hash?([])
    #   #=> false
    #   HashTools.hash?({})
    #   #=> true
    def hash?(obj)
      return true if obj.is_a?(Hash)

      HASH_METHODS.each do |method_name|
        return false unless obj.respond_to?(method_name)
      end

      true
    end

    # Returns true if the hash is immutable.
    #
    # A hash is considered immutable if the hash itself is frozen and each
    # key and value in the hash is immutable.
    #
    # @param hsh [Hash] the hash to test.
    #
    # @return [Boolean] true if the hash is immutable, otherwise false.
    #
    # @raise [ArgumentError] if the first argument is not an Hash-like object.
    #
    # @see HashTools#mutable?
    #
    # @see ObjectTools#immutable?
    #
    # @example
    #   HashTools.immutable?({ :id => 0, :title => 'The Ramayana' })
    #   #=> false
    #
    #   HashTools.immutable?({ :id => 0, :title => +'The Ramayana' }.freeze)
    #   #=> false
    #
    #   HashTools.immutable?({ :id => 0, :title => 'The Ramayana' }.freeze)
    #   #=> true
    def immutable?(hsh)
      require_hash!(hsh)

      return false unless hsh.frozen?

      hsh.each do |key, value|
        unless ObjectTools.immutable?(key) && ObjectTools.immutable?(value)
          return false
        end
      end

      true
    end

    # Returns true if the hash or any of its contents are mutable.
    #
    # @param hsh [Hash] the hash to test.
    #
    # @return [Boolean] true if the hash is mutable, otherwise false.
    #
    # @raise [ArgumentError] if the first argument is not an Hash-like object.
    #
    # @see HashTools#immutable?
    def mutable?(hsh)
      !immutable?(hsh)
    end

    private

    def convert_value_to_stringified_hash(value)
      if hash?(value)
        convert_keys_to_strings(value)
      elsif ArrayTools.array?(value)
        value.map { |item| convert_value_to_stringified_hash(item) }
      else
        value
      end
    end

    def convert_value_to_symbolic_hash(value)
      if hash?(value)
        convert_keys_to_symbols(value)
      elsif ArrayTools.array?(value)
        value.map { |item| convert_value_to_symbolic_hash(item) }
      else
        value
      end
    end

    def require_hash!(value)
      return if hash?(value)

      raise ArgumentError, 'argument must be a hash', caller[1..]
    end
  end
end
