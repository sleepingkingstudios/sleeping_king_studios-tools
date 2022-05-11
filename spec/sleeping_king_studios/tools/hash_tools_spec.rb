# frozen_string_literal: true

require 'spec_helper'

require 'sleeping_king_studios/tools/hash_tools'

RSpec.describe SleepingKingStudios::Tools::HashTools do
  extend RSpec::SleepingKingStudios::Concerns::WrapExamples

  include Spec::Examples::HashExamples

  let(:instance) { described_class.instance }

  describe '#convert_keys_to_strings' do
    it 'should define the method' do
      expect(instance).to respond_to(:convert_keys_to_strings).with(1).argument
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:convert_keys_to_strings)
        .with(1).argument
    end

    it 'should alias the method' do
      expect(instance)
        .to have_aliased_method(:convert_keys_to_strings)
        .as(:stringify_keys)
    end

    it 'should define the aliased class method' do
      expect(described_class)
        .to respond_to(:stringify_keys)
        .with(1).argument
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.convert_keys_to_strings nil }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an object' do
      it 'should raise an error' do
        expect { described_class.convert_keys_to_strings Object.new }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an empty hash' do
      let(:hsh) { {} }

      it { expect(described_class.convert_keys_to_strings(hsh)).to be_a(Hash) }

      it { expect(described_class.convert_keys_to_strings(hsh)).to be_empty }

      it { expect(described_class.convert_keys_to_strings(hsh)).not_to be hsh }
    end

    describe 'with a hash with string keys' do
      let(:hsh) { { 'ichi' => 1, 'ni' => 2, 'san' => 3 } }

      it { expect(described_class.convert_keys_to_strings(hsh)).to be == hsh }

      it { expect(described_class.convert_keys_to_strings(hsh)).not_to be hsh }
    end

    describe 'with a hash with symbol keys' do
      let(:hsh)      { { ichi: 1, ni: 2, san: 3 } }
      let(:expected) { { 'ichi' => 1, 'ni' => 2, 'san' => 3 } }

      it 'should convert the keys to strings' do
        expect(described_class.convert_keys_to_strings(hsh)).to be == expected
      end
    end

    describe 'with a hash with nested arrays' do
      let(:hsh) do
        {
          languages: [
            { one:  1, two: 2, three: 3 },
            { ichi: 1, ni:  2, san:   3 },
            { uno:  1, dos: 2, tres:  3 }
          ]
        }
      end
      let(:expected) do
        {
          'languages' => [
            { 'one'  => 1, 'two' => 2, 'three' => 3 },
            { 'ichi' => 1, 'ni'  => 2, 'san'   => 3 },
            { 'uno'  => 1, 'dos' => 2, 'tres'  => 3 }
          ]
        }
      end

      it 'should convert the keys to strings' do
        cpy = described_class.convert_keys_to_strings(hsh)

        expect(cpy).to be == expected
      end
    end

    describe 'with a hash with nested hashes' do
      let(:hsh) do
        {
          english:  { one:  1, two: 2, three: 3 },
          japanese: { ichi: 1, ni:  2, san:   3 },
          spanish:  { uno:  1, dos: 2, tres:  3 }
        }
      end
      let(:expected) do
        {
          'english'  => { 'one'  => 1, 'two' => 2, 'three' => 3 },
          'japanese' => { 'ichi' => 1, 'ni'  => 2, 'san'   => 3 },
          'spanish'  => { 'uno'  => 1, 'dos' => 2, 'tres'  => 3 }
        }
      end

      it 'should convert the keys to strings' do
        cpy = described_class.convert_keys_to_strings(hsh)

        expect(cpy).to be == expected
      end
    end
  end

  describe '#convert_keys_to_symbols' do
    it 'should define the method' do
      expect(instance).to respond_to(:convert_keys_to_symbols).with(1).argument
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:convert_keys_to_symbols)
        .with(1).argument
    end

    it 'should alias the method' do
      expect(instance)
        .to have_aliased_method(:convert_keys_to_symbols)
        .as(:symbolize_keys)
    end

    it 'should define the aliased class method' do
      expect(described_class)
        .to respond_to(:symbolize_keys)
        .with(1).argument
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.convert_keys_to_symbols nil }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an object' do
      it 'should raise an error' do
        expect { described_class.convert_keys_to_symbols Object.new }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an empty hash' do
      let(:hsh) { {} }

      it { expect(described_class.convert_keys_to_symbols(hsh)).to be_a(Hash) }

      it { expect(described_class.convert_keys_to_symbols(hsh)).to be_empty }

      it { expect(described_class.convert_keys_to_symbols(hsh)).not_to be hsh }
    end

    describe 'with a hash with string keys' do
      let(:hsh)      { { 'ichi' => 1, 'ni' => 2, 'san' => 3 } }
      let(:expected) { { ichi: 1, ni: 2, san: 3 } }

      it 'should convert the keys to symbols' do
        cpy = described_class.convert_keys_to_symbols(hsh)

        expect(cpy).to be == expected
      end
    end

    describe 'with a hash with symbol keys' do
      let(:hsh) { { ichi: 1, ni: 2, san: 3 } }

      it { expect(described_class.convert_keys_to_symbols(hsh)).to be == hsh }

      it { expect(described_class.convert_keys_to_symbols(hsh)).not_to be hsh }
    end

    describe 'with a hash with nested arrays' do
      let(:hsh) do
        {
          'languages' => [
            { 'one'  => 1, 'two' => 2, 'three' => 3 },
            { 'ichi' => 1, 'ni'  => 2, 'san'   => 3 },
            { 'uno'  => 1, 'dos' => 2, 'tres'  => 3 }
          ]
        }
      end
      let(:expected) do
        {
          languages: [
            { one:  1, two: 2, three: 3 },
            { ichi: 1, ni:  2, san:   3 },
            { uno:  1, dos: 2, tres:  3 }
          ]
        }
      end

      it 'should convert the keys to symbols' do
        cpy = described_class.convert_keys_to_symbols(hsh)

        expect(cpy).to be == expected
      end
    end

    describe 'with a hash with nested hashes' do
      let(:hsh) do
        {
          'english'  => { 'one'  => 1, 'two' => 2, 'three' => 3 },
          'japanese' => { 'ichi' => 1, 'ni'  => 2, 'san'   => 3 },
          'spanish'  => { 'uno'  => 1, 'dos' => 2, 'tres'  => 3 }
        }
      end
      let(:expected) do
        {
          english:  { one:  1, two: 2, three: 3 },
          japanese: { ichi: 1, ni:  2, san:   3 },
          spanish:  { uno:  1, dos: 2, tres:  3 }
        }
      end

      it 'should convert the keys to symbols' do
        cpy = described_class.convert_keys_to_symbols(hsh)

        expect(cpy).to be == expected
      end
    end
  end

  describe '#deep_dup' do
    it { expect(instance).to respond_to(:deep_dup).with(1).argument }

    it { expect(described_class).to respond_to(:deep_dup).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.deep_dup nil }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an object' do
      it 'should raise an error' do
        expect { described_class.deep_dup Object.new }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    include_examples 'should create a deep copy of a hash'
  end

  describe '#deep_freeze' do
    it { expect(instance).to respond_to(:deep_freeze).with(1).argument }

    it { expect(described_class).to respond_to(:deep_freeze).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.deep_freeze nil }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an object' do
      it 'should raise an error' do
        expect { described_class.deep_freeze Object.new }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    include_examples 'should perform a deep freeze of the hash'
  end

  describe '#generate_binding' do
    it { expect(instance).to respond_to(:generate_binding).with(1).argument }

    it 'should define the method' do
      expect(described_class).to respond_to(:generate_binding).with(1).argument
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.generate_binding nil }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an empty hash' do
      it { expect(described_class.generate_binding({})).to be_a Binding }
    end

    describe 'with a hash with values' do
      let(:hash) do
        {
          first:  1,
          second: 'a String',
          third:  Object.new
        }
      end

      it { expect(described_class.generate_binding(hash)).to be_a Binding }

      it 'should bind the hash values', :aggregate_failures do
        binding = described_class.generate_binding(hash)

        hash.each do |key, value|
          expect(binding.local_variable_defined?(key)).to be true
          expect(binding.local_variable_get(key)).to be == value
        end
      end
    end
  end

  describe '#hash?' do
    it { expect(instance).to respond_to(:hash?).with(1).argument }

    it { expect(described_class).to respond_to(:hash?).with(1).argument }

    describe 'with nil' do
      it { expect(described_class.hash? nil).to be false }
    end

    describe 'with an object' do
      it { expect(described_class.hash? Object.new).to be false }
    end

    describe 'with a struct' do
      let(:struct_class) { Struct.new(:title) }
      let(:struct)       { struct_class.new 'The Art of War' }

      it { expect(described_class.hash? struct).to be false }
    end

    describe 'with a string' do
      it { expect(described_class.hash? 'greetings,programs').to be false }
    end

    describe 'with an integer' do
      it { expect(described_class.hash? 42).to be false }
    end

    describe 'with an empty array' do
      it { expect(described_class.hash? []).to be false }
    end

    describe 'with a non-empty array' do
      it { expect(described_class.hash? %w[ichi ni san]).to be false }
    end

    describe 'with an empty hash' do
      it { expect(described_class.hash?({})).to be true }
    end

    describe 'with a non-empty hash' do
      it { expect(described_class.hash?({ greetings: 'programs' })).to be true }
    end
  end

  describe '#immutable?' do
    it { expect(instance).to respond_to(:immutable?).with(1).argument }

    it { expect(described_class).to respond_to(:immutable?).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.immutable? nil }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an object' do
      it 'should raise an error' do
        expect { described_class.immutable? Object.new }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    include_examples 'should test if the hash is immutable'
  end

  describe '#mutable?' do
    let(:hsh) { {} }

    before(:example) do
      allow(instance).to receive(:immutable?).and_call_original
    end

    it { expect(instance).to respond_to(:mutable?).with(1).argument }

    it { expect(described_class).to respond_to(:mutable?).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.mutable? nil }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with an object' do
      it 'should raise an error' do
        expect { described_class.mutable? Object.new }
          .to raise_error ArgumentError, /argument must be a hash/
      end
    end

    describe 'with a hash' do
      before(:example) do
        allow(instance).to receive(:immutable?).with(hsh).and_return(false)
      end

      it { expect(instance.mutable? hsh).to be true }

      it 'should delegate to #immutable?' do
        instance.mutable? hsh

        expect(instance).to have_received(:immutable?).with(hsh)
      end
    end
  end
end
