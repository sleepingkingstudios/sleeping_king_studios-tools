# frozen_string_literal: true

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Utility for generating configured, user-readable output strings.
  class Messages < Base
    autoload :Strategy, 'sleeping_king_studios/tools/messages/strategy'
  end
end
