# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Namespace for common objects or patterns that are useful across projects but
  # are larger than or do not fit the functional paradigm of the tools.*
  # pattern.
  module Toolbox
    autoload :ConstantMap,
      'sleeping_king_studios/tools/toolbox/constant_map'
    autoload :Inflector,
      'sleeping_king_studios/tools/toolbox/inflector'
    autoload :Mixin,
      'sleeping_king_studios/tools/toolbox/mixin'
    autoload :SemanticVersion,
      'sleeping_king_studios/tools/toolbox/semantic_version'
    autoload :Subclass,
      'sleeping_king_studios/tools/toolbox/subclass'
  end
end
