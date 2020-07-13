# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbelt'

RSpec.describe SleepingKingStudios::Tools::Toolbelt do
  let(:instance) { described_class.instance }

  describe '.instance' do
    it { expect(described_class).to have_reader(:instance) }

    it 'should return an instance' do
      klass = Kernel.instance_method(:class).bind(described_class.instance).call

      expect(klass).to be described_class
    end

    it 'should cache the instance' do
      previous = described_class.instance

      expect(described_class.instance.equal?(previous)).to be true
    end
  end

  describe '.new' do
    describe 'with inflector: value' do
      let(:inflector) do
        instance_double(SleepingKingStudios::Tools::Toolbox::Inflector)
      end
      let(:instance) { described_class.new(inflector: inflector) }

      it 'should pass the inflector to #string_tools' do
        expect(instance.__send__(:string_tools).inflector)
          .to be inflector
      end
    end
  end

  %w[array core hash integer object string].each do |name|
    describe "##{name}" do
      let(:namespace) { SleepingKingStudios::Tools }
      let(:tools)     { namespace.const_get("#{name.capitalize}Tools") }

      before(:example) do
        allow(SleepingKingStudios::Tools::CoreTools).to receive(:deprecate)
      end

      it { expect(instance.__send__ name).to be tools }

      it 'should be deprecated' do # rubocop:disable RSpec/ExampleLength
        instance.__send__(name)

        expect(SleepingKingStudios::Tools::CoreTools)
          .to have_received(:deprecate)
          .with(
            "SleepingKingStudios::Tools::Toolbelt##{name}",
            message: "Use ##{name}_tools instead."
          )
      end
    end
  end

  describe '#array_tools' do
    it 'should return an instance of ArrayTools' do
      expect(instance.__send__ :array_tools)
        .to be_a SleepingKingStudios::Tools::ArrayTools
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
