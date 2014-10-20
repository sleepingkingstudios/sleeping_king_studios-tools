# lib/sleeping_king_studios/tools/string_tools.rb

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Tools for working with strings.
  module StringTools
    extend self

    # Returns the singular or the plural value, depending on the provided
    # item count.
    #
    # @param [Integer] count The number of items.
    # @param [String] single The singular form of the word or phrase.
    # @param [String] plural The plural form of the word or phrase.
    #
    # @return [String] THe single form if count == 1; otherwise the plural
    #   form.
    def pluralize count, single, plural
      1 == count ? single : plural
    end # method pluralize
  end # module
end # module
