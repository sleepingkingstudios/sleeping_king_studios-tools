# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox'

class SleepingKingStudios::Tools::Toolbox::Inflector
  # Rules for inflecting words.
  class Rules
    # @param irregular_words [Hash{String => String}] irregular word pairs in
    #   singular => plural order, e.g. "child" => "children".
    # @param plural_rules [Array<Array<Regexp, String>>] rules for
    #   pluralizing words.
    # @param singular_rules [Array<Array<Regexp, String>>] rules for
    #   singularizing words.
    # @param uncountable_words [Array<String>] uncountable words e.g. "data".
    def initialize(
      irregular_words:   nil,
      plural_rules:      nil,
      singular_rules:    nil,
      uncountable_words: nil
    )
      @plural_rules      = plural_rules    || default_plural_rules
      @singular_rules    = singular_rules  || default_singular_rules
      @irregular_words   = irregular_words || default_irregular_words
      @uncountable_words =
        Set.new(uncountable_words || default_uncountable_words)

      @irregular_words_reversed = reverse_hash(@irregular_words)
    end

    # @return [Array<Array<String, String>>] irregular word pairs in
    #   singular => plural order.
    attr_reader :irregular_words

    # @return [Array<Array<String, String>>] irregular word pairs in plural =>
    #   singular order.
    attr_reader :irregular_words_reversed

    # @return [Array<Array<Regexp, String>>] rules for pluralizing words.
    attr_reader :plural_rules

    # @return [Array<Array<Regexp, String>>] rules for singularizing words.
    attr_reader :singular_rules

    # @return [Array<String>] uncountable words.
    attr_reader :uncountable_words

    # Defines an irregular word pair.
    #
    # @param singular [String] the singular form of the word.
    # @param plural [String] the plural form of the word.
    #
    # @return [self] the rules object.
    def define_irregular_word(singular, plural)
      validate_string(singular)
      validate_string(plural)

      @irregular_words[singular]        = plural
      @irregular_words_reversed[plural] = singular

      self
    end

    # Defines a pluralization rule.
    #
    # @param pattern [Regexp] the pattern to match.
    # @param replace [String] the string to replace.
    #
    # @return [self] the rules object.
    def define_plural_rule(pattern, replace)
      validate_pattern(pattern)
      validate_string(replace, as: 'replace')

      @plural_rules.unshift([pattern, replace])

      self
    end

    # Defines a singularization rule.
    #
    # @param pattern [Regexp] the pattern to match.
    # @param replace [String] the string to replace.
    #
    # @return [self] the rules object.
    def define_singular_rule(pattern, replace)
      validate_pattern(pattern)
      validate_string(replace, as: 'replace')

      @singular_rules.unshift([pattern, replace])

      self
    end

    # Defines an uncountable word.
    #
    # @param word [String] the uncountable word.
    #
    # @return [self] the rules object.
    def define_uncountable_word(word)
      validate_string(word)

      @uncountable_words << word

      self
    end

    # @return [String] a human-readable representation of the rules object.
    def inspect
      "#<SleepingKingStudios::Tools::Toolbox::Inflector::Rules:#{object_id}>"
    end

    private

    def default_irregular_words
      {
        'child'  => 'children',
        'person' => 'people'
      }
    end

    def default_plural_rules
      [
        [/([^aeiouy])y$/i, '\1ies'],   # Winery => Wineries
        [/([^aeiouy]o)$/i, '\1es'],    # Halo   => Haloes
        [/(ss|[xz]|[cs]h)$/i, '\1es'], # Truss  => Trusses
        [/s$/i, 's'],                  # Words  => Words
        [/$/, 's']                     # Word   => Words
      ]
    end

    def default_singular_rules
      [
        [/([^aeiouy])ies$/i, '\1y'],   # Wineries => Winery
        [/([^aeiouy]o)es$/, '\1'],     # Haloes   => Halo
        [/(ss|[sxz]|[cs]h)es$/, '\1'], # Torches  => Torch
        [/ss$/i, 'ss'],                # Truss    => Truss
        [/s$/i, '']                    # Words    => Word
      ]
    end

    def default_uncountable_words
      %w[data]
    end

    def reverse_hash(hsh)
      hsh.each.with_object({}) do |(key, value), reversed|
        reversed[value] = key
      end
    end

    def validate_pattern(rxp)
      raise ArgumentError, "pattern can't be blank", caller(1..-1) if rxp.nil?

      return if rxp.is_a?(Regexp)

      raise ArgumentError, 'pattern must be a Regexp', caller(1..-1)
    end

    def validate_string(word, as: 'word')
      raise ArgumentError, "#{as} can't be blank", caller(1..-1) if word.nil?

      unless word.is_a?(String)
        raise ArgumentError, "#{as} must be a String", caller(1..-1)
      end

      return unless word.empty?

      raise ArgumentError, "#{as} can't be blank", caller(1..-1)
    end
  end
end
