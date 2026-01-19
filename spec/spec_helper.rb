# frozen_string_literal: true

require 'rspec'
require 'rspec/sleeping_king_studios/all'
require 'byebug'

unless ENV['COVERAGE'] == 'false'
  require 'simplecov'

  SimpleCov.start
end

# Isolated namespace for defining spec-only or transient objects.
module Spec; end

SleepingKingStudios::Tools.initializer.call

# Require Factories, Custom Matchers, &c
Dir[File.join File.dirname(__FILE__), 'support', '**', '*.rb']
  .each { |f| require f }

RSpec.configure do |config|
  config.extend RSpec::SleepingKingStudios::Concerns::ExampleConstants
  config.extend RSpec::SleepingKingStudios::Concerns::FocusExamples
  config.extend RSpec::SleepingKingStudios::Concerns::WrapExamples
  config.include RSpec::SleepingKingStudios::Deferred::Consumer
  config.include RSpec::SleepingKingStudios::Examples::PropertyExamples

  # Limit a spec run to individual examples or groups you care about by tagging
  # them with `:focus` metadata.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Allow more verbose output when running an individual spec file.
  config.default_formatter = 'doc' if config.files_to_run.one?

  # Run specs in random order to surface order dependencies.
  config.order = :random
  Kernel.srand config.seed

  # rspec-expectations config goes here.
  config.expect_with :rspec do |expectations|
    # Enable only the newer, non-monkey-patching expect syntax.
    expectations.syntax = :expect
  end

  # rspec-mocks config goes here.
  config.mock_with :rspec do |mocks|
    # Enable only the newer, non-monkey-patching expect syntax.
    mocks.syntax = :expect

    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended.
    mocks.verify_partial_doubles = true
  end
end
