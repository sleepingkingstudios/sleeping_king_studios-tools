# frozen_string_literal: true

require 'forwardable'

require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  # Service object for transforming strings.
  #
  # Internally, an instance of this class is used to StringTools to perform
  # string transformations.
  #
  # This class should define a compatible interface with
  # ActiveSupport::Inflector, i.e. all methods defined on Toolbox::Inflector
  # should have a corresponding method on ActiveSupport::Inflector with a
  # superset of the parameters. (The reverse is *not* true).
  #
  # @see SleepingKingStudios::Tools::StringTools.
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

    # @param rules [SleepingKingStudios::Tools::Toobox::Inflector::Rules] an
    #   object defining the transformation rules.
    def initialize(rules: nil)
      @rules = rules || Rules.new
    end

    # @return [SleepingKingStudios::Tools::Toobox::Inflector::Rules] an object
    #   defining the transformation rules.
    attr_reader :rules

    # Converts a lowercase, underscore-separated string to CamelCase.
    #
    # @param word [String] the word to transform.
    # @param uppercase_first_letter [Boolean] if true, the first letter is
    #   capitalized. Defaults to true.
    #
    # @return [String] the word in CamelCase.
    def camelize(word, uppercase_first_letter = true) # rubocop:disable Style/OptionalBooleanParameter
      return '' if word.nil? || word.empty?

      word =
        word
        .to_s
        .gsub(/(\b|[_-]+)([a-z])/) { Regexp.last_match(2).upcase }
        .gsub(/[_-]+/, '')

      (uppercase_first_letter ? word[0].upcase : word[0].downcase) + word[1..]
    end

    # Transforms the word to a plural, lowercase form.
    #
    # @param word [String] the word to transform.
    #
    # @return [String] the word in plural form.
    def pluralize(word) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
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

    # Transforms the word to a singular, lowercase form.
    #
    # @param word [String] the word to transform.
    #
    # @return [String] the word in singular form.
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
    # @return [String] the word in underscored form.
    def underscore(word)
      return '' if word.nil? || word.empty?

      word
        .to_s
        .gsub(/([A-Z0-9\d]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z])([A-Z\d])/, '\1_\2')
        .gsub(/(\d)([A-Z])/, '\1_\2')
        .gsub(/\A_+|_+\z/, '')
        .tr('-', '_')
        .downcase
    end
  end
end
