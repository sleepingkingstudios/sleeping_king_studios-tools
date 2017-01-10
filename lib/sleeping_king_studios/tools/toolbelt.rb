# lib/sleeping_king_studios/tools/toolbelt.rb

require 'sleeping_king_studios/tools/all'

module SleepingKingStudios::Tools
  # Helper object for quick access to all available tools.
  class Toolbelt < BasicObject
    def self.instance
      @instance ||= new
    end # class method instance

    namespace = ::SleepingKingStudios::Tools

    %w(array core hash integer object string).each do |name|
      define_method(name) do
        begin
          namespace.const_get("#{name.capitalize}Tools")
        rescue NameError => exception
          nil
        end # begin-rescue
      end # each
    end # each
  end # module
end # module
