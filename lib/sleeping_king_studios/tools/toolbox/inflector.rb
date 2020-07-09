# frozen_string_literal: true

require 'forwardable'

require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  # Transforms words (e.g. from singular to plural).
  #
  # Should maintain the same interface as ActiveSupport::Inflector.
  class Inflector
    extend Forwardable

    autoload :Rules, 'sleeping_king_studios/tools/toolbox/inflector/rules'
  end
end
