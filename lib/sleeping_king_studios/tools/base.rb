# frozen_string_literal: true

require 'forwardable'

require 'sleeping_king_studios/tools'

module SleepingKingStudios::Tools
  # Abstract base class for Tools classes.
  class Base
    class << self
      extend Forwardable
    end

    # @return [SleepingKingStudios::Tools::Base] a memoized instance of the
    #   tools class.
    def self.instance
      @instance ||= new
    end
  end
end
