# frozen_string_literal: true

# Hic iacet Arthurus, rex quondam, rexque futurus.
module SleepingKingStudios
  # A library of utility services and concerns to expand the functionality of
  # core classes without polluting the global namespace.
  module Tools
    autoload :Base,     'sleeping_king_studios/tools/base'
    autoload :Toolbelt, 'sleeping_king_studios/tools/toolbelt'
    autoload :Version,  'sleeping_king_studios/tools/version'
  end
end
