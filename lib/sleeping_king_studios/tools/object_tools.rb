# lib/sleeping_king_studios/tools/object_tools.rb

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Low-level tools for working with objects.
  module ObjectTools
    extend self

    # Takes a proc or lambda and invokes it with the given object as
    # receiver, with any additional arguments or block provided.
    #
    # @param [Object] base The receiver. The proc will be called in the
    #   context of this object.
    # @param [Proc] proc The proc or lambda to call.
    # @param [Array] args Optional. Additional arguments to pass in to the
    #   proc or lambda.
    # @param [block] block Optional. If present, will be passed in to proc or
    #   lambda.
    #
    # @return The result of calling the proc or lambda with the given
    #   receiver and any additional arguments or block.
    def apply base, proc, *args, &block
      return base.instance_exec *args, &proc unless block_given?

      temporary_method_name = :__sleeping_king_studios_tools_object_tools_temporary_method_for_applying_proc__

      metaclass = class << base; self; end
      metaclass.send :define_method, temporary_method_name, &proc

      begin
        base.send temporary_method_name, *args, &block
      ensure
        metaclass.send :remove_method, temporary_method_name if temporary_method_name && defined?(temporary_method_name)
      end
    end # method apply

    # Creates a deep copy of the object. If the object is an Array, returns a
    # new Array with deep copies of each array item. If the object is a Hash,
    # returns a new Hash with deep copies of each hash key and value. Otherwise,
    # returns Object#dup.
    #
    # @param [Object] obj The object to copy.
    #
    # @return The copy of the object.
    def deep_dup obj
      case obj
      when FalseClass, Fixnum, Float, NilClass, Symbol, TrueClass
        obj
      when ->(_) { ArrayTools.array?(obj) }
        ArrayTools.deep_dup obj
      when ->(_) { HashTools.hash?(obj) }
        HashTools.deep_dup obj
      else
        obj.respond_to?(:deep_dup) ? obj.deep_dup : obj.dup
      end # case
    end # method deep_dup

    # Performs a deep freeze of the object. If the object is an Array, freezes
    # the array and performs a deep freeze on each array item. If the object is
    # a hash, freezes the hash and performs a deep freeze on each hash key and
    # value. Otherwise, calls Object#freeze.
    #
    # @param [Object] obj The object to freeze.
    def deep_freeze obj
      case obj
      when FalseClass, Fixnum, Float, NilClass, Symbol, TrueClass
        # Object is inherently immutable; do nothing here.
      when ->(_) { ArrayTools.array?(obj) }
        ArrayTools.deep_freeze(obj)
      when ->(_) { HashTools.hash?(obj) }
        HashTools.deep_freeze obj
      else
        obj.respond_to?(:deep_freeze) ? obj.deep_freeze : obj.freeze
      end # case
    end # method deep_freeze

    # Accesses deeply nested attributes by calling the first named method on the
    # given object, and each subsequent method on the result of the previous
    # method call. If the object does not respond to the method name, nil is
    # returned instead of calling the method.
    #
    # @param [Object] obj The object to dig.
    # @param [Array] method_names The names of the methods to call.
    #
    # @return [Object] The result of the last method call, or nil if the last
    #   object does not respond to the last method.
    def dig object, *method_names
      method_names.reduce(object) do |memo, method_name|
        memo.respond_to?(method_name) ? memo.send(method_name) : nil
      end # reduce
    end # method object

    # Returns the object's eigenclass.
    #
    # @param [Object] object The object for which an eigenclass is required.
    #
    # @return [Class] The object's eigenclass.
    def eigenclass object
      class << object; self; end
    end # method eigenclass
    alias_method :metaclass, :eigenclass

    # Returns true if the object is immutable. Values of nil, false, and true
    # are always immutable, as are instances of Numeric and Symbol. Arrays are
    # immutable if the array is frozen and each array item is immutable. Hashes
    # are immutable if the hash is frozen and each hash key and hash value are
    # immutable. Otherwise, objects are immutable if they are frozen.
    #
    # @param obj [Object] The object to test.
    #
    # @return [Boolean] True if the object is immutable, otherwise false.
    def immutable? obj
      case obj
      when NilClass, FalseClass, TrueClass, Numeric, Symbol
        true
      when ->(_) { ArrayTools.array?(obj) }
        ArrayTools.immutable? obj
      when ->(_) { HashTools.hash?(obj) }
        HashTools.immutable? obj
      else
        obj.frozen?
      end # case
    end # method immutable?

    # Returns true if the object is mutable.
    #
    # @param obj [Object] The object to test.
    #
    # @return [Boolean] True if the object is mutable, otherwise false.
    #
    # @see #immutable?
    def mutable? obj
      !immutable?(obj)
    end # method mutable?

    # Returns true if the object is an Object. This should return true only for
    # objects that have an alternate inheritance chain from BasicObject, such as
    # a Proxy.
    #
    # @param obj [Object] The object to test.
    #
    # @return [Boolean] True if the object is an Object, otherwise false.
    def object? obj
      Object === obj
    end # method object?

    # As #send, but returns nil if the object does not respond to the method.
    #
    # @param [Object] object The receiver of the message.
    # @param [String, Symbol] method_name The name of the method to call.
    # @param [Array] args The arguments to the message.
    #
    # @see active_support/core_ext/object/try.rb
    def try object, method_name, *args
      if object.nil?
        return object.respond_to?(method_name) ?
          object.send(method_name, *args) :
          nil
      end # if

      # Delegate to ActiveSupport::CoreExt::Object#try.
      return object.try(method_name, *args) if object.respond_to?(:try)

      object.send method_name, *args
    rescue NoMethodError => exception
      nil
    end # method try
  end # module
end # module

require 'sleeping_king_studios/tools/array_tools'
require 'sleeping_king_studios/tools/hash_tools'
