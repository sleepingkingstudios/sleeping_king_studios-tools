# frozen_string_literal: true

require 'sleeping_king_studios/tools/messages'

module SleepingKingStudios::Tools
  # Namespace for message strategy implementations.
  module Messages::Strategies
    autoload :HashStrategy,
      'sleeping_king_studios/tools/messages/strategies/hash_strategy'
  end
end
