# frozen_string_literal: true

require 'set'

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Tools for working with an application or working environment.
  class CoreTools < Base
    # Exception raised when deprecated code is called with strategy 'raise'.
    class DeprecationError < StandardError; end

    DEPRECATION_STRATEGIES = Set.new(%w[ignore raise warn]).freeze
    private_constant :DEPRECATION_STRATEGIES

    class << self
      def_delegators :instance,
        :deprecate,
        :empty_binding,
        :require_each

      # @return [Set] the permitted deprecation strategies for the tool.
      def deprecation_strategies = DEPRECATION_STRATEGIES
    end

    # @param deprecation_caller_depth [Integer] the number of backtrace lines to
    #   display when outputting a deprecation warning.
    # @param deprecation_strategy [String] the name of the strategy used when
    #   deprecated code is called. Must be 'ignore', 'raise', or 'warn'.
    def initialize(
      deprecation_caller_depth: nil,
      deprecation_strategy:     nil
    )
      super()

      @deprecation_caller_depth =
        deprecation_caller_depth ||
        ENV.fetch('DEPRECATION_CALLER_DEPTH', '3').to_i
      @deprecation_strategy =
        deprecation_strategy&.to_s || ENV.fetch('DEPRECATION_STRATEGY', 'warn')

      validate_deprecation_strategy(@deprecation_strategy)
    end

    # @return [Integer] the number of backtrace lines to display when outputting
    #   a deprecation warning.
    attr_reader :deprecation_caller_depth

    # @return [String] the current deprecation strategy.
    attr_reader :deprecation_strategy

    # Prints a deprecation warning or raises an exception.
    #
    # The behavior of this method depends on the configured deprecation
    # strategy, which can be passed to the constructor or configured using the
    # DEPRECATION_STRATEGY environment variable.
    #
    # - If the strategy is 'warn' (the default), the formatted message is passed
    #   to Kernel.warn, which prints the message to $stderr.
    # - If the strategy is 'raise', raises a DeprecationError with the message.
    # - If the strategy is 'ignore', this method does nothing.
    #
    # @example
    #   CoreTools.deprecate 'ObjectTools#old_method'
    #   #=> prints to stderr:
    #   #
    #   #   [WARNING] ObjectTools#old_method is deprecated.
    #   #       called from /path/to/file.rb:4: in something_or_other
    #
    # @example With An Additional Message
    #   CoreTools.deprecate 'ObjectTools#old_method',
    #     'Use #new_method instead.'
    #   #=> prints to stderr:
    #   #
    #   #   [WARNING] ObjectTools#old_method is deprecated. Use #new_method instead.
    #   #     called from /path/to/file.rb:4: in something_or_other
    #
    # @example With A Format String
    #   CoreTools.deprecate 'ObjectTools#old_method',
    #     '0.1.0',
    #     format: '%s was deprecated in version %s.'
    #   #=> prints to stderr:
    #   #
    #   #   ObjectTools#old_method was deprecated in version 0.1.0.
    #   #     called from /path/to/file.rb:4: in something_or_other
    #
    # @overload deprecate(name, message: nil)
    #   Prints a deprecation warning or raises an exception.
    #
    #   @param name [String] the name of the object, method, or feature that
    #     has been deprecated.
    #   @param message [String] an optional message to print after the formatted
    #     string. Defaults to nil.
    #
    # @overload deprecate(*args, format:, message: nil)
    #   Prints a deprecation warning with the specified format or raises.
    #
    #   @param args [Array] the arguments to pass into the format string.
    #   @param format [String] the format string.
    #   @param message [String] an optional message to print after the formatted
    #     string. Defaults to nil.
    def deprecate(*args, format: nil, message: nil)
      case deprecation_strategy
      when 'ignore'
        # Do nothing.
      when 'raise'
        deprecate_with_exception(*args, format:, message:)
      when 'warn'
        deprecate_with_warning(*args, format:, message:)
      end
    end

    # Generates an empty Binding object with an Object as the receiver.
    #
    # @return [Binding] The empty binding object.
    def empty_binding
      Object.new.instance_exec { binding }
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

    def deprecate_with_exception(*args, format: nil, message: nil)
      format ||= '%s has been deprecated.'

      str = format % args
      str << ' ' << message if message

      raise DeprecationError, str, caller(2..-1)
    end

    def deprecate_with_warning(*args, format: nil, message: nil)
      format ||= '[WARNING] %s has been deprecated.'

      str = format % args
      str << ' ' << message if message
      str << format_caller

      Kernel.warn str
    end

    def format_caller
      lines = caller
      start = lines.find_index do |line|
        !line.include?('forwardable.rb') &&
          !line.include?('sleeping_king_studios-tools')
      end

      lines[start...(start + deprecation_caller_depth)]
        .map { |line| "\n  called from #{line}" }
        .join
    end

    def validate_deprecation_strategy(strategy)
      return if self.class.deprecation_strategies.include?(strategy.to_s)

      message =
        "invalid deprecation strategy #{strategy.inspect} - valid options " \
        "are #{self.class.deprecation_strategies.map(&:inspect).join(', ')}"
      raise ArgumentError, message
    end
  end
end
