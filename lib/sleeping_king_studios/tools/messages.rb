# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Utility for generating configured, user-readable output strings.
  class Messages < Base
    autoload :Registry,   'sleeping_king_studios/tools/messages/registry'
    autoload :Strategies, 'sleeping_king_studios/tools/messages/strategies'
    autoload :Strategy,   'sleeping_king_studios/tools/messages/strategy'

    UNDEFINED = SleepingKingStudios::Tools::UNDEFINED
    private_constant :UNDEFINED

    # @param registry [SleepingKingStudios::Tools::Messages::Registry] the
    #   strategies registry to use for the tool. Defaults to the value of
    #   Registry.global.
    # @param toolbelt [SleepingKingStudios::Tools::Toolbelt] the toolbelt this
    #   tools instance belongs to.
    def initialize(registry:, toolbelt: nil)
      super(toolbelt:)

      @registry =
        registry || SleepingKingStudios::Tools::Messages::Registry.global
    end

    # @return [SleepingKingStudios::Tools::Messages::Registry] the strategies
    #   registry to use for the tool.
    attr_reader :registry

    # @overload message(key, parameters: {}, scope: nil, **options)
    #   Generates a message from the given key, scope, and parameters.
    #
    #   Internally, finds a messages strategy matching the combined key and
    #   scope and calls that strategy.
    #
    #   If a strategy is not found, or if the strategy does not define a message
    #   for the key, you can provide a default value.
    #
    #   - If the default value is a Proc, it will be called with the fully
    #     scoped key, as a positional argument as well as any additional
    #     keywords passed to #call. The value returned by the Proc will be
    #     returned by #call.
    #   - If the default value is any other Object (including nil), the default
    #     value will be returned by #call.
    #   - If a default value is not provided, a missing message warning will be
    #     generated and returned.
    #
    #   @param key [String, Symbol] the key used to resolve the message.
    #   @param default [Object] the default value to return if there is no
    #     defined registry for the message, or if the strategy does not define a
    #     message for the key.
    #   @param parameters [Hash] the parameters used to generate the message,
    #     such as values for a template string.
    #   @param scope [String] the namespace for the key. Combined with the given
    #     key to generate the scoped key value.
    #   @param options [Hash] additional options for resolving or generating the
    #     message.
    def message(key, default: UNDEFINED, parameters: {}, scope: nil, **)
      scoped_key = join_scope(key:, scope:)
      strategy   = registry.get(scoped_key)

      return apply_default(scoped_key, default, **) unless strategy

      strategy.call(key, default:, parameters:, scope:, **)
    end

    private

    def apply_default(key, default, **)
      return missing_message(key, **) if default == UNDEFINED

      return default unless default.is_a?(Proc)

      default.call(key, **)
    end

    def missing_message(scoped_key, **)
      "Message missing: #{scoped_key}"
    end

    def join_scope(key:, scope:)
      validate_key(key)

      return key if scope.nil? || scope.empty?

      "#{scope}.#{key}"
    end

    def validate_key(maybe_key)
      raise ArgumentError, "key can't be blank" if maybe_key.nil?

      unless maybe_key.is_a?(String) || maybe_key.is_a?(Symbol)
        raise ArgumentError, 'key is not a String or a Symbol'
      end

      raise ArgumentError, "key can't be blank" if maybe_key.empty?
    end
  end
end
