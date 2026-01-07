# frozen_string_literal: true

require 'sleeping_king_studios/tools/messages'

module SleepingKingStudios::Tools
  # Matches defined message strategies by message scope.
  class Messages::Registry
    # Exception raised when registering a strategy for an existing scope.
    class StrategyAlreadyExistsError < StandardError; end

    class << self
      semaphore = Thread::Mutex.new

      # @!method global()
      #   Returns a singleton instance of the messages registry, instantiating
      #   the instance if needed.
      #
      #   @return [Registry] the messages registry singleton.
      define_method :global do
        semaphore.synchronize { @global ||= new }
      end
    end

    Node = Struct.new(:children, :scope, :strategy, keyword_init: true) do
      def initialize(scope:, strategy: nil)
        super(children: {}, scope:, strategy:)
      end

      def [](segment)
        children[segment]
      end
    end
    private_constant :Node

    def initialize
      @strategies = {}
      @root       = Node.new(scope: :root)
    end

    # Returns the strategy matching the given scope or key.
    #
    # The returned strategy will match the longest defined scope that matches
    # the given key.
    #
    # @param scope [String] the requested scope or key.
    #
    # @return [SleepingKingStudios::Tools::Messages::Strategy, nil] the matching
    #   strategy, or nil if no strategy matches the given scope or key.
    def get(scope)
      validate_scope(scope)

      node     = root
      strategy = nil

      scope.to_s.split('.').each do |segment|
        node = node[segment]

        break if node.nil?

        strategy = node.strategy if node.strategy
      end

      strategy
    end
    alias [] get

    # Adds a strategy to the registry with the given scope.
    #
    # @param scope [String] the scope for the strategy.
    # @param strategy [SleepingKingStudios::Tools::Messages::Strategy] the
    #   strategy to register.
    # @param force [true, false] if true, overrides an existing strategy with
    #   the given scope. Defaults to false.
    #
    # @return [self] the registry.
    def register(scope:, strategy:, force: false)
      validate_scope(scope)

      if strategies.key?(scope.to_s) && !force
        raise StrategyAlreadyExistsError,
          "strategy already exists with scope #{scope}"
      end

      @strategies[scope.to_s] = strategy

      add_node(scope:, strategy:)

      self
    end
    alias add register

    # @return [Hash] the registered strategies for the registry.
    def strategies
      @strategies.dup.freeze
    end

    private

    attr_reader :root

    def add_node(scope:, strategy:)
      leaf = scope.split('.').reduce(root) do |node, segment|
        node.children[segment] ||= Node.new(scope: segment)
      end

      leaf.strategy = strategy
    end

    def validate_scope(scope)
      raise ArgumentError, "scope can't be blank" if scope.nil?

      unless scope.is_a?(String) || scope.is_a?(Symbol)
        raise ArgumentError, 'scope is not a String or a Symbol'
      end

      return unless scope.empty?

      raise ArgumentError, "scope can't be blank"
    end
  end
end
