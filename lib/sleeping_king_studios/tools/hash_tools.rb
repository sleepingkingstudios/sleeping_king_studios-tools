# lib/sleeping_king_studios/tools/hash_tools.rb

require 'sleeping_king_studios/tools'
require 'sleeping_king_studios/tools/array_tools'
require 'sleeping_king_studios/tools/object_tools'

module SleepingKingStudios::Tools
  # Tools for working with hash-like enumerable objects.
  module HashTools
    extend self

    HASH_METHODS = [:[], :count, :each, :each_key, :each_pair].freeze

    # Returns a copy of the hash with the keys converted to strings.
    #
    # @param [Hash] hsh The hash to convert.
    #
    # @return [Hash] The converted copy of the hash.
    def convert_keys_to_strings hsh
      require_hash! hsh

      hsh.each.with_object({}) do |(key, value), cpy|
        sym = key.to_s

        cpy[sym] = convert_value_to_stringified_hash(value)
      end # each
    end # method convert_keys_to_strings
    alias_method :stringify_keys, :convert_keys_to_strings

    # Returns a copy of the hash with the keys converted to symbols.
    #
    # @param [Hash] hsh The hash to convert.
    #
    # @return [Hash] The converted copy of the hash.
    def convert_keys_to_symbols hsh
      require_hash! hsh

      hsh.each.with_object({}) do |(key, value), cpy|
        sym = key.to_s.intern

        cpy[sym] = convert_value_to_symbolic_hash(value)
      end # each
    end # method convert_keys_to_symbols
    alias_method :symbolize_keys, :convert_keys_to_symbols

    # Creates a deep copy of the object by returning a new Hash with deep
    # copies of each key and value.
    #
    # @param [Hash<Object>] hsh The hash to copy.
    #
    # @return [Hash] The copy of the hash.
    def deep_dup hsh
      require_hash! hsh

      hsh.each.with_object(Hash.new) do |(key, value), copy|
        copy[ObjectTools.deep_dup key] = ObjectTools.deep_dup(value)
      end # each
    end # method deep_dup

    # Freezes the hash and performs a deep freeze on each hash key and
    # value.
    #
    # @param [Hash] hsh The object to freeze.
    def deep_freeze hsh
      require_hash! hsh

      hsh.freeze

      hsh.each do |key, value|
        ObjectTools.deep_freeze key
        ObjectTools.deep_freeze value
      end # each
    end # method deep_freeze

    # Returns true if the object is or appears to be a Hash.
    #
    # @param hsh [Object] The object to test.
    #
    # @return [Boolean] True if the object is a Hash, otherwise false.
    def hash? hsh
      return true if Hash === hsh

      HASH_METHODS.each do |method_name|
        return false unless hsh.respond_to?(method_name)
      end # each

      true
    end # method hash?

    # Returns true if the hash is immutable, i.e. if the hash is frozen and each
    # hash key and hash value are immutable.
    #
    # @param hsh [Hash] The hash to test.
    #
    # @return [Boolean] True if the hash is immutable, otherwise false.
    def immutable? hsh
      require_hash! hsh

      return false unless hsh.frozen?

      hsh.each do |key, value|
        return false unless ObjectTools.immutable?(key) && ObjectTools.immutable?(value)
      end # each

      true
    end # method immutable

    # Returns true if the hash is mutable.
    #
    # @param hsh [Array] The hash to test.
    #
    # @return [Boolean] True if the hash is mutable, otherwise false.
    #
    # @see #immutable?
    def mutable? hsh
      !immutable?(hsh)
    end # method mutable?

    private

    def convert_value_to_stringified_hash value
      if hash?(value)
        convert_keys_to_strings(value)
      elsif ArrayTools.array?(value)
        value.map { |item| convert_value_to_stringified_hash(item) }
      else
        value
      end # if-else
    end # method convert_value_to_stringified_hash

    def convert_value_to_symbolic_hash value
      if hash?(value)
        convert_keys_to_symbols(value)
      elsif ArrayTools.array?(value)
        value.map { |item| convert_value_to_symbolic_hash(item) }
      else
        value
      end # if-else
    end # method convert_value_to_symbolic_hash

    def require_hash! value
      return if hash?(value)

      raise ArgumentError, 'argument must be a hash', caller[1..-1]
    end # method require_array
  end # module
end # module
