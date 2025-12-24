# frozen_string_literal: true

require 'sleeping_king_studios/tools/assertions'

require 'support/deferred/assertions_examples'

RSpec.describe SleepingKingStudios::Tools::Assertions do
  include Spec::Support::Deferred::AssertionsExamples

  subject(:assertions) { described_class.instance }

  deferred_examples 'should fail the assertion' do |**deferred_options|
    describe 'should raise an exception with the failure message' do
      let(:error_class) do
        deferred_options.fetch(:error_class, described_class::AssertionError)
      end
      let(:message_options) do
        hsh = defined?(super()) ? super() : options
        hsh = hsh.merge(as: false) if deferred_options.fetch(:skip_as, false)
        hsh
      end
      let(:configured_message) do
        next expected_message if defined?(expected_message)

        scope = "sleeping_king_studios.tools.assertions.#{error_key}"

        assertions.error_message_for(scope, **message_options)
      end

      it { expect { assert }.to raise_error error_class, configured_message }

      unless deferred_options.fetch(:skip_as, false)
        describe 'with as: value' do
          let(:options) { super().merge(as: 'custom name') }

          specify do
            expect { assert }.to raise_error error_class, configured_message
          end
        end
      end

      describe 'with message: value' do
        let(:options) { super().merge(message: 'something went wrong') }

        it { expect { assert }.to raise_error error_class, options[:message] }
      end
    end
  end

  deferred_examples 'should pass the assertion' do
    it { expect { assert }.not_to raise_error }
  end

  let(:error_class) { described_class::AssertionError }
  let(:options)     { {} }

  describe '::AssertionError' do
    it { expect(described_class::AssertionError).to be_a Class }

    it { expect(described_class::AssertionError).to be < StandardError }
  end

  describe '.instance' do
    it { expect(described_class).to respond_to(:instance).with(0).arguments }

    it { expect(described_class.instance).to be_a described_class }

    it 'should cache the instance' do
      cached = described_class.instance

      expect(described_class.instance).to be cached
    end
  end

  include_deferred 'should define the assertion methods'

  include_deferred 'should define the assertion methods',
    error_class: ArgumentError,
    prefix:      :validate

  context 'with error_class: value' do
    let(:error_class) { ArgumentError }
    let(:options)     { super().merge(error_class:) }

    include_deferred 'should define the assertion methods'
  end

  describe '#aggregator_class' do
    it { expect(assertions).to respond_to(:aggregator_class).with(0).arguments }

    it { expect(assertions.aggregator_class).to be described_class::Aggregator }
  end

  describe '#assert_group' do
    it 'should alias the method' do
      expect(assertions).to have_aliased_method(:assert_group).as(:aggregate)
    end
  end

  describe '#assert_inherits_from' do
    it 'should alias the method' do
      expect(assertions)
        .to have_aliased_method(:assert_inherits_from)
        .as(:assert_subclass)
    end
  end

  describe '#error_message_for' do
    let(:scope)   { nil }
    let(:options) { {} }

    define_method :error_message do
      assertions.error_message_for(scope, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:error_message_for)
        .with(1).argument
        .and_any_keywords
    end

    describe 'with scope: an unknown String' do
      let(:scope)    { 'spec.custom.scope' }
      let(:expected) { 'Error message missing: spec.custom.scope' }

      it { expect(error_message).to be == expected }
    end

    describe 'with scope: an unknown Symbol' do
      let(:scope)    { :'spec.custom.scope' }
      let(:expected) { 'Error message missing: spec.custom.scope' }

      it { expect(error_message).to be == expected }
    end

    describe 'with scope: a valid String' do
      let(:scope)    { 'sleeping_king_studios.tools.assertions.blank' }
      let(:expected) { 'value must be nil or empty' }

      it { expect(error_message).to be == expected }

      describe 'with as: false' do
        let(:options)  { super().merge(as: false) }
        let(:expected) { 'must be nil or empty' }

        it { expect(error_message).to be == expected }
      end

      describe 'with as: value' do
        let(:options)  { super().merge(as: 'item') }
        let(:expected) { 'item must be nil or empty' }

        it { expect(error_message).to be == expected }
      end

      describe 'with options: Hash' do
        let(:scope)    { 'sleeping_king_studios.tools.assertions.instance_of' }
        let(:options)  { super().merge(expected: String) }
        let(:expected) { 'value is not an instance of String' }

        it { expect(error_message).to be == expected }
      end
    end

    describe 'with scope: a valid Symbol' do
      let(:scope)    { :'sleeping_king_studios.tools.assertions.blank' }
      let(:expected) { 'value must be nil or empty' }

      it { expect(error_message).to be == expected }

      describe 'with as: false' do
        let(:options)  { super().merge(as: false) }
        let(:expected) { 'must be nil or empty' }

        it { expect(error_message).to be == expected }
      end

      describe 'with as: value' do
        let(:options)  { super().merge(as: 'item') }
        let(:expected) { 'item must be nil or empty' }

        it { expect(error_message).to be == expected }
      end

      describe 'with options: Hash' do
        let(:scope)    { :'sleeping_king_studios.tools.assertions.instance_of' }
        let(:options)  { super().merge(expected: String) }
        let(:expected) { 'value is not an instance of String' }

        it { expect(error_message).to be == expected }
      end
    end
  end
end
