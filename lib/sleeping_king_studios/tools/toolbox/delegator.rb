# frozen_string_literal: true

require 'sleeping_king_studios/tools/core_tools'
require 'sleeping_king_studios/tools/toolbox'

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/MethodLength
# rubocop:disable Metrics/PerceivedComplexity
module SleepingKingStudios::Tools::Toolbox
  # Module for extending classes with basic delegation. Supports passing
  # arguments, keywords, and blocks to the delegated method.
  #
  # @example
  #   class MyClass
  #     extend SleepingKingStudios::Tools::Delegator
  #
  #     delegate :my_method, :to => MyService
  #   end # class
  module Delegator
    def self.extended(_module)
      super

      SleepingKingStudios::Tools::CoreTools.deprecate(
        'SleepingKingStudios::Tools::Toolbox::Delegator',
        message: 'Use Ruby stdlib Forwardable instead.'
      )
    end

    # Defines a wrapper method to delegate implementation of the specified
    # method or methods to an object, to the object at another specified method,
    # or to the object at a specified instance variable.
    #
    # @example Delegate to an object
    #   class MyModule
    #     extend SleepingKingStudios::Tools::Toolbox::Delegator
    #
    #     delegate :my_method, :to => MyService
    #   end # class
    #
    # @example Delegate to a method
    #   class MyModule
    #     extend SleepingKingStudios::Tools::Toolbox::Delegator
    #
    #     def my_service
    #       MyService.new
    #     end # method my_service
    #
    #     delegate :my_method, :to => :my_service
    #   end # class
    #
    # @example Delegate to an instance variable
    #   class MyModule
    #     extend SleepingKingStudios::Tools::Toolbox::Delegator
    #
    #     def initialize
    #       @my_service = MyService.new
    #     end # constructor
    #
    #     delegate :my_method, :to => :@my_service
    #   end # class
    #
    # @param method_names [Array<String, Symbol>] The names of the methods to
    #   delegate.
    # @param to [Object, String, Symbol] The object, method, or instance
    #   variable to delegate to. If the object is not a string or symbol, the
    #   generated method will call `method_name` on the object. If the object is
    #   a string or symbol, but does not start with an `@`, the generated method
    #   will call the method of that name on the instance, and then call
    #   `method_name` on the result. If the object is a string or symbol and
    #   does start with an `@`, the generated method will get the instance
    #   variable of that name and call `method_name` on the result.
    #
    # @raise ArgumentError if no delegate is specified.
    def delegate(*method_names, to: nil, allow_nil: false)
      raise ArgumentError, 'must specify a delegate' if to.nil? && !allow_nil

      method_names.each do |method_name|
        delegate_method method_name, to, { allow_nil: !!allow_nil }
      end
    end

    # Wraps a delegate object by automatically delegating each method that is
    # defined on the delegate class from the instance to the delegate. The
    # delegate can be specified with an object literal or with the name of an
    # instance method or instance variable.
    #
    # Only methods that are defined at the time #wrap_delegate is called will be
    # delegated, so make sure to call #wrap_delegate after loading any gems or
    # libraries that extend your delegate class, such as ActiveSupport.
    #
    # @example Create a class that wraps a Hash
    #   class Errors
    #     extend SleepingKingStudios::Tools::Delegator
    #
    #     wrap_delegate(
    #       Hash.new { |hsh, key| hsh[key] = Errors.new },
    #       :klass => Hash
    #     )
    #
    #     def messages
    #       @messages ||= []
    #     end # method messages
    #   end # class
    #
    #   errors = Errors.new
    #   errors[:post].messages << "title can't be blank"
    #
    # @param target [Object, String, Symbol] The object, method, or instance
    #   variable to delegate to. If the object is not a string or symbol, the
    #   generated method will call each method on the object. If the object is
    #   a string or symbol, but does not start with an `@`, the generated method
    #   will call the method of that name on the instance, and then call
    #   each method on the result. If the object is a string or symbol and
    #   does start with an `@`, the generated method will get the instance
    #   variable of that name and call each method on the result.
    # @param klass [Module] The class or module whose methods are delegated to
    #   the target. If target is the name of an instance variable or an instance
    #   method, the klass must be specified. If target is an object literal, the
    #   klass is optional, in which case all methods from the target will be
    #   delegated to the target.
    # @param except [Array<String, Symbol>] An optional list of method names.
    #   Any names on the list will not be delegated, even if the method is
    #   defined by the klass or defined on the target literal.
    # @param only [Array<String, Symbol>] An optional list of method names.
    #   Only names on the list will be delegated, and only if the method is
    #   defined by the klass or defined on the target literal.
    #
    # @raise ArgumentError if no delegate is specified.
    # @raise ArgumentError if the target is the name of an instance method or an
    #   instance variable and no klass is specified.
    # @raise ArgumentError if the target is an object literal that does not
    #   belong to the specified klass.
    #
    # @see #delegate
    def wrap_delegate(target, klass: nil, except: [], only: [])
      if klass.is_a?(Module)
        unless target.is_a?(String) ||
               target.is_a?(Symbol) ||
               target.is_a?(klass)
          raise ArgumentError, "expected delegate to be a #{klass.name}"
        end

        method_names = klass.instance_methods - Object.instance_methods
      elsif target.is_a?(String) || target.is_a?(Symbol)
        raise ArgumentError, 'must specify a delegate class'
      else
        method_names = target.methods - Object.new.methods
      end

      if except.is_a?(Array) && !except.empty?
        method_names -= except.map(&:intern)
      end

      method_names &= only.map(&:intern) if only.is_a?(Array) && !only.empty?

      delegate(*method_names, to: target)
    end

    private

    def delegate_method(method_name, target, options = {})
      if target.is_a?(String) || target.is_a?(Symbol)
        target = target.intern

        if target.to_s =~ /\A@/
          define_method method_name do |*args, &block|
            receiver = instance_variable_get(target)

            return nil if receiver.nil? && options[:allow_nil]

            receiver.send(method_name, *args, &block)
          end
        else
          define_method method_name do |*args, &block|
            receiver = send(target)

            return nil if receiver.nil? && options[:allow_nil]

            receiver.send(method_name, *args, &block)
          end
        end
      else
        define_method method_name do |*args, &block|
          return nil if target.nil? && options[:allow_nil]

          target.send(method_name, *args, &block)
        end
      end
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/PerceivedComplexity
