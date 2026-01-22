# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Low-level tools for working with objects.
  class ObjectTools < SleepingKingStudios::Tools::Base # rubocop:disable Metrics/ClassLength
    TEMPORARY_METHOD_NAME =
      '__sleeping_king_studios_tools_apply_%i__'
    private_constant :TEMPORARY_METHOD_NAME

    class << self
      def_delegators :instance,
        :apply,
        :deep_dup,
        :deep_freeze,
        :dig,
        :eigenclass,
        :fetch,
        :immutable?,
        :metaclass,
        :mutable?,
        :object?,
        :try
    end

    # Calls a Proc or lambda on the given receiver with the given parameters.
    #
    # Unlike calling #instance_exec with the block, ObjectTools#apply allows you
    # to specify a block parameter.
    #
    # @param receiver [Object] The receiver. the proc will be called in the
    #   context of this object.
    # @param proc [Proc] the proc or lambda to call.
    # @param args [Array] optional. Additional arguments to pass in to the proc
    #   or lambda.
    # @param kwargs [Hash] optional. Additional keywords to pass in to the proc
    #   or lambda.
    # @param block [block] optional. If present, will be passed in to proc or
    #   lambda.
    #
    # @return the result of calling the proc or lambda with the given
    #   receiver and any additional arguments or block.
    #
    # @example
    #   my_object = double('object', :to_s => 'A mock object')
    #   my_proc   = ->() { puts %{#{self.to_s} says "Greetings, programs!"} }
    #
    #   ObjectTools.apply my_object, my_proc
    #   #=> Writes 'A mock object says "Greetings, programs!"' to STDOUT.
    def apply(receiver, proc, *args, **kwargs, &block)
      return receiver.instance_exec(*args, **kwargs, &proc) unless block_given?

      method_name =
        Kernel.format(TEMPORARY_METHOD_NAME, Thread.current.object_id)

      with_temporary_method(receiver, method_name, proc) do
        receiver.send(method_name, *args, **kwargs, &block)
      end
    end

    # Creates a deep copy of the object.
    #
    # If the object is an Array, returns a new Array with deep copies of each
    # array item. If the object is a Hash, returns a new Hash with deep copies
    # of each hash key and value. Otherwise, returns Object#dup.
    #
    # @param obj [Object] the object to copy.
    #
    # @return the copy of the object.
    #
    # @see ArrayTools#deep_copy
    #
    # @see HashTools#deep_copy
    #
    # @example
    #   data = {
    #     :songs = [
    #       {
    #         :name   => 'Welcome to the Jungle',
    #         :artist => "Guns N' Roses",
    #         :album  => 'Appetite for Destruction'
    #       },
    #       {
    #         :name   => 'Hells Bells',
    #         :artist => 'AC/DC',
    #         :album  => 'Back in Black'
    #       },
    #       {
    #         :name   => "Knockin' on Heaven's Door",
    #         :artist => 'Bob Dylan',
    #         :album  => 'Pat Garrett & Billy The Kid'
    #       }
    #     ]
    #   }
    #
    #   copy = ObjectTools.deep_dup data
    #
    #   copy[:songs] << { :name => 'Sympathy for the Devil', :artist => 'The Rolling Stones', :album => 'Beggars Banquet' }
    #   data[:songs].count
    #   #=> 3
    #
    #   copy[:songs][1][:name] = 'Shoot to Thrill'
    #   data[:songs][1]
    #   #=> { :name => 'Hells Bells', :artist => 'AC/DC', :album => 'Back in Black' }
    def deep_dup(obj) # rubocop:disable Metrics/AbcSize
      case obj
      when FalseClass, Integer, Float, NilClass, Symbol, TrueClass
        obj
      when ->(_) { toolbelt.array_tools.array?(obj) }
        toolbelt.array_tools.deep_dup obj
      when ->(_) { toolbelt.hash_tools.hash?(obj) }
        toolbelt.hash_tools.deep_dup obj
      else
        obj.respond_to?(:deep_dup) ? obj.deep_dup : obj.dup
      end
    end

    # Performs a deep freeze of the object.
    #
    # If the object is an Array, freezes the array and performs a deep freeze on
    # each array item. If the object is a hash, freezes the hash and performs a
    # deep freeze on each hash key and value. Otherwise, calls Object#freeze.
    #
    # @param obj [Object] The object to freeze.
    #
    # @return [Object] the frozen object.
    #
    # @example
    #   data = {
    #     :songs = [
    #       {
    #         :name   => 'Welcome to the Jungle',
    #         :artist => "Guns N' Roses",
    #         :album  => 'Appetite for Destruction'
    #       },
    #       {
    #         :name   => 'Hells Bells',
    #         :artist => 'AC/DC',
    #         :album  => 'Back in Black'
    #       },
    #       {
    #         :name   => "Knockin' on Heaven's Door",
    #         :artist => 'Bob Dylan',
    #         :album  => 'Pat Garrett & Billy The Kid'
    #       }
    #     ]
    #   }
    #   ObjectTools.deep_freeze(data)
    #
    #   data.frozen?
    #   #=> true
    #   data[:songs].frozen?
    #   #=> true
    #   data[:songs][0].frozen?
    #   #=> true
    #   data[:songs][0].name.frozen?
    #   #=> true
    def deep_freeze(obj) # rubocop:disable Metrics/AbcSize
      case obj
      when FalseClass, Integer, Float, NilClass, Symbol, TrueClass
        # Object is inherently immutable; do nothing here.
      when ->(_) { toolbelt.array_tools.array?(obj) }
        toolbelt.array_tools.deep_freeze(obj)
      when ->(_) { toolbelt.hash_tools.hash?(obj) }
        toolbelt.hash_tools.deep_freeze obj
      else
        obj.respond_to?(:deep_freeze) ? obj.deep_freeze : obj.freeze
      end
    end

    # Accesses deeply nested attributes on an object.
    #
    # This method finds the first named property on the given object, and then
    # each subsequent property on the result of the previous call.
    #
    # - If the object responds to the property name as a public method, it calls
    #   the  method directly.
    # - If the object does not respond to the property name, or if the property
    #   name is not itself a valid method name, checks if the object responds to
    #   #[]; if so, calls #[] with the property name.
    # - Otherwise, immediately returns nil.
    #
    # Using #[] access allows digging through Array (using integer indices) and
    # Hash data structures as well as object methods.
    #
    # @param obj [Object] the object to dig.
    # @param method_names [Array] the names of the methods to call.
    # @param indifferent_keys [true, false] if true, matches both String and
    #   Symbol keys when accessing a Hash value using #[]. Defaults to false.
    #
    # @return [Object, nil] the result of the last method call, or nil if the
    #   last object does not respond to the last method.
    #
    # @example
    #   ObjectTools.dig(my_object, :first_method, :second_method, :third_method)
    #   #=> my_object.first_method.second_method.third_method
    def dig(obj, *method_names, indifferent_keys: false)
      method_names.reduce(obj) do |memo, method_name|
        if object_responds_to_method?(memo, method_name)
          next memo.public_send(method_name)
        end

        next nil unless memo.respond_to?(:[])

        next memo[method_name] unless indifferent_keys

        indifferent_get(memo, method_name)
      end
    rescue NameError
      nil
    end

    # Returns the object's eigenclass.
    #
    # @param obj [Object] the object for which an eigenclass is required.
    #
    # @return [Class] the object's singleton class.
    def eigenclass(obj)
      obj.singleton_class
    end
    alias metaclass eigenclass

    # @overload fetch(obj, key, default = nil, indifferent_key: false)
    #   Retrieves the value at the specified method, key, or index.
    #
    #   If the value does not exist, returns the default value, or raises am
    #   exception if there is no default value. If the object defines a native
    #   #fetch method, delegates to the native implementation.
    #
    #   @param obj [Object] the baseobject.
    #   @param key [Object] the key to retrieve.
    #   @param indifferent_key [true, false] if true and the key is a String or
    #     a Symbol, tries to match both the String and Symbol equivalent.
    #     Defaults to false.
    #   @param default [Object] the default value.
    #
    #   @return [Object] the value at the specified key or index.
    #
    #   @raise [IndexError, KeyError, NameError] if the object does not have a
    #     value for the requested key or index and there is no default value.
    #
    # @overload fetch(obj, key, indifferent_key: false, &default)
    #   Retrieves the value at the specified method, key, or index.
    #
    #   If the value does not exist, returns the default value, or raises am
    #   exception if there is no default value. If the object defines a native
    #   #fetch method, delegates to the native implementation.
    #
    #   @param obj [Object] the baseobject.
    #   @param key [Object] the key to retrieve.
    #   @param indifferent_key [true, false] if true and the key is a String or
    #     a Symbol, tries to match both the String and Symbol equivalent.
    #     Defaults to false.
    #
    #   @yield generates the default value if there is no value at the key.
    #
    #   @yieldparam key [Object] the requested key.
    #
    #   @yieldreturn [Object] the default value.
    #
    #   @return [Object] the value at the specified key or index.
    #
    #   @raise [IndexError, KeyError, NameError] if the object does not have a
    #     value for the requested key or index and there is no default value.
    def fetch(obj, key_or_index, default = UNDEFINED, indifferent_key: false, &)
      case obj
      when ->(_) { object_responds_to_method?(obj, key_or_index) }
        obj.public_send(key_or_index)
      when ->(_) { toolbelt.array_tools.array?(obj) }
        fetch_array(obj, key_or_index, default, &)
      when ->(_) { toolbelt.hash_tools.hash?(obj) }
        fetch_hash(obj, key_or_index, default, indifferent_key:, &)
      else
        handle_invalid_fetch(obj, key_or_index, default, &)
      end
    end

    # Checks if the object is immutable.
    #
    # - nil, false, and true are always immutable, as are instances of Numeric
    #   and Symbol.
    # - Strings are immutable if frozen, such as strings defined in a file with
    #   a frozen_string_literal pragma.
    # - Arrays are immutable if the array is frozen and each array item is
    #   immutable.
    # - Hashes are immutable if the hash is frozen and each hash key and hash
    #   value are immutable.
    # - Otherwise, objects are immutable if they are frozen.
    #
    # @param obj [Object] the object to test.
    #
    # @return [Boolean] true if the object is immutable, otherwise false.
    #
    # @example
    #   ObjectTools.immutable?(nil)
    #   #=> true
    #
    #   ObjectTools.immutable?(false)
    #   #=> true
    #
    #   ObjectTools.immutable?(0)
    #   #=> true
    #
    #   ObjectTools.immutable?(:hello)
    #   #=> true
    #
    #   ObjectTools.immutable?('Greetings, programs!')
    #   #=> true
    #
    #   ObjectTools.immutable?(+'Greetings, programs!')
    #   #=> false
    #
    #   ObjectTools.immutable?([1, 2, 3])
    #   #=> false
    #
    #   ObjectTools.immutable?([1, 2, 3].freeze)
    #   #=> false
    #
    # @see #mutable?
    #
    # @see ArrayTools#immutable?
    #
    # @see HashTools#immutable?
    def immutable?(obj)
      case obj
      when NilClass, FalseClass, TrueClass, Numeric, Symbol
        true
      when ->(_) { ArrayTools.array?(obj) }
        ArrayTools.immutable?(obj)
      when ->(_) { HashTools.hash?(obj) }
        HashTools.immutable?(obj)
      else
        obj.frozen?
      end
    end

    # Checks if the object is mutable.
    #
    # @param obj [Object] the object to test.
    #
    # @return [Boolean] true if the object is mutable, otherwise false.
    #
    # @see #immutable?
    def mutable?(obj)
      !immutable?(obj)
    end

    # Returns true if the object is an Object.
    #
    # This should return false only for objects that have an alternate
    # inheritance chain from BasicObject, such as a Proxy.
    #
    # @param obj [Object] the object to test.
    #
    # @return [Boolean] true if the object is an Object, otherwise false.
    #
    # @example
    #   ObjectTools.object?(nil)
    #   #=> true
    #
    #   ObjectTools.object?([])
    #   #=> true
    #
    #   ObjectTools.object?({})
    #   #=> true
    #
    #   ObjectTools.object?(1)
    #   #=> true
    #
    #   ObjectTools.object?(BasicObject.new)
    #   #=> false
    def object?(obj)
      Object.instance_method(:is_a?).bind(obj).call(Object)
    end

    # @overload try(obj, method_name, *args)
    #   As #send, but returns nil if the object does not respond to the method.
    #
    #   This method relies on #respond_to?, so methods defined with
    #   method_missing will not be called.
    #
    #   @param obj [Object] the receiver of the message.
    #   @param method_name [String, Symbol] the name of the method to call.
    #   @param args [Array] the arguments to the message.
    #
    #   @return [Object, nil] the return value of the called method, or nil if
    #     the object does not respond to the method.
    #
    #   @example
    #     ObjectTools.try(%w(ichi ni san), :count)
    #     #=> 3
    #
    #     ObjectTools.try(nil, :count)
    #     #=> nil
    def try(obj, method_name, *)
      return obj.try(method_name, *) if obj.respond_to?(:try)

      return nil unless obj.respond_to?(method_name)

      obj.send(method_name, *)
    end

    private

    def fetch_array(ary, index, default = UNDEFINED, &)
      return toolbelt.array_tools.fetch(ary, index, &) if default == UNDEFINED

      toolbelt.array_tools.fetch(ary, index, default, &)
    end

    def fetch_hash(hsh, key, default = UNDEFINED, indifferent_key: false, &)
      if default == UNDEFINED
        return toolbelt.hash_tools.fetch(hsh, key, indifferent_key:, &)
      end

      toolbelt.hash_tools.fetch(hsh, key, default, indifferent_key:, &)
    end

    def handle_invalid_fetch(obj, key, default, &block)
      return block.call(key) if block_given?

      return default unless default == UNDEFINED

      message    = "undefined method #{key.inspect}"
      class_name = Object.instance_method(:class).bind(obj).call&.name
      message   += " for an instance of #{class_name}" if class_name

      raise NoMethodError, message
    end

    def indifferent_get(object, key)
      case key
      when String
        object[key] || object[key.to_sym]
      when Symbol
        object[key] || object[key.to_s]
      else
        object[key]
      end
    end

    def object_responds_to_method?(object, maybe_method_name)
      unless maybe_method_name.is_a?(String) || maybe_method_name.is_a?(Symbol)
        return false
      end

      object.respond_to?(maybe_method_name)
    end

    def with_temporary_method(receiver, method_name, proc)
      metaclass = class << receiver; self; end
      metaclass.send :define_method, method_name, &proc

      yield
    ensure
      metaclass.send :remove_method, method_name
    end
  end
end
