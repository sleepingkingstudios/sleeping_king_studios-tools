# frozen_string_literal: true

require 'sleeping_king_studios/tools/messages/strategies'

module SleepingKingStudios::Tools::Messages::Strategies
  # Messaging strategy that refers to an internal Hash of templates.
  #
  # Internally, the templates Hash is flattened - a nested Hash of
  # { foo: { bar: { baz: 'template' } } } is stored as a flat Hash with
  # { 'foo.bar.baz' => 'template' }. This makes lookup of scoped keys more
  # efficient but prevents retrieving non-leaf nodes (such as "foo" or "foo.bar"
  # in the above Hash). If you need to retrieve Hash values, initialize the
  # strategy with flatten_templates: false.
  class HashStrategy < SleepingKingStudios::Tools::Messages::Strategy
    # Exception raised when parsing the templates input.
    class ParseError < StandardError; end

    VALID_TEMPLATE_VALUES = [Proc, String, Symbol].freeze
    private_constant :VALID_TEMPLATE_VALUES

    # @overload initialize(templates, **options)
    #   @param templates [Hash] the templates used to generate messages.
    #   @param options [Hash] additional options for the strategy.
    #
    #   @option options flatten_templates [true, false] if true, the templates
    #     are flattened internally. Defaults to true.
    #   @option options validate_values [Proc, true, false] if false, skips
    #     validation of template values. If given a Proc, calls the Proc with
    #     each template value; the value fails validation if the Proc returns
    #     an error message. Defaults to true.
    def initialize(templates, flatten_templates: true, validate_values: true)
      super()

      unless templates.is_a?(Hash)
        raise ArgumentError, 'templates is not an instance of Hash'
      end

      @flatten_templates = flatten_templates
      @validate_values   = validate_values
      @templates         = self.flatten_templates(templates).freeze
    end

    # @return [Hash] the templates used to generate messages.
    attr_reader :templates

    private

    def convert_keys_to_strings(hsh, scope: nil) # rubocop:disable Metrics/MethodLength
      hsh
        .to_h do |key, value|
          validate_template_key(key, scope:)

          if value.is_a?(Hash)
            local = scope ? "#{scope}.#{key}" : key.to_s

            value = convert_keys_to_strings(value, scope: local)
          else
            validate_template_value(key, value, scope:)
          end

          [key.to_s, value]
        end
        .freeze
    end

    def flatten_templates(hsh, scope: nil, templates: {}) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      return convert_keys_to_strings(hsh, scope:) unless flatten_templates?

      hsh.each do |(key, value)|
        validate_template_key(key, scope:)

        next if value.nil? || (value.respond_to?(:empty?) && value.empty?)

        local = scope ? "#{scope}.#{key}" : key.to_s

        if value.is_a?(Hash)
          next flatten_templates(value, scope: local, templates:)
        end

        validate_template_value(key, value, scope:)

        templates[local] = value
      end

      templates
    end

    def flatten_templates? = @flatten_templates

    def template_for(scoped_key, **)
      return templates[scoped_key] if flatten_templates?

      templates.dig(*scoped_key.split('.'))
    end

    def template_value_error(value)
      return unless @validate_values

      return @validate_values.call(value) if @validate_values.is_a?(Proc)

      return if VALID_TEMPLATE_VALUES.any? { |klass| value.is_a?(klass) }

      'value is not a String or a Proc'
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
      error_message = template_value_error(value)

      return if error_message.nil?

      message = 'invalid value in templates'
      message = "#{message}.#{scope}" if scope
      message = "#{message}.#{key} - #{error_message}, got #{value.inspect}"

      raise ParseError, message
    end
  end
end
