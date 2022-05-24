# frozen_string_literal: true

# Hic iacet Arthurus, rex quondam, rexque futurus.
module SleepingKingStudios
  # A library of utility services and concerns to expand the functionality of
  # core classes without polluting the global namespace.
  module Tools
    autoload :Base,         'sleeping_king_studios/tools/base'
    autoload :ArrayTools,   'sleeping_king_studios/tools/array_tools'
    autoload :Assertions,   'sleeping_king_studios/tools/assertions'
    autoload :CoreTools,    'sleeping_king_studios/tools/core_tools'
    autoload :HashTools,    'sleeping_king_studios/tools/hash_tools'
    autoload :IntegerTools, 'sleeping_king_studios/tools/integer_tools'
    autoload :ObjectTools,  'sleeping_king_studios/tools/object_tools'
    autoload :StringTools,  'sleeping_king_studios/tools/string_tools'
    autoload :Toolbelt,     'sleeping_king_studios/tools/toolbelt'
    autoload :Toolbox,      'sleeping_king_studios/tools/toolbox'
    autoload :Version,      'sleeping_king_studios/tools/version'
  end
end
