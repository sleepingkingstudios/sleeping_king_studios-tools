# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Tools for working with an application or working environment.
  class CoreTools < Base
    class DeprecationError < StandardError; end

    class << self
      def_delegators :instance,
        :deprecate,
        :empty_binding,
        :require_each
    end

    def initialize(deprecation_strategy: nil)
      super()

      @deprecation_strategy =
        deprecation_strategy || ENV.fetch('DEPRECATION_STRATEGY', 'warn')
    end

    # @return [String] The current deprecation strategy.
    attr_reader :deprecation_strategy

    # @overload deprecate(name, message: nil)
    #   Prints a deprecation warning.
    #
    #   @param name [String] The name of the object, method, or feature that
    #     has been deprecated.
    #   @param message [String] An optional message to print after the formatted
    #     string. Defaults to nil.
    #
    # @overload deprecate(*args, format:, message: nil)
    #   Prints a deprecation warning with the specified format.
    #
    #   @param args [Array] The arguments to pass into the format string.
    #   @param format [String] The format string.
    #   @param message [String] An optional message to print after the formatted
    #     string. Defaults to nil.
    def deprecate(*args, format: nil, message: nil)
      send(
        :"deprecate_as_#{deprecation_strategy}",
        *args,
        format:  format,
        message: message
      )
    end

    # Generates an empty Binding object with a BasicObject as the receiver.
    #
    # @return [Binding] The empty binding object.
    def empty_binding
      context = Object.new

      def context.binding
        Kernel.instance_method(:binding).bind(self).call
      end

      context.binding
    end

    # Expands each file pattern and requires each file.
    #
    # @param file_patterns [Array] The files to require.
    def require_each(*file_patterns)
      file_patterns.each do |file_pattern|
        if file_pattern.include?('*')
          Dir[file_pattern].each do |file_name|
            Kernel.require file_name
          end
        else
          Kernel.require file_pattern
        end
      end
    end

    private

    def deprecate_as_ignore(*_args, **_kwargs); end

    def deprecate_as_raise(*args, format: nil, message: nil)
      format ||= '%s has been deprecated.'

      str = format % args
      str << ' ' << message if message

      raise DeprecationError, str, caller(2..-1)
    end

    def deprecate_as_warn(*args, format: nil, message: nil)
      format ||= '[WARNING] %s has been deprecated.'

      str = format % args
      str << ' ' << message if message

      str << "\n  called from #{external_caller}"

      Kernel.warn str
    end

    def external_caller
      caller.find do |line|
        !(
          line.include?('forwardable.rb') ||
          line.include?('sleeping_king_studios-tools')
        )
      end
    end
  end
end
