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

    # Data class representing a single node in the registry tree.
    Node = Struct.new(:children, :scope, :strategy) do
      # @param scope [String] the scope for the registry node.
      # @param strategy [SleepingKingStudios::Tools::Messages::Strategy] the
      #   strategy defined for the node, if any.
      def initialize(scope:, strategy: nil)
        super(children: {}, scope:, strategy:)
      end

      # Retrieves the child node with the requested sub-path, if any.
      #
      # @param segment [String] the sub-path for the requested child.
      #
      # @return [SleepingKingStudios::Tools::Messages::Registry::Node, nil] the
      #   child node, or nil if there is no node defined at that sub-path.
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

    # @overload register(scope:, strategy:, force: false)
    #   Adds a strategy to the registry with the given scope.
    #
    #   @param scope [String] the scope for the strategy.
    #   @param strategy [SleepingKingStudios::Tools::Messages::Strategy] the
    #     strategy to register.
    #   @param force [true, false] if true, overrides an existing strategy with
    #     the given scope. Defaults to false.
    #
    #   @return [self] the registry.
    #
    # @overload register(scope:, hash:, force: false)
    #
    # @overload register(scope:, file:, force: false)
    def register(scope:, force: false, **)
      validate_scope(scope)

      strategy = resolve_strategy(**)

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

    def resolve_strategy(**options)
      return options[:strategy] if options.key?(:strategy)

      namespace = SleepingKingStudios::Tools::Messages::Strategies

      return namespace::FileStrategy.new(options[:file]) if options.key?(:file)
      return namespace::HashStrategy.new(options[:hash]) if options.key?(:hash)

      raise ArgumentError, 'missing keyword: :strategy'
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
