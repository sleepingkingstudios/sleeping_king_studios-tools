# lib/sleeping_king_studios/tools/core_tools.rb

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Tools for working with an application or working environment.
  module CoreTools
    extend self

    # @overload deprecate(name, message: nil)
    #   Prints a deprecation warning.
    #
    #   @param name [String] The name of the object, method, or feature that
    #     has been deprecated.
    #   @param message [String] An optional message to print after the formatted
    #     string. Defaults to nil.
    #
    # @overload deprecate(*args, format:, message: nil)
    #   Prints a deprecation warning with the specified format.
    #
    #   @param args [Array] The arguments to pass into the format string.
    #   @param format [String] The format string.
    #   @param message [String] An optional message to print after the formatted
    #     string. Defaults to nil.
    def deprecate *args, format: nil, message: nil
      format ||= "[WARNING] %s has been deprecated."

      str = format % args
      str << ' ' << message if message

      str << "\n  called from #{caller[1]}"

      Kernel.warn str
    end # method deprecate

    # Expands each file pattern and requires each file.
    def require_each *file_patterns
      file_patterns.each do |file_pattern|
        if file_pattern.include?('*')
          Dir[file_pattern].each do |file_name|
            Kernel.require file_name
          end # each
        else
          Kernel.require file_pattern
        end # unless
      end # each
    end # method require_each
  end # module
end # module
