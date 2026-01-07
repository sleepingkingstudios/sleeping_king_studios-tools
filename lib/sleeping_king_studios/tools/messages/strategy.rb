# frozen_string_literal: true

require 'sleeping_king_studios/tools/messages'

module SleepingKingStudios::Tools
  # Abstract class for converting parameterized keys to user-readable messages.
  class Messages::Strategy
    # @overload call(key, parameters: {}, scope: nil, **options)
    #   Generates a formatted string for the given key, parameters, and options.
    #
    #   @param key [String, Symbol] the key used to resolve the message.
    #   @param parameters [Hash] the parameters used to generate the message,
    #     such as values for a template string.
    #   @param scope [String] the namespace for the key. Combined with the given
    #     key to generate the scoped key value.
    #   @param options [Hash] additional options for resolving or generating the
    #     message.
    #
    #   @return [String] the generated template string, or a generic error
    #     string if a message is not defined for the given key and parameters.
    def call(key, parameters: {}, scope: nil, **)
      scoped_key = join_scope(key:, scope:)
      template   = template_for(scoped_key, **)

      return missing_message(scoped_key, **) unless template

      generate(template, parameters:, **)
    end

    private

    def generate(template, parameters: {}, **)
      raise ArgumentError, "template can't be blank" if template.nil?

      case template
      when String
        format(template, parameters)
      when Proc
        template.call(parameters:, **)
      else
        raise ArgumentError, "invalid template #{template.inspect}"
      end
    end

    def join_scope(key:, scope:)
      validate_key(key)

      return key.to_s if scope.nil? || scope.empty?

      "#{scope}.#{key}"
    end

    def missing_message(scoped_key, **)
      "Message missing: #{scoped_key}"
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
