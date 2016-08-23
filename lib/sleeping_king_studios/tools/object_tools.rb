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
    def apply base, proc, *args, **kwargs, &block
      temporary_method_name = :__sleeping_king_studios_tools_object_tools_temporary_method_for_applying_proc__

      metaclass = class << base; self; end
      metaclass.send :define_method, temporary_method_name, &proc

      begin
        if kwargs.empty?
          base.send temporary_method_name, *args, &block
        else
          base.send temporary_method_name, *args, **kwargs, &block
        end # if-else
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

    # Returns the object's eigenclass.
    #
    # @param [Object] object The object for which an eigenclass is required.
    #
    # @return [Class] The object's eigenclass.
    def eigenclass object
      class << object; self; end
    end # method eigenclass
    alias_method :metaclass, :eigenclass

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
