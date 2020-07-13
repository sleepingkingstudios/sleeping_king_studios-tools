# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Helper object for quick access to all available tools.
  class Toolbelt < BasicObject
    def self.instance
      @instance ||= new
    end

    def initialize(inflector: nil)
      @array_tools   = ::SleepingKingStudios::Tools::ArrayTools.new
      @core_tools    = ::SleepingKingStudios::Tools::CoreTools.new
      @hash_tools    = ::SleepingKingStudios::Tools::HashTools.new
      @integer_tools = ::SleepingKingStudios::Tools::IntegerTools.new
      @object_tools  = ::SleepingKingStudios::Tools::ObjectTools.new
      @string_tools  =
        ::SleepingKingStudios::Tools::StringTools.new(inflector: inflector)
    end

    attr_reader :array_tools

    attr_reader :core_tools

    attr_reader :hash_tools

    attr_reader :integer_tools

    attr_reader :object_tools

    attr_reader :string_tools

    alias ary array_tools
    alias hsh hash_tools
    alias int integer_tools
    alias obj object_tools
    alias str string_tools

    %w[array core hash integer object string].each do |name|
      define_method(name) do
        ::SleepingKingStudios::Tools::CoreTools.deprecate(
          "SleepingKingStudios::Tools::Toolbelt##{name}",
          message: "Use ##{name}_tools instead."
        )

        ::SleepingKingStudios::Tools.const_get("#{name.capitalize}Tools")
      end
    end

    def inspect
      "#<#{::Object.instance_method(:class).bind(self).call.name}>"
    end
    alias to_s inspect
  end
end
