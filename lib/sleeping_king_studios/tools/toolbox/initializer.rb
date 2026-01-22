# frozen_string_literal: true

module SleepingKingStudios
  module Tools
    module Toolbox
      # Utility class for initializing a library or project.
      #
      # An initializer is used to set up the project, including loading
      # configuration, setting initial data or states, and initializing
      # dependencies.
      #
      # Using an initializer provides several advantages:
      #
      # - Potentially-expensive setup code is run on your own schedule, not when
      #   the module is first loaded.
      # - The setup code will only run once, even if the initializer is called
      #   multiple times or from multiple places.
      # - The setup code will only run once, even in a multi-threaded
      #   environment.
      #
      # @example Defining An Initializer
      #   module Space
      #     @initializer = SleepingKingStudios::Tools::Toolbox::Initializer.new do
      #       # Initializers can safely call other initializers to ensure
      #       # dependencies are set up.
      #       Physics.initializer.call
      #
      #       Space.load_configuration
      #     end
      #
      #     def self.initializer = @initializer
      #   end
      #
      # @example Calling An Initializer
      #   # In spec/spec_helper.rb
      #
      #   require 'space'
      #
      #   Space.initializer.call
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
