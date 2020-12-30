# frozen_string_literal: true

require 'forwardable'

require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  # Transforms words (e.g. from singular to plural).
  #
  # Should maintain the same interface as ActiveSupport::Inflector.
  class Inflector
    extend Forwardable

    autoload :Rules, 'sleeping_king_studios/tools/toolbox/inflector/rules'

    def_delegators :@rules,
      :irregular_words,
      :irregular_words_reversed,
      :plural_rules,
      :singular_rules,
      :uncountable_words

    private \
      :irregular_words,
      :irregular_words_reversed,
      :plural_rules,
      :singular_rules,
      :uncountable_words

    # @return [Rules] An object defining the transformation rules.
    def initialize(rules: nil)
      @rules = rules || Rules.new
    end

    # @return [Rules] The defined rules object for the inflector.
    attr_reader :rules

    # Transforms the word to CamelCase.
    #
    # @param word [String] The word to transform.
    # @param uppercase_first_letter [Boolean] If true, the first letter is
    #   capitalized. Defaults to true.
    #
    # @return [String] The word in CamelCase.
    def camelize(word, uppercase_first_letter = true) # rubocop:disable Style/OptionalBooleanParameter
      return '' if word.nil? || word.empty?

      word = word.to_s.gsub(/(\b|[_-])([a-z])/) { Regexp.last_match(2).upcase }

      (uppercase_first_letter ? word[0].upcase : word[0].downcase) + word[1..-1]
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity

    # Transforms the word to a plural, lowercase form.
    #
    # @param word [String] The word to transform.
    #
    # @return [String] The word in plural form.
    def pluralize(word)
      return '' if word.nil? || word.empty?

      normalized = word.to_s.strip.downcase

      return normalized if uncountable_words.include?(normalized)

      return normalized if irregular_words_reversed.key?(normalized)

      return irregular_words[normalized] if irregular_words.key?(normalized)

      plural_rules.each do |match, replace|
        next unless normalized =~ match

        return normalized.sub(match, replace)
      end

      word
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity

    # Transforms the word to a singular, lowercase form.
    #
    # @param word [String] The word to transform.
    #
    # @return [String] The word in singular form.
    def singularize(word) # rubocop:disable Metrics/MethodLength
      return '' if word.nil? || word.empty?

      normalized = word.to_s.strip.downcase

      return normalized if irregular_words.key?(normalized)

      if irregular_words_reversed.key?(normalized)
        return irregular_words_reversed[normalized]
      end

      singular_rules.each do |match, replace|
        next unless normalized =~ match

        return normalized.sub(match, replace)
      end

      word
    end

    # Transforms the word to a lowercase, underscore-separated form.
    #
    # @param word [String] the word to transform.
    #
    # @return [String] The word in underscored form.
    def underscore(word)
      return '' if word.nil? || word.empty?

      word = word.to_s.gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')

      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.tr!('-', '_')
      word.downcase!
      word
    end
  end
end
