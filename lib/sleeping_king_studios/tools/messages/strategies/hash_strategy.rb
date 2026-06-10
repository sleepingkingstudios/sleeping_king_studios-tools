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

    # @param templates [Hash] the templates used to generate messages.
    # @param flatten_templates [true, false] if true, the templates are
    #   flattened internally. Defaults to true.
    def initialize(templates, flatten_templates: true)
      super()

      unless templates.is_a?(Hash)
        raise ArgumentError, 'templates is not an instance of Hash'
      end

      @flatten_templates = flatten_templates
      @templates         = self.flatten_templates(templates).freeze
    end

    # @return [Hash] the templates used to generate messages.
    attr_reader :templates

    private

    def convert_keys_to_strings(hsh)
      hsh
        .to_h do |key, value|
          value = convert_keys_to_strings(value) if value.is_a?(Hash)

          [key.to_s, value]
        end
        .freeze
    end

    def flatten_templates(hsh, scope: nil, templates: {}) # rubocop:disable Metrics/CyclomaticComplexity
      return convert_keys_to_strings(hsh) unless flatten_templates?

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

    def flatten_templates? = @flatten_templates

    def template_for(scoped_key, **)
      return templates[scoped_key] if flatten_templates?

      templates.dig(*scoped_key.split('.'))
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
