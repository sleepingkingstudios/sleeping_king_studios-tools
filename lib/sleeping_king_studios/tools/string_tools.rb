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
  end # module
end # module
