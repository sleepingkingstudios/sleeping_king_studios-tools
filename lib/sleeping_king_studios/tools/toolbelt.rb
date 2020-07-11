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
          # :nocov:
          nil
          # :nocov:
        end # begin-rescue
      end # each
    end # each

    def inspect
      @to_s ||=
        begin
          object_class = class << self; self; end.superclass

          "#<#{object_class.name}>"
        end # string
    end # method inspect
    alias_method :to_s, :inspect
  end # module
end # module
