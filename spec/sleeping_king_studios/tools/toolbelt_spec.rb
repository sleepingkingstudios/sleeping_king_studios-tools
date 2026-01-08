# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'

RSpec.describe SleepingKingStudios::Tools::Toolbelt do
  subject(:toolbelt) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  describe '.global' do
    let(:cached_value) { described_class.global }

    it { expect(described_class).to respond_to(:global).with(0).arguments }

    it 'should be an instance of Toolbelt' do
      expect(Object.instance_method(:class).bind(described_class.global).call)
        .to be described_class
    end

    it { expect(described_class).to have_aliased_method(:global).as(:instance) }

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

  describe '.new' do
    describe 'with deprecation_caller_depth: value' do
      let(:constructor_options) do
        super().merge(deprecation_caller_depth: 10)
      end

      it 'should pass the strategy to #core_tools' do
        expect(toolbelt.core_tools.deprecation_caller_depth).to be 10
      end
    end

    describe 'with deprecation_strategy: value' do
      let(:constructor_options) do
        super().merge(deprecation_strategy: 'ignore')
      end

      it 'should pass the strategy to #core_tools' do
        expect(toolbelt.core_tools.deprecation_strategy)
          .to be == 'ignore'
      end
    end

    describe 'with inflector: value' do
      let(:inflector) do
        instance_double(SleepingKingStudios::Tools::Toolbox::Inflector)
      end
      let(:constructor_options) do
        super().merge(inflector:)
      end

      it 'should pass the inflector to #string_tools' do
        expect(toolbelt.string_tools.inflector)
          .to be inflector
      end
    end

    describe 'with messages_registry: value' do
      let(:registry) do
        SleepingKingStudios::Tools::Messages::Registry.new
      end
      let(:constructor_options) do
        super().merge(messages_registry: registry)
      end

      it 'should pass the registry to #messages' do
        expect(toolbelt.messages.registry).to be registry
      end
    end
  end

  describe '#array_tools' do
    it 'should return an instance of ArrayTools' do
      expect(toolbelt.array_tools)
        .to be_a SleepingKingStudios::Tools::ArrayTools
    end
  end

  describe '#assertions' do
    it 'should return an instance of Assertions' do
      expect(toolbelt.assertions)
        .to be_a SleepingKingStudios::Tools::Assertions
    end
  end

  describe '#ary' do
    it 'should return an instance of ArrayTools' do
      expect(toolbelt.ary)
        .to be_a SleepingKingStudios::Tools::ArrayTools
    end
  end

  describe '#core_tools' do
    it 'should return an instance of CoreTools' do
      expect(toolbelt.core_tools)
        .to be_a SleepingKingStudios::Tools::CoreTools
    end
  end

  describe '#hash_tools' do
    it 'should return an instance of HashTools' do
      expect(toolbelt.hash_tools)
        .to be_a SleepingKingStudios::Tools::HashTools
    end
  end

  describe '#hsh' do
    it 'should return an instance of HashTools' do
      expect(toolbelt.hsh)
        .to be_a SleepingKingStudios::Tools::HashTools
    end
  end

  describe '#inspect' do
    it { expect(toolbelt.inspect).to be == "#<#{described_class.name}>" }
  end

  describe '#int' do
    it 'should return an instance of IntegerTools' do
      expect(toolbelt.int)
        .to be_a SleepingKingStudios::Tools::IntegerTools
    end
  end

  describe '#integer_tools' do
    it 'should return an instance of IntegerTools' do
      expect(toolbelt.integer_tools)
        .to be_a SleepingKingStudios::Tools::IntegerTools
    end
  end

  describe '#messages' do
    it 'should return an instance of Messages' do
      expect(toolbelt.messages).to be_a SleepingKingStudios::Tools::Messages
    end

    it 'should configure the Messages tool' do
      expect(toolbelt.messages.registry)
        .to be SleepingKingStudios::Tools::Messages::Registry.global
    end
  end

  describe '#obj' do
    it 'should return an instance of ObjectTools' do
      expect(toolbelt.obj)
        .to be_a SleepingKingStudios::Tools::ObjectTools
    end
  end

  describe '#object_tools' do
    it 'should return an instance of ObjectTools' do
      expect(toolbelt.object_tools)
        .to be_a SleepingKingStudios::Tools::ObjectTools
    end
  end

  describe '#str' do
    it 'should return an instance of StringTools' do
      expect(toolbelt.str)
        .to be_a SleepingKingStudios::Tools::StringTools
    end
  end

  describe '#string_tools' do
    it 'should return an instance of StringTools' do
      expect(toolbelt.string_tools)
        .to be_a SleepingKingStudios::Tools::StringTools
    end
  end

  describe '#to_s' do
    it { expect(toolbelt.to_s).to be == "#<#{described_class.name}>" }
  end
end
