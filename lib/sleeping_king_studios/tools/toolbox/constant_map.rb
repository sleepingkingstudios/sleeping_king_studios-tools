# lib/sleeping_king_studios/tools/toolbox/constant_map.rb

require 'sleeping_king_studios/tools/string_tools'
require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  module ConstantMap
    class << self
      def new constants
        mod = Module.new
        mod.extend self

        constants.each do |const_name, const_value|
          mod.const_set const_name, const_value
        end # each

        mod
      end # class method new
    end # eigenclass

    def all
      constants.each.with_object({}) do |const_name, hsh|
        hsh[const_name] = const_get(const_name)
      end # each
    end # method all

    def each &block
      all.each(&block)
    end # method each

    def freeze
      super

      constants.each do |const_name|
        object_tools.deep_freeze const_get(const_name)
      end # each
    end # method freeze

    private

    def method_missing symbol, *args, &block
      const_name = string_tools.underscore(symbol.to_s).upcase.intern

      if constants.include?(const_name)
        define_singleton_method symbol, ->() { const_get const_name }

        return send(symbol, *args, &block)
      end # if

      super
    end # method method_missing

    def object_tools
      ::SleepingKingStudios::Tools::ObjectTools
    end # method object_tools

    def respond_to_missing? symbol, include_all = false
      const_name = string_tools.underscore(symbol.to_s).upcase.intern

      constants.include?(const_name) || super
    end # method respond_to_missing?

    def string_tools
      ::SleepingKingStudios::Tools::StringTools
    end # method string_tools
  end # module
end # module
