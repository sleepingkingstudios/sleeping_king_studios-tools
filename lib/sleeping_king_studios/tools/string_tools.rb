# lib/sleeping_king_studios/tools/string_tools.rb

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Tools for working with strings.
  module StringTools
    extend self

    # Returns the singular or the plural value, depending on the provided
    # item count.
    #
    # @example
    #   "There are four #{StringTools.pluralize 4, 'light', 'lights'}!"
    #   #=> 'There are four lights!'
    #
    # @param [Integer] count The number of items.
    # @param [String] single The singular form of the word or phrase.
    # @param [String] plural The plural form of the word or phrase.
    #
    # @return [String] The single form if count == 1; otherwise the plural
    #   form.
    def pluralize count, single, plural
      1 == count ? single : plural
    end # method pluralize

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

    def require_string! value
      raise ArgumentError.new('argument must be a string') unless value.is_a?(String)
    end # method require_array
  end # module
end # module
