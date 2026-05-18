# frozen_string_literal: true

require 'sleeping_king_studios/tools/messages'

module SleepingKingStudios::Tools
  # Abstract class for converting parameterized keys to user-readable messages.
  class Messages::Strategy
    UNDEFINED = SleepingKingStudios::Tools::UNDEFINED
    private_constant :UNDEFINED

    # @overload call(key, parameters: {}, scope: nil, **options)
    #   Generates a formatted string for the given key, parameters, and options.
    #
    #   If the strategy does not define a message for the key, you can provide a
    #   default value.
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
    #   @param default [Object] the default value to return if the strategy does
    #     not define a message for the key.
    #   @param parameters [Hash] the parameters used to generate the message,
    #     such as values for a template string.
    #   @param scope [String] the namespace for the key. Combined with the given
    #     key to generate the scoped key value.
    #   @param options [Hash] additional options for resolving or generating the
    #     message.
    #
    #   @return [String] the generated template string, or a generic error
    #     string if a message is not defined for the given key and parameters.
    def call(key, default: UNDEFINED, parameters: {}, scope: nil, **)
      scoped_key = join_scope(key:, scope:)
      template   = template_for(scoped_key, **)

      return apply_default(scoped_key, default, **) unless template

      generate(template, parameters:, scoped_key:, **)
    end

    private

    def apply_default(key, default, **)
      return missing_message(key, **) if default == UNDEFINED

      return default unless default.is_a?(Proc)

      default.call(key, **)
    end

    def generate(template, scoped_key: nil, parameters: {}, **) # rubocop:disable Metrics/MethodLength
      raise ArgumentError, "template can't be blank" if template.nil?

      case template
      when String
        format(template, parameters)
      when Proc
        template.call(parameters:, **)
      else
        raise ArgumentError, "invalid template #{template.inspect}"
      end
    rescue KeyError => exception
      missing_parameters_message(scoped_key, exception:, **)
    end

    def join_scope(key:, scope:)
      validate_key(key)

      return key.to_s if scope.nil? || scope.empty?

      "#{scope}.#{key}"
    end

    def missing_message(scoped_key, **)
      "Message missing: #{scoped_key}"
    end

    def missing_parameters_message(scoped_key, exception:, **)
      "Message missing parameters: #{scoped_key} #{exception.message}"
    end

    def template_for(_scoped_key, **)
      nil
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
