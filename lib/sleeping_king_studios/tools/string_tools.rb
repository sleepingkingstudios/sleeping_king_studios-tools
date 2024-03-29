# frozen_string_literal: true

require 'sleeping_king_studios/tools'
require 'sleeping_king_studios/tools/toolbox/inflector'

module SleepingKingStudios::Tools
  # Tools for working with strings.
  class StringTools < SleepingKingStudios::Tools::Base
    class << self
      def_delegators :instance,
        :camelize,
        :chain,
        :define_irregular_word,
        :define_plural_rule,
        :define_singular_rule,
        :define_uncountable_word,
        :indent,
        :map_lines,
        :plural?,
        :pluralize,
        :singular?,
        :singularize,
        :string?,
        :underscore
    end

    # @param inflector [Object] An object that conforms to the interface used
    #   by SleepingKingStudios::Tools::Toolbox::Inflector, such as
    #   ActiveSupport::Inflector .
    def initialize(inflector: nil)
      super()

      @inflector =
        inflector || SleepingKingStudios::Tools::Toolbox::Inflector.new
    end

    attr_reader :inflector

    # Converts a lowercase, underscore-separated string to CamelCase.
    #
    # @param str [String] The string to convert.
    #
    # @return [String] The converted string.
    #
    # @see ActiveSupport::Inflector#camelize.
    def camelize(str)
      str = require_string! str

      inflector.camelize(str)
    end

    # Performs multiple string tools operations in sequence, starting with the
    # given string and passing the result of each operation to the next.
    #
    # @param str [String] The string to process.
    # @param commands [Array<String, Symbol>] The string operations to apply.
    #
    # @return [String] The processed string.
    def chain(str, *commands)
      str = require_string! str

      commands.reduce(str) { |memo, command| send(command, memo) }
    end

    # Adds the specified number of spaces to the start of each line of the
    # string. Defaults to 2 spaces.
    #
    # @param str [String] The string to indent.
    # @param count [Integer] The number of spaces to add.
    #
    # @return [String] The indented string.
    def indent(str, count = 2)
      str = require_string! str
      pre = ' ' * count

      map_lines(str) { |line| "#{pre}#{line}" }
    end

    # Yields each line of the string to the provided block and combines the
    # results into a new multiline string.
    #
    # @param str [String] The string to map.
    #
    # @yieldparam line [String] The current line.
    # @yieldparam index [Integer] The index of the current line.
    #
    # @return [String] The mapped string.
    def map_lines(str)
      str = require_string! str

      str.each_line.with_index.reduce(+'') do |memo, (line, index)|
        memo << yield(line, index)
      end
    end

    # Determines whether or not the given word is in plural form. If calling
    # #pluralize(word) is equal to word, the word is considered plural.
    #
    # @return [Boolean] True if the word is in plural form, otherwise false.
    def plural?(word)
      word = require_string!(word)

      word == pluralize(word)
    end

    # @overload pluralize(str)
    #   Takes a word in singular form and returns the plural form, based on the
    #   defined rules and known irregular/uncountable words.
    #
    #   @param str [String] The word to pluralize.
    #
    #   @return [String] The pluralized word.
    def pluralize(*args)
      str = require_string! args.first

      inflector.pluralize str
    end

    # Determines whether or not the given word is in singular form. If calling
    # #singularize(word) is equal to word, the word is considered singular.
    #
    # @return [Boolean] True if the word is in singular form, otherwise false.
    def singular?(word)
      word = require_string!(word)

      word == singularize(word)
    end

    # Transforms the word to a singular, lowercase form.
    #
    # @param str [String] The word to transform.
    #
    # @return [String] The word in singular form.
    def singularize(str)
      require_string! str

      inflector.singularize str
    end

    # Returns true if the object is a String.
    #
    # @param str [Object] The object to test.
    #
    # @return [Boolean] True if the object is a String, otherwise false.
    def string?(str)
      str.is_a?(String)
    end

    # Converts a mixed-case string expression to a lowercase, underscore
    # separated string.
    #
    # @param str [String] The string to convert.
    #
    # @return [String] The converted string.
    #
    # @see ActiveSupport::Inflector#underscore.
    def underscore(str)
      str = require_string! str

      inflector.underscore(str)
    end

    private

    def require_string!(value)
      return value if string?(value)

      return value.to_s if value.is_a?(Symbol)

      raise ArgumentError, 'argument must be a string', caller[1..]
    end
  end
end
