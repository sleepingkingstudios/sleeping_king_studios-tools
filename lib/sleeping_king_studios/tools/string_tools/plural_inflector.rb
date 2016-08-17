# lib/sleeping_king_studios/tools/string_tools/plural_inflector.rb

require 'sleeping_king_studios/tools/string_tools'

module SleepingKingStudios::Tools::StringTools
  # Inflector class to handle word pluralization using a set of defined rules
  # and irregular/uncountable words.
  class PluralInflector
    # Defines an irregular word, which is a singular and plural word pair that
    # do not obey any defined rule, such as "goose" and "geese".
    #
    # @param singular [String] The singular form of the word.
    # @param plural [String] The plural form of the word.
    def define_irregular_word singular, plural
      irregular_words[singular]       = plural
      inverse_irregular_words[plural] = singular
    end # method define_irregular_word

    # Defines a rule for pluralization. The rule will be applied to any words
    # that match the first parameter, performing a replace on the word using
    # the second parameter.
    #
    # Rules are applied in reverse order of definition, meaning that rules
    # defined later will take precedence over previously defined rules.
    #
    # @param match [Regexp] The matching rule.
    # @param replace [String] The replacement string.
    def define_plural_rule match, replace
      plural_rules.unshift [match, replace]
    end # method define_plural_rule

    # Defines a rule for singularization. The rule will be applied to any words
    # that match the first parameter, performing a replace on the word using
    # the second parameter.
    #
    # Rules are applied in reverse order of definition, meaning that rules
    # defined later will take precedence over previously defined rules.
    #
    # @param match [Regexp] The matching rule.
    # @param replace [String] The replacement string.
    def define_singular_rule match, replace
      singular_rules.unshift [match, replace]
    end # method define_singular_rule

    # Defines an uncountable word, such as "data". If #pluralize or #singularize
    # is called with an uncountable word as its parameter, it will return the
    # unmodified word.
    #
    # @param word [String] The uncountable word.
    def define_uncountable_word word
      uncountable_words << word
    end # method define_uncountable_word

    # Takes a word in singular form and returns the plural form, based on the
    # defined rules and known irregular/uncountable words.
    #
    # First, checks if the word is known to be uncountable (see
    # #define_uncountable_word). Then, checks if the word is known to be
    # irregular (see #define_irregular_word). Finally, iterates through the
    # defined plural rules from most recently defined to first defined (see
    # #define_plural_rule).
    #
    # @note The defined rules and exceptions are deliberately basic. Each
    #   application is responsible for defining its own pluralization rules
    #   using this framework.
    #
    # @param str [String] The word to pluralize.
    #
    # @return [String] The pluralized word.
    #
    # @see #singularize
    def pluralize str
      str        = str.to_s.strip
      normalized = str.downcase

      uncountable_words.each do |word|
        return str if word == normalized
      end # each

      return str if inverse_irregular_words.key?(normalized)

      return irregular_words[normalized] if irregular_words.key?(normalized)

      plural_rules.each do |match, replace|
        next unless str =~ match

        return str.sub(match, replace)
      end # each

      str
    end # method pluralize

    # Takes a word in plural form and returns the singular form, based on the
    # defined rules and known irregular/uncountable words.
    #
    # @param str [String] The word to singularize.
    #
    # @return [String] The singularized word.
    #
    # @see #pluralize
    def singularize str
      str        = str.to_s.strip
      normalized = str.downcase

      uncountable_words.each do |word|
        return str if word == normalized
      end # each

      return inverse_irregular_words[normalized] if inverse_irregular_words.key?(normalized)

      singular_rules.each do |match, replace|
        next unless str =~ match

        return str.sub(match, replace)
      end # each

      str
    end # method singularize

    private

    def define_irregular_words
      define_irregular_word 'child', 'children'
      define_irregular_word 'person', 'people'
    end # method define_irregular_words

    def inverse_irregular_words
      return @inverse_irregular_words if @inverse_irregular_words

      @inverse_irregular_words = {}

      define_irregular_words

      @inverse_irregular_words
    end # method inverse_irregular_words

    def irregular_words
      return @irregular_words if @irregular_words

      @irregular_words = {}

      define_irregular_words

      @irregular_words
    end # method irregular_words

    def plural_rules
      return @plural_rules if @plural_rules

      @plural_rules = []

      define_plural_rule(/$/, 's')
      define_plural_rule(/s$/, 's')
      define_plural_rule(/([xz]|[cs]h)$/i, '\1es')
      define_plural_rule(/([^aeiouy]o)$/i, '\1es')
      define_plural_rule(/([^aeiouy])y$/i, '\1ies')

      @plural_rules
    end # method plural_rules

    def singular_rules
      return @singular_rules if @singular_rules

      @singular_rules = []

      define_singular_rule(/s$/i, '')
      define_singular_rule(/([sxz]|[cs]h)es$/, '\1')
      define_singular_rule(/([^aeiouy]o)es$/, '\1')
      define_singular_rule(/([^aeiouy])ies$/i, '\1y')

      @singular_rules
    end # method singular_rules

    def uncountable_words
      return @uncountable_words if @uncountable_words

      @uncountable_words = []

      @uncountable_words << 'data'

      @uncountable_words
    end # method uncountable_words
  end # class
end # module
