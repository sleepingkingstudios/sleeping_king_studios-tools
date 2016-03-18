# lib/sleeping_king_studios/tools/delegator.rb

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Module for extending classes with basic delegation. Supports passing
  # arguments, keywords, and blocks to the delegated method.
  #
  # @example
  #   class MyModule
  #     extend SleepingKingStudios::Tools::Delegator
  #
  #     delegate :my_method, :to => MyService
  #   end # class
  module Delegator
    # Defines a wrapper method to delegate implementation of the specified
    # method or methods to an object, to the object at another specified method,
    # or to the object at a specified instance variable.
    #
    # @example Delegate to an object
    #   class MyModule
    #     extend SleepingKingStudios::Tools::Delegator
    #
    #     delegate :my_method, :to => MyService
    #   end # class
    #
    # @example Delegate to a method
    #   class MyModule
    #     extend SleepingKingStudios::Tools::Delegator
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
    #     extend SleepingKingStudios::Tools::Delegator
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
    # @raise ArgumentError if no delegate is specified.
    def delegate *method_names, to: nil, allow_nil: false
      raise ArgumentError.new('must specify a delegate') if to.nil? && !allow_nil

      method_names.each do |method_name|
        delegate_method method_name, to, { :allow_nil => !!allow_nil }
      end # each
    end # method delegate

    private

    def delegate_method method_name, target, options = {}
      if target.is_a?(String) || target.is_a?(Symbol)
        target = target.intern

        if target.to_s =~ /\A@/
          define_method method_name do |*args, **kwargs, &block|
            target = instance_variable_get(target)

            return nil if target.nil? && options[:allow_nil]

            kwargs.empty? ?
              target.send(method_name, *args, &block) :
              target.send(method_name, *args, **kwargs, &block)
          end # define_method
        else
          define_method method_name do |*args, **kwargs, &block|
            target = send(target)

            return nil if target.nil? && options[:allow_nil]

            kwargs.empty? ?
              target.send(method_name, *args, &block) :
              target.send(method_name, *args, **kwargs, &block)
          end # define_method
        end # if-else
      else
        define_method method_name do |*args, **kwargs, &block|
          return nil if target.nil? && options[:allow_nil]

          kwargs.empty? ?
            target.send(method_name, *args, &block) :
            target.send(method_name, *args, **kwargs, &block)
        end # define_method
      end # if
    end # method delegate_method
  end # module
end # module
