# frozen_string_literal: true

require 'sleeping_king_studios/tools'

SleepingKingStudios::Tools::CoreTools
  .deprecate('SleepingKingStudios::Tools::EnumerableTools')

module SleepingKingStudios::Tools
  # Alias for ArrayTools to ensure backward compatibility.
  EnumerableTools = ArrayTools
end
