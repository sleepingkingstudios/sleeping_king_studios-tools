# lib/sleeping_king_studios/tools/object_tools.rb

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Low-level tools for working with objects.
  module ObjectTools
    class << self
      # Takes a proc or lambda and invokes it with the given object as
      # receiver, with any additional arguments or block provided.
      #
      # @param [Object] base The receiver. The proc will be called in the
      #   context of this object.
      # @param [Proc] proc The proc or lambda to call.
      # @param [Array] args Optional. Additional arguments to pass in to the
      #   proc or lambda.
      # @param [block] block Optional. If present, will be passed in to proc or
      #   lambda.
      #
      # @return The result of calling the proc or lambda with the given
      #   receiver and any additional arguments or block.
      def apply base, proc, *args, &block
        temporary_method_name = :__sleeping_king_studios_tools_object_tools_temporary_method_for_applying_proc__

        metaclass = class << base; self; end
        metaclass.send :define_method, temporary_method_name, &proc

        value = base.send temporary_method_name, *args, &block

        metaclass.send :remove_method, temporary_method_name

        value
      end # class method apply

      # Returns the object's eigenclass.
      #
      # @param [Object] object The object for which an eigenclass is required.
      #
      # @return [Class] The object's eigenclass.
      def eigenclass object
        class << object; self; end
      end # class method eigenclass
      alias_method :metaclass, :eigenclass
    end # class << self
  end # module
end # module
