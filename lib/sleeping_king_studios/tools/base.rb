# frozen_string_literal: true

require 'forwardable'

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Abstract base class for Tools classes.
  class Base
    class << self
      extend Forwardable
    end

    def self.instance
      @instance ||= new
    end
  end
end
