# frozen_string_literal: true

require 'sleeping_king_studios/tools/assertions'

module SleepingKingStudios::Tools
  # Utility for grouping multiple assertion statements.
  #
  # @example
  #   rocket = Struct.new(:fuel, :launched).new(0.0, true)
  #   aggregator = SleepingKingStudios::Tools::Assertions::Aggregator.new
  #   aggregator.empty?
  #   #=> true
  #
  #   aggregator.assert(message: 'is out of fuel') { rocket.fuel > 0 }
  #   aggregator.assert(message: 'has already launched') { !rocket.launched }
  #   aggregator.empty?
  #   #=> false
  #   aggregator.failure_message
  #   #=> 'is out of fuel, has already launched'
  class Assertions::Aggregator < Assertions
    extend Forwardable

    def initialize
      super

      @failures = []
    end

    # @!method <<(message)
    #   Appends the message to the failure messages.
    #
    #   @param message [String] the message to append.
    #
    #   @return [Array] the updated failure messages.
    #
    #   @see Array#<<.

    # @!method clear
    #   Removes all items from the failure messages.
    #
    #   @return [Array] the empty failure messages.
    #
    #   @see Array#clear.

    # @!method count
    #   Returns a count of the failure message.
    #
    #   @return [Integer] the number of failure messages.
    #
    #   @see Array#count.

    # @!method each
    #   Iterates over the failure messages.
    #
    #   @overload each
    #     Returns an enumerator that iterates over the failure messages.
    #
    #     @return [Enumerator] an enumerator over the messages.
    #
    #     @see Enumerable#each.
    #
    #   @overload each(&block)
    #     Yields each failure message to the block.
    #
    #     @yieldparam message [String] the current failure message.
    #
    #     @see Enumerable#each.

    # @!method empty?
    #   Checks if there are any failure messages.
    #
    #   @return [true, false] true if there are no failure messages; otherwise
    #     false.
    #
    #   @see Enumerable#empty?

    # @!method size
    #   Returns a count of the failure message.
    #
    #   @return [Integer] the number of failure messages.
    #
    #   @see Array#size.
    def_delegators :@failures,
      :<<,
      :clear,
      :count,
      :each,
      :empty?,
      :size

    # (see SleepingKingStudios::Tools::Assertions#assert_group)
    def assert_group(error_class: AssertionError, message: nil, &assertions)
      return super if message

      raise ArgumentError, 'no block given' unless block_given?

      assertions.call(self)
    end
    alias aggregate assert_group

    # Generates a combined failure message from the configured messages.
    #
    # @return [String] the combined messages for each failed assertion.
    #
    # @example With an empty aggregator.
    #   aggregator = SleepingKingStudios::Tools::Assertions::Aggregator.new
    #
    #   aggregator.failure_message
    #   #=> ''
    #
    # @example With an aggregator with failure messages.
    #   aggregator = SleepingKingStudios::Tools::Assertions::Aggregator.new
    #   aggrgator << 'rocket is out of fuel'
    #   aggrgator << 'rocket is not pointed toward space'
    #
    #   aggregator.failure_message
    #   #=> 'rocket is out of fuel, rocket is not pointed toward space'
    def failure_message
      failures.join(', ')
    end

    private

    attr_reader :failures

    def handle_error(message:, **_)
      failures << message

      message
    end
  end
end
