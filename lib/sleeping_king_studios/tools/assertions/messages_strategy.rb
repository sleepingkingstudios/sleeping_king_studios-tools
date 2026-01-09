# frozen_string_literal: true

require 'sleeping_king_studios/tools/assertions'

module SleepingKingStudios::Tools
  # Messages strategy for displaying assertions errors.
  #
  # Defines its own internal message templates, and automatically handles value
  # name option (:as option) when generating messages.
  class Assertions::MessagesStrategy < SleepingKingStudios::Tools::Messages::Strategies::HashStrategy
    # rubocop:disable Layout/HashAlignment
    ERROR_MESSAGES =
      {
        'blank' =>
          'must be nil or empty',
        'block' =>
          'block returned a falsy value',
        'boolean' =>
          'must be true or false',
        'class' =>
          'is not a Class',
        'class_or_module' =>
          'is not a Class or Module',
        'exclusion' =>
          'is one of %<expected>s',
        'exclusion_range' =>
          'is within %<range_expr>s',
        'inclusion' =>
          'is not one of %<expected>s',
        'inclusion_range' =>
          'is outside %<range_expr>s',
        'inherit_from' =>
          'does not inherit from %<expected>s',
        'instance_of' =>
          'is not an instance of %<expected>s',
        'instance_of_anonymous' =>
          'is not an instance of %<expected>s (%<parent>s)',
        'matches' =>
          'does not match the expected value',
        'matches_proc' =>
          'does not match the Proc',
        'matches_regexp' =>
          'does not match the pattern %<pattern>s',
        'name' =>
          'is not a String or a Symbol',
        'nil' =>
          'must be nil',
        'not_nil' =>
          'must not be nil',
        # @note: This value will be changed in a future version.
        'presence' =>
          "can't be blank"
      }.freeze
    # rubocop:enable Layout/HashAlignment

    def initialize
      templates =
        ERROR_MESSAGES
        .transform_keys do |key|
          "sleeping_king_studios.tools.assertions.#{key}"
        end
        .freeze

      super(templates)
    end

    private

    def generate(template, as: nil, parameters: {}, **)
      message = super

      return message unless as

      "#{as} #{message}"
    end
  end
end
