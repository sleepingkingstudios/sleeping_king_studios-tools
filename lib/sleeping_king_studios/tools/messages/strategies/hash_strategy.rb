# frozen_string_literal: true

require 'sleeping_king_studios/tools/messages/strategies'

module SleepingKingStudios::Tools::Messages::Strategies
  # Messaging strategy that refers to an internal Hash of templates.
  class HashStrategy < SleepingKingStudios::Tools::Messages::Strategy
    # @param templates [Hash] the templates used to generate messages.
    def initialize(templates)
      super()

      @templates =
        flatten_templates(templates).freeze
    end

    # @return [Hash] the templates used to generate messages.
    attr_reader :templates

    private

    def flatten_templates(hsh, scope: nil, templates: {})
      hsh.each do |(key, value)|
        local = scope ? "#{scope}.#{key}" : key.to_s

        next templates[local] = value unless value.is_a?(Hash)

        flatten_templates(value, scope: local, templates:)
      end

      templates
    end

    def template_for(scoped_key, **)
      templates[scoped_key]
    end
  end
end
