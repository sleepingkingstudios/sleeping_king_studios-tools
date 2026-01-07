# frozen_string_literal: true

require 'sleeping_king_studios/tools/messages/registry'
require 'sleeping_king_studios/tools/messages/strategy'

RSpec.describe SleepingKingStudios::Tools::Messages::Registry do
  subject(:registry) { described_class.new }

  deferred_context 'when the registry has many strategies' do
    let(:messages_strategy) do
      SleepingKingStudios::Tools::Messages::Strategy.new
    end
    let(:rocket_parts_strategy) do
      SleepingKingStudios::Tools::Messages::Strategy.new
    end
    let(:rockets_strategy) do
      SleepingKingStudios::Tools::Messages::Strategy.new
    end
    let(:space_strategy) do
      SleepingKingStudios::Tools::Messages::Strategy.new
    end
    let(:strategies) do
      {
        'space'               => space_strategy,
        'space.messages'      => messages_strategy,
        'space.rockets'       => rockets_strategy,
        'space.rockets.parts' => rocket_parts_strategy
      }
    end

    before(:example) do
      strategies.each { |scope, strategy| registry.register(scope:, strategy:) }
    end
  end

  describe '::StrategyAlreadyExistsError' do
    include_examples 'should define constant',
      :StrategyAlreadyExistsError,
      -> { be_a(Class).and(be < StandardError) }
  end

  describe '.global' do
    let(:cached_value) { described_class.global }

    it { expect(described_class).to respond_to(:global).with(0).arguments }

    it { expect(described_class.global).to be_a described_class }

    it { expect(described_class.global).to be cached_value }

    context 'when accessed by multiple threads' do
      let(:values) do
        []
      end
      let(:threads) do
        Array.new(3) do |index|
          Thread.new { values[index] = described_class.global }
        end
      end

      before(:example) do
        described_class.instance_variable_set(:@global, nil)

        allow(described_class).to receive(:new).and_wrap_original do |original|
          sleep 1

          original.call
        end
      end

      around(:example) do |example|
        value = described_class.instance_variable_get(:@global)

        example.call
      ensure
        described_class.instance_variable_set(:@global, value)
      end

      it 'should synchronize the cached values', :aggregate_failures do
        threads.map(&:join)

        expect(values.size).to be 3
        expect(values).to all be cached_value
      end
    end
  end

  describe '#get' do
    it { expect(registry).to respond_to(:get).with(1).argument }

    it { expect(registry).to have_aliased_method(:get).as(:[]) }

    describe 'with nil' do
      let(:error_message) do
        "scope can't be blank"
      end

      it 'should raise an exception' do
        expect { registry.get(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:error_message) do
        'scope is not a String or a Symbol'
      end

      it 'should raise an exception' do
        expect { registry.get(Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty String' do
      let(:error_message) do
        "scope can't be blank"
      end

      it 'should raise an exception' do
        expect { registry.get('') }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty Symbol' do
      let(:error_message) do
        "scope can't be blank"
      end

      it 'should raise an exception' do
        expect { registry.get(:'') }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a non-matching key' do
      it { expect(registry.get('time.machine.coordinates')).to be nil }
    end

    wrap_deferred 'when the registry has many strategies' do
      describe 'with a non-matching key' do
        it { expect(registry.get('time.machine.coordinates')).to be nil }
      end

      describe 'with a key matching a top-level scope' do
        it 'should return the matching strategy' do
          expect(registry.get('space')).to be space_strategy
        end
      end

      describe 'with a scoped key matching a top-level scope' do
        it 'should return the matching strategy' do
          expect(registry.get('space.planets')).to be space_strategy
        end
      end

      describe 'with a key matching a nested scope' do
        it 'should return the matching strategy' do
          expect(registry.get('space.rockets')).to be rockets_strategy
        end
      end

      describe 'with a scoped key matching a nested scope' do
        it 'should return the matching strategy' do
          expect(registry.get('space.rockets.prefabs')).to be rockets_strategy
        end
      end

      describe 'with a key matching a deeply nested scope' do
        it 'should return the matching strategy' do
          expect(registry.get('space.rockets.parts'))
            .to be rocket_parts_strategy
        end
      end

      describe 'with a scoped key matching a deeply nested scope' do
        it 'should return the matching strategy' do
          expect(registry.get('space.rockets.parts.engines.hydrolox'))
            .to be rocket_parts_strategy
        end
      end

      describe 'with a key matching a leaf scope' do
        it 'should return the matching strategy' do
          expect(registry.get('space.messages')).to be messages_strategy
        end
      end

      describe 'with a scoped key matching a leaf scope' do
        it 'should return the matching strategy' do
          expect(registry.get('space.messages.errors.failure'))
            .to be messages_strategy
        end
      end
    end
  end

  describe '#register' do
    let(:scope)    { 'space.errors' }
    let(:strategy) { SleepingKingStudios::Tools::Messages::Strategy.new }

    it 'should define the method' do
      expect(registry)
        .to respond_to(:register)
        .with(0).arguments
        .and_keywords(:force, :scope, :strategy)
    end

    it { expect(registry).to have_aliased_method(:register).as(:add) }

    it { expect(registry.register(scope:, strategy:)).to be registry }

    it 'should add the strategy to the registry' do
      expect { registry.register(scope:, strategy:) }.to(
        change { registry.get(scope) }.to be strategy
      )
    end

    it 'should set the strategy for child scopes' do
      expect { registry.register(scope:, strategy:) }.to(
        change { registry.get('space.errors.messages') }.to be strategy
      )
    end

    describe 'with scope: nil' do
      let(:error_message) do
        "scope can't be blank"
      end

      it 'should raise an exception' do
        expect { registry.register(scope: nil, strategy:) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with scope: an Object' do
      let(:error_message) do
        'scope is not a String or a Symbol'
      end

      it 'should raise an exception' do
        expect { registry.register(scope: Object.new.freeze, strategy:) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with scope: an empty String' do
      let(:error_message) do
        "scope can't be blank"
      end

      it 'should raise an exception' do
        expect { registry.register(scope: '', strategy:) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with scope: an empty Symbol' do
      let(:error_message) do
        "scope can't be blank"
      end

      it 'should raise an exception' do
        expect { registry.register(scope: :'', strategy:) }
          .to raise_error ArgumentError, error_message
      end
    end

    wrap_deferred 'when the registry has many strategies' do
      it 'should add the strategy to the registry' do
        expect { registry.register(scope:, strategy:) }.to(
          change { registry.get(scope) }.to be strategy
        )
      end

      describe 'with scope: an existing scope' do
        let(:scope) { 'space.messages' }
        let(:error_message) do
          "strategy already exists with scope #{scope}"
        end

        it 'should raise an exception' do
          expect { registry.register(scope:, strategy:) }
            .to raise_error(
              described_class::StrategyAlreadyExistsError,
              error_message
            )
        end

        describe 'with force: true' do
          it 'should add the strategy to the registry' do
            expect { registry.register(scope:, strategy:, force: true) }.to(
              change { registry.get(scope) }.to be strategy
            )
          end
        end
      end

      describe 'with scope: an ancestor of an existing scope' do
        let(:inventors_strategy) do
          SleepingKingStudios::Tools::Messages::Strategy.new
        end
        let(:scope) { 'time' }

        before(:example) do
          registry.register(
            scope:    'time.machines.inventors',
            strategy: inventors_strategy
          )
        end

        it 'should add the strategy to the registry' do
          expect { registry.register(scope:, strategy:) }.to(
            change { registry.get(scope) }.to be strategy
          )
        end

        it 'should set the strategy for the child scope' do
          expect { registry.register(scope:, strategy:) }.to(
            change { registry.get('time.machines') }.to be strategy
          )
        end

        it 'should not change the strategy for the ancestor scope' do
          expect { registry.register(scope:, strategy:) }.not_to(
            change { registry.get('time.machines.inventors') }
          )
        end
      end

      describe 'with scope: a parent of an existing scope' do
        let(:inventors_strategy) do
          SleepingKingStudios::Tools::Messages::Strategy.new
        end
        let(:scope) { 'time.machines' }

        before(:example) do
          registry.register(
            scope:    'time.machines.inventors',
            strategy: inventors_strategy
          )
        end

        it 'should add the strategy to the registry' do
          expect { registry.register(scope:, strategy:) }.to(
            change { registry.get(scope) }.to be strategy
          )
        end

        it 'should not change the strategy for the parent scope' do
          expect { registry.register(scope:, strategy:) }.not_to(
            change { registry.get('time') }
          )
        end

        it 'should not change the strategy for the child scope' do
          expect { registry.register(scope:, strategy:) }.not_to(
            change { registry.get('time.machines.inventors') }
          )
        end
      end

      describe 'with scope: a child of an existing scope' do
        let(:time_strategy) do
          SleepingKingStudios::Tools::Messages::Strategy.new
        end
        let(:scope) { 'time.machines' }

        before(:example) do
          registry.register(
            scope:    'time',
            strategy: time_strategy
          )
        end

        it 'should add the strategy to the registry' do
          expect { registry.register(scope:, strategy:) }.to(
            change { registry.get(scope) }.to be strategy
          )
        end

        it 'should not change the strategy for the parent scope' do
          expect { registry.register(scope:, strategy:) }.not_to(
            change { registry.get('time') }
          )
        end

        it 'should set the strategy for the child scope' do
          expect { registry.register(scope:, strategy:) }.to(
            change { registry.get('time.machines.inventors') }.to be strategy
          )
        end
      end

      describe 'with scope: a descendent of an existing scope' do
        let(:time_strategy) do
          SleepingKingStudios::Tools::Messages::Strategy.new
        end
        let(:scope) { 'time.machines.inventors' }

        before(:example) do
          registry.register(
            scope:    'time',
            strategy: time_strategy
          )
        end

        it 'should add the strategy to the registry' do
          expect { registry.register(scope:, strategy:) }.to(
            change { registry.get(scope) }.to be strategy
          )
        end

        it 'should not change the strategy for the parent scope' do
          expect { registry.register(scope:, strategy:) }.not_to(
            change { registry.get('time.machines') }
          )
        end

        it 'should set the strategy for the child scope' do
          expect { registry.register(scope:, strategy:) }.to(
            change { registry.get('time.machines.inventors.laboratories') }
              .to be strategy
          )
        end
      end

      describe 'with scope: a scope with existing parent and child scopes' do
        let(:time_strategy) do
          SleepingKingStudios::Tools::Messages::Strategy.new
        end
        let(:inventors_strategy) do
          SleepingKingStudios::Tools::Messages::Strategy.new
        end
        let(:scope) { 'time.machines' }

        before(:example) do
          registry.register(
            scope:    'time',
            strategy: time_strategy
          )
          registry.register(
            scope:    'time.machines.inventors',
            strategy: inventors_strategy
          )
        end

        it 'should add the strategy to the registry' do
          expect { registry.register(scope:, strategy:) }.to(
            change { registry.get(scope) }.to be strategy
          )
        end

        it 'should not change the strategy for the parent scope' do
          expect { registry.register(scope:, strategy:) }.not_to(
            change { registry.get('time') }
          )
        end

        it 'should not change the strategy for the child scope' do
          expect { registry.register(scope:, strategy:) }.not_to(
            change { registry.get('time.machines.inventors') }
          )
        end
      end
    end
  end

  describe '#strategies' do
    include_examples 'should define reader', :strategies, {}

    it { expect(registry.strategies).to be_frozen }

    wrap_deferred 'when the registry has many strategies' do
      it { expect(registry.strategies).to be == strategies }

      it { expect(registry.strategies).to be_frozen }
    end
  end
end
