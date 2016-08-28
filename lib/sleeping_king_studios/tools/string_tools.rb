# lib/sleeping_king_studios/tools/string_tools.rb

require 'sleeping_king_studios/tools'
require 'sleeping_king_studios/tools/object_tools'

module SleepingKingStudios::Tools
  # Tools for working with strings.
  module StringTools
    extend self

    autoload :PluralInflector, 'sleeping_king_studios/tools/string_tools/plural_inflector'

    # Converts a lowercase, underscore-separated string to CamelCase.
    #
    # @param str [String] The string to convert.
    #
    # @return [String] The converted string.
    #
    # @see ActiveSupport::Inflector#camelize.
    def camelize str
      require_string! str

      str = str.dup
      str.gsub!(/(\b|[_-])([a-z])/) { |match| $2.upcase }
      str
    end # method camelize

    # (see PluralInflector#define_irregular_word)
    def define_irregular_word singular, plural
      plural_inflector.define_irregular_word singular, plural
    end # method define_irregular_word

    # (see PluralInflector#define_plural_rule)
    def define_plural_rule match, replace
      plural_inflector.define_plural_rule match, replace
    end # method define_plural_rule

    # (see PluralInflector#define_singular_rule)
    def define_singular_rule match, replace
      plural_inflector.define_singular_rule match, replace
    end # method define_singular_rule

    # (see PluralInflector#define_uncountable_word)
    def define_uncountable_word word
      plural_inflector.define_uncountable_word word
    end # method define_uncountable_word

    # @overload pluralize(str)
    #   Takes a word in singular form and returns the plural form, based on the
    #   defined rules and known irregular/uncountable words.
    #
    #   @param str [String] The word to pluralize.
    #
    #   @return [String] The pluralized word.
    #
    # @overload pluralize(count, single, plural)
    #   @deprecated This functionality is deprecated as of version 0.4.0 and
    #     will be removed in a future version. Use IntegerTools#pluralize
    #     instead.
    #
    #   Returns the singular or the plural value, depending on the provided
    #   item count.
    #
    #   @example
    #     "There are four #{StringTools.pluralize 4, 'light', 'lights'}!"
    #     #=> 'There are four lights!'
    #
    #   @param [Integer] count The number of items.
    #   @param [String] single The singular form of the word or phrase.
    #   @param [String] plural The plural form of the word or phrase.
    #
    #   @return [String] The single form if count == 1; otherwise the plural
    #     form.
    def pluralize *args
      if args.count == 3
        CoreTools.deprecate 'StringTools#pluralize with 3 arguments',
          :message => 'Use IntegerTools#pluralize instead.'

        return IntegerTools.pluralize(*args)
      end # if

      require_string! args.first

      plural_inflector.pluralize args.first
    end # method pluralize

    # (see PluralInflector#singularize)
    def singularize str
      require_string! str

      plural_inflector.singularize str
    end # method singularize

    # Returns true if the object is a String.
    #
    # @param str [Object] The object to test.
    #
    # @return [Boolean] True if the object is a String, otherwise false.
    def string? str
      String === str
    end # method string?

    # Converts a mixed-case string expression to a lowercase, underscore
    # separated string.
    #
    # @param str [String] The string to convert.
    #
    # @return [String] The converted string.
    #
    # @see ActiveSupport::Inflector#underscore.
    def underscore str
      require_string! str

      str = str.dup
      str.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
      str.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      str.tr!("-", "_")
      str.downcase!
      str
    end # method underscore

    private

    def plural_inflector
      @plural_inflector ||= PluralInflector.new
    end # method plural_inflector

    def require_string! value
      return if string?(value)

      raise ArgumentError, 'argument must be a string', caller[1..-1]
    end # method require_array
  end # module
end # module
