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
        :indent,
        :map_lines,
        :plural?,
        :pluralize,
        :singular?,
        :singularize,
        :string?,
        :underscore
    end

    # @param inflector [Object] service object for inflecting strings. The
    #   inflector must be an object that conforms to the interface used by
    #   by SleepingKingStudios::Tools::Toolbox::Inflector, such as an instance
    #   of ActiveSupport::Inflector .
    # @param toolbelt [SleepingKingStudios::Tools::Toolbelt] the toolbelt this
    #   tools instance belongs to.
    def initialize(inflector: nil, toolbelt: nil)
      super(toolbelt:)

      @inflector =
        inflector || SleepingKingStudios::Tools::Toolbox::Inflector.new
    end

    # @return [Object] service object for inflecting strings.
    attr_reader :inflector

    # Converts a lowercase, underscore-separated string to CamelCase.
    #
    # @param str [String] the string to convert.
    #
    # @return [String] the converted string.
    #
    # @see SleepingKingStudios::Tools::Toolbox::Inflector#camelize.
    #
    # @example
    #   StringTools#camelize 'valhalla'
    #   #=> 'Valhalla'
    #
    #   StringTools#camelize 'muspelheimr_and_niflheimr'
    #   #=> 'MuspelheimrAndNiflheimr'
    def camelize(str)
      str = require_string!(str)

      inflector.camelize(str)
    end

    # Performs a series of operations on the string.
    #
    # Use #chain to call each specified method in the chain in sequence, passing
    # the output of each method to the next method.
    #
    # @param str [String] the string to process.
    # @param commands [Array<String, Symbol>] the string operations to apply.
    #
    # @return [String] the processed string.
    #
    # @example
    #   # Equivalent to `StringTools.underscore(StringTools.pluralize str)`.
    #   StringTools#chain 'ArchivedPeriodical', :underscore, :pluralize
    #   # => 'archived_periodicals'
    #
    # @deprecated v1.3.0 Use Object#then {} instead.
    def chain(str, *commands)
      toolbelt.core_tools.deprecate(
        "#{self.class.name}#chain",
        message: 'Use Object#then {} instead.'
      )

      str = require_string!(str)

      commands.reduce(str) { |memo, command| public_send(command, memo) }
    end

    # Adds the specified number of spaces to the start of each line.
    #
    # @param str [String] the string to indent.
    # @param count [Integer] the number of spaces to add. Defaults to 2.
    #
    # @return [String] the indented string.
    #
    # @example
    #   string = 'The Hobbit'
    #   StringTools.indent(string)
    #   #=> '  The Hobbit'
    #
    #   titles = [
    #     "The Fellowship of the Ring",
    #     "The Two Towers",
    #     "The Return of the King"
    #   ]
    #   string = titles.join "\n"
    #   StringTools.indent(string, 4)
    #   #=> "    The Fellowship of the Ring\n"\
    #       "    The Two Towers\n"\
    #       "    The Return of the King"
    def indent(str, count = 2)
      str = require_string!(str)
      pre = ' ' * count

      map_lines(str) { |line| "#{pre}#{line}" }
    end

    # Yields each line to the provided block and combines the results.
    #
    # The results of each line are combined back into a new multi-line string.
    #
    # @param str [String] the string to map.
    #
    # @yieldparam line [String] the current line.
    # @yieldparam index [Integer] the index of the current line.
    #
    # @yieldreturn [String] the modified line.
    #
    # @return [String] the mapped and recombined string.
    #
    # @example
    #   string = 'The Hobbit'
    #   StringTools.map_lines(string) { |line| "  #{line}" }
    #   #=> '- The Hobbit'
    #
    #   titles = [
    #     "The Fellowship of the Ring",
    #     "The Two Towers",
    #     "The Return of the King"
    #   ]
    #   string = titles.join "\n"
    #   StringTools.map_lines(string) { |line, index| "#{index}. #{line}" }
    #   #=> "0. The Fellowship of the Ring\n"\
    #       "1. The Two Towers\n"\
    #       "2. The Return of the King"
    def map_lines(str)
      str = require_string!(str)

      str.each_line.with_index.reduce(+'') do |memo, (line, index)|
        memo << yield(line, index)
      end
    end

    # Determines whether or not the given word is in plural form.
    #
    # If calling #pluralize(word) is equal to word, the word is considered
    # plural.
    #
    # @param word [String] the word to check.
    #
    # @return [Boolean] true if the word is in plural form, otherwise false.
    #
    # @see #pluralize
    #
    # @example
    #   StringTools.plural? 'light'
    #   #=> false
    #
    #   StringTools.plural? 'lights'
    #   #=> true
    def plural?(word)
      word = require_string!(word)

      word == pluralize(word)
    end

    # @overload pluralize(str)
    #   Takes a word in singular form and returns the plural form.
    #
    #   This method delegates to the configured inflector, which converts the
    #   given word based on the defined rules and known irregular/uncountable
    #   words.
    #
    #   @param str [String] the word to pluralize.
    #
    #   @return [String] the pluralized word.
    #
    #   @example
    #     StringTools.pluralize 'light'
    #     #=> 'lights'
    #
    #   @see SleepingKingStudios::Tools::Toolbox::Inflector#pluralize.
    def pluralize(*args)
      str = require_string!(args.first)

      inflector.pluralize(str)
    end

    # Determines whether or not the given word is in singular form.
    #
    # If calling #singularize(word) is equal to word, the word is considered
    # singular.
    #
    # @param word [String] the word to check.
    #
    # @return [Boolean] true if the word is in singular form, otherwise false.
    #
    # @see #singularize
    #
    # @example
    #   StringTools.singular? 'light'
    #   #=> true
    #
    #   StringTools.singular? 'lights'
    #   #=> false
    def singular?(word)
      word = require_string!(word)

      word == singularize(word)
    end

    # Transforms the word to a singular, lowercase form.
    #
    # This method delegates to the configured inflector, which converts the
    # given word based on the defined rules and known irregular/uncountable
    # words.
    #
    # @param str [String] the word to transform.
    #
    # @return [String] the word in singular form.
    #
    #   @see SleepingKingStudios::Tools::Toolbox::Inflector#singularize.
    #
    # @example
    #   StringTools.singularize 'lights'
    #   #=> 'light'
    def singularize(str)
      require_string!(str)

      inflector.singularize(str)
    end

    # Returns true if the object is a String.
    #
    # @param str [Object] the object to test.
    #
    # @return [Boolean] true if the object is a String, otherwise false.
    #
    # @example
    #   StringTools.string?(nil)
    #   #=> false
    #   StringTools.string?([])
    #   #=> false
    #   StringTools.string?('Greetings, programs!')
    #   #=> true
    #   StringTools.string?(:greetings_starfighter)
    #   #=> false
    def string?(str)
      str.is_a?(String)
    end

    # Converts a mixed-case string to a lowercase, underscore separated string.
    #
    # @param str [String] the string to convert.
    #
    # @return [String] the converted string.
    #
    # @see SleepingKingStudios::Tools::Toolbox::Inflector#underscore.
    #
    # @example
    #   StringTools#underscore 'Bifrost'
    #   #=> 'bifrost'
    #
    #   StringTools#underscore 'FenrisWolf'
    #   #=> 'fenris_wolf'
    def underscore(str)
      str = require_string!(str)

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
