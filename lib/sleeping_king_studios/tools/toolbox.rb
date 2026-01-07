# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Namespace for defining common objects outside the tools.* pattern.
  module Toolbox
    autoload :ConstantMap,
      'sleeping_king_studios/tools/toolbox/constant_map'
    autoload :Inflector,
      'sleeping_king_studios/tools/toolbox/inflector'
    autoload :Initializer,
      'sleeping_king_studios/tools/toolbox/initializer'
    autoload :Mixin,
      'sleeping_king_studios/tools/toolbox/mixin'
    autoload :SemanticVersion,
      'sleeping_king_studios/tools/toolbox/semantic_version'
    autoload :Subclass,
      'sleeping_king_studios/tools/toolbox/subclass'
  end
end
