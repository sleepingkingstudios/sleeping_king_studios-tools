# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'

RSpec.describe SleepingKingStudios::Tools::Toolbelt do
  let(:instance) { described_class.instance }

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
      let(:instance) { described_class.new(deprecation_caller_depth: 10) }

      it 'should pass the strategy to #core_tools' do
        expect(instance.core_tools.deprecation_caller_depth).to be 10
      end
    end

    describe 'with deprecation_strategy: value' do
      let(:instance) { described_class.new(deprecation_strategy: 'ignore') }

      it 'should pass the strategy to #core_tools' do
        expect(instance.core_tools.deprecation_strategy)
          .to be == 'ignore'
      end
    end

    describe 'with inflector: value' do
      let(:inflector) do
        instance_double(SleepingKingStudios::Tools::Toolbox::Inflector)
      end
      let(:instance) { described_class.new(inflector:) }

      it 'should pass the inflector to #string_tools' do
        expect(instance.string_tools.inflector)
          .to be inflector
      end
    end

    describe 'with messages_registry: value' do
      let(:registry) do
        SleepingKingStudios::Tools::Messages::Registry.new
      end
      let(:toolbelt) { described_class.new(messages_registry: registry) }

      it 'should pass the registry to #messages' do
        expect(toolbelt.messages.registry).to be registry
      end
    end
  end

  describe '#array_tools' do
    it 'should return an instance of ArrayTools' do
      expect(instance.__send__ :array_tools)
        .to be_a SleepingKingStudios::Tools::ArrayTools
    end
  end

  describe '#assertions' do
    it 'should return an instance of Assertions' do
      expect(instance.__send__ :assertions)
        .to be_a SleepingKingStudios::Tools::Assertions
    end
  end

  describe '#ary' do
    it 'should return an instance of ArrayTools' do
      expect(instance.__send__ :ary)
        .to be_a SleepingKingStudios::Tools::ArrayTools
    end
  end

  describe '#core_tools' do
    it 'should return an instance of CoreTools' do
      expect(instance.__send__ :core_tools)
        .to be_a SleepingKingStudios::Tools::CoreTools
    end
  end

  describe '#hash_tools' do
    it 'should return an instance of HashTools' do
      expect(instance.__send__ :hash_tools)
        .to be_a SleepingKingStudios::Tools::HashTools
    end
  end

  describe '#hsh' do
    it 'should return an instance of HashTools' do
      expect(instance.__send__ :hsh)
        .to be_a SleepingKingStudios::Tools::HashTools
    end
  end

  describe '#inspect' do
    it { expect(instance.inspect).to be == "#<#{described_class.name}>" }
  end

  describe '#int' do
    it 'should return an instance of IntegerTools' do
      expect(instance.__send__ :int)
        .to be_a SleepingKingStudios::Tools::IntegerTools
    end
  end

  describe '#integer_tools' do
    it 'should return an instance of IntegerTools' do
      expect(instance.__send__ :integer_tools)
        .to be_a SleepingKingStudios::Tools::IntegerTools
    end
  end

  describe '#messages' do
    it 'should return an instance of Messages' do
      expect(instance.messages).to be_a SleepingKingStudios::Tools::Messages
    end

    it 'should configure the Messages tool' do
      expect(instance.messages.registry)
        .to be SleepingKingStudios::Tools::Messages::Registry.global
    end
  end

  describe '#obj' do
    it 'should return an instance of ObjectTools' do
      expect(instance.__send__ :obj)
        .to be_a SleepingKingStudios::Tools::ObjectTools
    end
  end

  describe '#object_tools' do
    it 'should return an instance of ObjectTools' do
      expect(instance.__send__ :object_tools)
        .to be_a SleepingKingStudios::Tools::ObjectTools
    end
  end

  describe '#str' do
    it 'should return an instance of StringTools' do
      expect(instance.__send__ :str)
        .to be_a SleepingKingStudios::Tools::StringTools
    end
  end

  describe '#string_tools' do
    it 'should return an instance of StringTools' do
      expect(instance.__send__ :string_tools)
        .to be_a SleepingKingStudios::Tools::StringTools
    end
  end

  describe '#to_s' do
    it { expect(instance.to_s).to be == "#<#{described_class.name}>" }
  end
end
