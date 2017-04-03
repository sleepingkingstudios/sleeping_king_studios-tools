# lib/sleeping_king_studios/tools.rb

# Hic iacet Arthurus, rex quondam, rexque futurus.
module SleepingKingStudios
  # A library of utility services and concerns to expand the functionality of
  # core classes without polluting the global namespace.
  module Tools
    autoload :Toolbelt, 'sleeping_king_studios/tools/toolbelt'
  end # module
end # module

require 'sleeping_king_studios/tools/version'
