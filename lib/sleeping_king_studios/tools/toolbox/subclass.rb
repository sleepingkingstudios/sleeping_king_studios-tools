# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  # Mixin for partially applying constructor parameters.
  #
  # @example
  #   class Character
  #     extend SleepingKingStudios::Tools::Toolbox::Subclass
  #
  #     def initialize(*traits)
  #       @traits = traits
  #     end
  #
  #     attr_reader :traits
  #   end
  #
  #   Bard = Character.subclass(:charismatic, :musical)
  #
  #   aoife = Bard.new(:sorcerous)
  #   aoife.traits
  #   #=> [:charismatic, :musical, :sorcerous]
  module Subclass
    # Creates a subclass with partially applied constructor parameters.
    #
    # @param class_arguments [Array] The arguments, if any, to apply to the
    #   constructor. These arguments will be added before any args passed
    #   directly to the constructor.
    # @param class_keywords [Hash] The keywords, if any, to apply to the
    #   constructor. These keywords will be added before any kwargs passed
    #   directly to the constructor.
    #
    # @yield The block, if any, to pass to the constructor. This will be
    #   overriden by a block passed directly to the constructor.
    #
    # @return [Class] the generated subclass.
    def subclass(*class_arguments, **class_keywords, &class_block) # rubocop:disable Metrics/MethodLength
      subclass = Class.new(self)

      subclass.define_method :initialize do |*args, **kwargs, &block|
        super(
          *class_arguments,
          *args,
          **class_keywords,
          **kwargs,
          &(block || class_block) # rubocop:disable Style/RedundantParentheses
        )
      end

      subclass
    end
  end
end
