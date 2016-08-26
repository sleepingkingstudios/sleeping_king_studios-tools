# lib/sleeping_king_studios/tools/semantic_version.rb

require 'sleeping_king_studios/tools/core_tools'

SleepingKingStudios::Tools::CoreTools.deprecate(
  'SleepingKingStudios::Tools::SemanticVersion',
  :message => 'Use SleepingKingStudios::Tools::Toolbox::SemanticVersion instead.'
) # end deprecate

require 'sleeping_king_studios/tools/toolbox/semantic_version'

module SleepingKingStudios::Tools
  # (see SleepingKingStudios::Tools::Toolbox::SemanticVersion)
  SemanticVersion = Toolbox::SemanticVersion
end # module
