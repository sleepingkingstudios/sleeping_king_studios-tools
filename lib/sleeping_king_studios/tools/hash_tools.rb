# lib/sleeping_king_studios/tools/hash_tools.rb

require 'sleeping_king_studios/tools'
require 'sleeping_king_studios/tools/object_tools'

module SleepingKingStudios::Tools
  # Tools for working with hash-like enumerable objects.
  module HashTools
    extend self

    # Creates a deep copy of the object by returning a new Hash with deep
    # copies of each key and value.
    #
    # @param [Hash<Object>] hsh The hash to copy.
    #
    # @return [Hash] The copy of the hash.
    def deep_dup hsh
      hsh.each.with_object(Hash.new) do |(key, value), copy|
        copy[ObjectTools.deep_dup key] = ObjectTools.deep_dup(value)
      end # each
    end # method deep_dup

    # Returns true if the object is or appears to be a Hash.
    #
    # @param hsh [Object] The object to test.
    #
    # @return [Boolean] True if the object is a Hash, otherwise false.
    def hash? hsh
      return true if Hash === hsh

      [:[], :count, :each, :each_pair].each do |method_name|
        return false unless hsh.respond_to?(method_name)
      end # each

      true
    end # method array?
  end # module
end # module
