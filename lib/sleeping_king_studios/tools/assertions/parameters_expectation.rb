# frozen_string_literal: true

require 'sleeping_king_studios/tools/assertions'

# An Image has required keyword :shape and optional keyword :color
#
# With keywords: [], [:color]
# #=> missing required keyword :shape
#
# With keywords: [:shape], [:shape, :color]
# #=> OK
#
# With keywords: [:shape, :size], [:shape, :color, :size]
# #=> unknown keyword :size
#
# -----
#
# So, we take required, optional keywords. But we *need* required,
# accepted keywords (required + optional).
#
# Given a set of keywords, we need to assert that the keywords includes
# all required keywords and does not include any non-accepted keywords.
#
# So, map keywords => allowed_keywords, and skip required_keywords if it
# is not given. Alternatively, map keywords => optional_keywords.

class SleepingKingStudios::Tools::Assertions
  ParametersExpectation = Data.define(
    :assertions,
    :block,
    :optional_arguments,
    :optional_keywords,
    :required_arguments,
    :required_keywords,
    :variadic_arguments,
    :variadic_keywords
  )

  class ParametersExpectation < Data
    DEFAULT_OPTIONS = {
      block:              false,
      optional_arguments: 0,
      optional_keywords:  false,
      required_arguments: 0,
      required_keywords:  false,
      variadic_arguments: false,
      variadic_keywords:  false
    }.freeze
    private_constant :DEFAULT_OPTIONS

    def initialize(assertions:, arguments: nil, keywords: nil, **)
      values = {
        **DEFAULT_OPTIONS,
        assertions:,
        **resolve_arguments(arguments),
        **resolve_keywords(keywords),
        **
      }

      if values[:optional_keywords]
        values[:optional_keywords] = values[:optional_keywords].map(&:to_sym)
      end

      if values[:required_keywords]
        values[:required_keywords] = values[:required_keywords].map(&:to_sym)
      end

      super(**values)
    end

    def call(actual)
      parameters = actual.parameters

      assertions.assert_group do |group|
        assert_required_arguments_match(group:, parameters:)
      end
    end

    def matches?(actual)
      parameters = actual.parameters

      required_arguments_match?(parameters)
    end

    alias block?              block

    alias match?              matches?

    alias variadic_arguments? variadic_arguments

    alias variadic_keywords?  variadic_keywords

    private

    def assert_required_arguments_match(group:, parameters:)
      return if required_arguments_match?(parameters)

      actual   = parameters.count { |(type, _)| type == :req }
      expected = required_arguments
      key      =
        if actual > expected
          'too_many_required_arguments'
        else
          'not_enough_required_arguments'
        end
      message  = error_message_for(key, actual:, expected:)

      group.assert(message:) { false }
    end

    def block_matches?(parameters)
    end

    def error_message_for(key, as: false, **)
      assertions.error_message_for("#{error_prefix}.#{key}", as:, **)
    end

    def error_prefix = 'sleeping_king_studios.tools.assertions.parameters'

    def required_arguments_match?(parameters)
      parameters.count { |(type, _)| type == :req } == required_arguments
    end

    def resolve_arguments(arguments)
      case arguments
      when Integer
        { required_arguments: arguments, optional_arguments: 0 }
      when Range
        min = arguments.min
        max = arguments.max

        { required_arguments: min, optional_arguments: max - min }
      end
    end

    def resolve_keywords(keywords)
      case keywords
      when Array
        { optional_keywords: keywords, required_keywords: false }
      end
    end
  end
end
