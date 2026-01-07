# frozen_string_literal: true

require 'sleeping_king_studios/tools/messages/strategies'

module SleepingKingStudios::Tools::Messages::Strategies
  # Messaging strategy that refers to an internal Hash of templates.
  class HashStrategy < SleepingKingStudios::Tools::Messages::Strategy
    # Exception raised when parsing the templates input.
    class ParseError < StandardError; end

    # @param templates [Hash] the templates used to generate messages.
    def initialize(templates)
      super()

      unless templates.is_a?(Hash)
        raise ArgumentError, 'templates is not an instance of Hash'
      end

      @templates = flatten_templates(templates).freeze
    end

    # @return [Hash] the templates used to generate messages.
    attr_reader :templates

    private

    def flatten_templates(hsh, scope: nil, templates: {})
      hsh.each do |(key, value)|
        validate_template_key(key, scope:)
        validate_template_value(key, value, scope:)

        local = scope ? "#{scope}.#{key}" : key.to_s

        next if value.nil? || (value.respond_to?(:empty?) && value.empty?)

        next templates[local] = value unless value.is_a?(Hash)

        flatten_templates(value, scope: local, templates:)
      end

      templates
    end

    def template_for(scoped_key, **)
      templates[scoped_key]
    end

    def validate_template_key(key, scope:)
      return if (key.is_a?(String) || key.is_a?(Symbol)) && !key.empty?

      message = 'invalid key in templates'
      message = "#{message}.#{scope}" if scope
      message =
        "#{message} - expected non-empty String or Symbol, got #{key.inspect}"

      raise ParseError, message
    end

    def validate_template_value(key, value, scope:)
      return if value.nil? || value.is_a?(Hash) || value.is_a?(Proc)
      return if value.is_a?(String) || value.is_a?(Symbol)

      message = 'invalid value in templates'
      message = "#{message}.#{scope}" if scope
      message = "#{message}.#{key}"
      message =
        "#{message} - expected Hash, Proc, or String, got #{value.inspect}"

      raise ParseError, message
    end
  end
end
