# frozen_string_literal: true

module SleepingKingStudios
  module Tools
    module Toolbox
      # Utility class for initializing a library or project.
      class Initializer
        # @yield the block to execute when the initializer is called.
        def initialize(&block)
          raise ArgumentError, 'no block given' unless block_given?

          @block     = block
          @called    = false
          @semaphore = Thread::Mutex.new
        end

        # Runs the initialization block exactly once.
        def call
          @semaphore.synchronize do
            return if @called

            @block.call

            @called = true
          end
        end
      end
    end
  end
end
