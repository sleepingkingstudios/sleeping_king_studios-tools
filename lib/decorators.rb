# frozen_string_literal: true

require 'benchmark/ips'

class Decorator
  def call(next_function, *args, **kwargs, &block)
    next_function.call(*args, **kwargs, &block)
  end
end

class LogDecorator < Decorator
  class << self
    attr_accessor :log_counter
  end

  def call(next_function, *args, **kwargs, &block)
    LogDecorator.log_counter += 1

    super
  end
end

class MemoizeDecorator < Decorator
  class << self
    attr_accessor :memoize_counter
  end

  def call(next_function, *args, **kwargs, &block)
    MemoizeDecorator.memoize_counter += 1

    super
  end
end

class DecoratedMethod
  def initialize(callable:, decorators:)
    @callable   = callable
    @decorators = decorators
  end

  attr_reader :callable

  attr_reader :decorators

  def call(receiver, *args, **kwargs, &block)
    apply_decorators(receiver).call(*args, **kwargs, &block)
  end

  private

  def apply_decorators(receiver)
    bound_method = callable.bind(receiver)

    decorators.reduce(bound_method) do |applied_method, decorator|
      lambda do |*args, **kwargs, &block|
        decorator.call(applied_method, *args, **kwargs, &block)
      end
    end
  end
end

module Decoration
  module ClassMethods
    def decorate(decorator)
      buffered_decorators << decorator
    end

    # @api private
    def method_added(method_name)
      super

      return if buffered_decorators.empty?

      decorated = DecoratedMethod.new(
        callable:   instance_method(method_name),
        decorators: buffered_decorators
      )

      decorated_methods.define_method(method_name) do |*args, **kwargs, &block|
        decorated.call(self, *args, **kwargs, &block)
      end

      @buffered_decorators = []
    end

    private

    def buffered_decorators
      @buffered_decorators ||= []
    end

    def decorated_methods
      return self::DecoratedMethods if const_defined?(:DecoratedMethods, false)

      decorated_methods = Module.new

      const_set(:DecoratedMethods, decorated_methods)

      prepend(decorated_methods)

      self::DecoratedMethods
    end
  end

  # @api private
  def self.included(other)
    super

    other.extend(ClassMethods)
  end
end

class Rocket
  include Decoration

  class << self
    attr_accessor :abort_counter

    attr_accessor :launch_counter
  end

  def initialize(name)
    @name = name
  end

  attr_reader :name

  decorate LogDecorator.new
  decorate MemoizeDecorator.new
  def launch
    sleep 0.01

    Rocket.launch_counter += 1
  end

  def abort
    LogDecorator.log_counter += 1

    sleep 0.01

    Rocket.abort_counter += 1
  end
end

LogDecorator.log_counter = 0
MemoizeDecorator.memoize_counter = 0
Rocket.abort_counter = 0
Rocket.launch_counter = 0

rocket = Rocket.new('Hellhound I')
unbound = Rocket.instance_method(:abort)

Benchmark.ips do |x|
  x.report('baseline') { rocket.abort }
  x.report('rebound') { unbound.bind(rocket).call }
  x.report('decorated') { rocket.launch }
end
