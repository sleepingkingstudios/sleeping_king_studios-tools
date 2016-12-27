# spec/sleeping_king_studios/tools/hash_tools_spec.rb

require 'spec_helper'

require 'sleeping_king_studios/tools/hash_tools'

RSpec.describe SleepingKingStudios::Tools::HashTools do
  extend RSpec::SleepingKingStudios::Concerns::WrapExamples

  include Spec::Examples::HashExamples

  let(:instance) { Object.new.extend described_class }

  describe '#convert_keys_to_strings' do
    it { expect(instance).to respond_to(:convert_keys_to_strings).with(1).argument }

    it { expect(described_class).to respond_to(:convert_keys_to_strings).with(1).argument }

    it { expect(instance).to alias_method(:convert_keys_to_strings).as(:stringify_keys) }

    it { expect(described_class).to alias_method(:convert_keys_to_strings).as(:stringify_keys) }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.convert_keys_to_strings nil }.
          to raise_error ArgumentError, /argument must be a hash/
      end # it
    end # describe

    describe 'with an object' do
      it 'should raise an error' do
        expect { described_class.convert_keys_to_strings Object.new }.
          to raise_error ArgumentError, /argument must be a hash/
      end # it
    end # describe

    describe 'with an empty hash' do
      let(:hsh) { {} }

      it 'should return a copy of the hash' do
        cpy = described_class.convert_keys_to_symbols(hsh)

        expect(cpy).to be_empty
        expect(cpy).not_to be hsh
      end # it
    end # describe

    describe 'with a hash with string keys' do
      let(:hsh) do
        { 'ichi' => 1, 'ni' => 2, 'san' => 3 }
      end # let

      it 'should convert the keys to string' do
        cpy = described_class.convert_keys_to_strings(hsh)

        expect(cpy).to be == hsh
        expect(cpy).not_to be hsh
      end # it
    end # describe

    describe 'with a hash with symbol keys' do
      let(:hsh) do
        { :ichi => 1, :ni => 2, :san => 3 }
      end # let
      let(:expected) do
        { 'ichi' => 1, 'ni' => 2, 'san' => 3 }
      end # let

      it 'should convert the keys to strings' do
        cpy = described_class.convert_keys_to_strings(hsh)

        expect(cpy).to be == expected
      end # it
    end # describe

    describe 'with a hash with nested arrays' do
      let(:hsh) do
        {
          :languages => [
            { :one  => 1, :two => 2, :three => 3 },
            { :ichi => 1, :ni  => 2, :san   => 3 },
            { :uno  => 1, :dos => 2, :tres  => 3 }
          ] # end array
        } # end hash
      end # let
      let(:expected) do
        {
          'languages' => [
            { 'one'  => 1, 'two' => 2, 'three' => 3 },
            { 'ichi' => 1, 'ni'  => 2, 'san'   => 3 },
            { 'uno'  => 1, 'dos' => 2, 'tres'  => 3 }
          ] # end array
        } # end hash
      end # let

      it 'should convert the keys to strings' do
        cpy = described_class.convert_keys_to_strings(hsh)

        expect(cpy).to be == expected
      end # it
    end # describe

    describe 'with a hash with nested hashes' do
      let(:hsh) do
        {
          :english  => { :one  => 1, :two => 2, :three => 3 },
          :japanese => { :ichi => 1, :ni  => 2, :san   => 3 },
          :spanish  => { :uno  => 1, :dos => 2, :tres  => 3 }
        } # end hash
      end # let
      let(:expected) do
        {
          'english'  => { 'one'  => 1, 'two' => 2, 'three' => 3 },
          'japanese' => { 'ichi' => 1, 'ni'  => 2, 'san'   => 3 },
          'spanish'  => { 'uno'  => 1, 'dos' => 2, 'tres'  => 3 }
        } # end hash
      end # let

      it 'should convert the keys to strings' do
        cpy = described_class.convert_keys_to_strings(hsh)

        expect(cpy).to be == expected
      end # it
    end # describe
  end # describe

  describe '#convert_keys_to_symbols' do
    it { expect(instance).to respond_to(:convert_keys_to_symbols).with(1).argument }

    it { expect(described_class).to respond_to(:convert_keys_to_symbols).with(1).argument }

    it { expect(instance).to alias_method(:convert_keys_to_symbols).as(:symbolize_keys) }

    it { expect(described_class).to alias_method(:convert_keys_to_symbols).as(:symbolize_keys) }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.convert_keys_to_symbols nil }.
          to raise_error ArgumentError, /argument must be a hash/
      end # it
    end # describe

    describe 'with an object' do
      it 'should raise an error' do
        expect { described_class.convert_keys_to_symbols Object.new }.
          to raise_error ArgumentError, /argument must be a hash/
      end # it
    end # describe

    describe 'with an empty hash' do
      let(:hsh) { {} }

      it 'should return a copy of the hash' do
        cpy = described_class.convert_keys_to_symbols(hsh)

        expect(cpy).to be_empty
        expect(cpy).not_to be hsh
      end # it
    end # describe

    describe 'with a hash with string keys' do
      let(:hsh) do
        { 'ichi' => 1, 'ni' => 2, 'san' => 3 }
      end # let
      let(:expected) do
        { :ichi => 1, :ni => 2, :san => 3 }
      end # let

      it 'should convert the keys to symbols' do
        cpy = described_class.convert_keys_to_symbols(hsh)

        expect(cpy).to be == expected
      end # it
    end # describe

    describe 'with a hash with symbol keys' do
      let(:hsh) do
        { :ichi => 1, :ni => 2, :san => 3 }
      end # let

      it 'should convert the keys to symbols' do
        cpy = described_class.convert_keys_to_symbols(hsh)

        expect(cpy).to be == hsh
        expect(cpy).not_to be hsh
      end # it
    end # describe

    describe 'with a hash with nested arrays' do
      let(:hsh) do
        {
          'languages' => [
            { 'one'  => 1, 'two' => 2, 'three' => 3 },
            { 'ichi' => 1, 'ni'  => 2, 'san'   => 3 },
            { 'uno'  => 1, 'dos' => 2, 'tres'  => 3 }
          ] # end array
        } # end hash
      end # let
      let(:expected) do
        {
          :languages => [
            { :one  => 1, :two => 2, :three => 3 },
            { :ichi => 1, :ni  => 2, :san   => 3 },
            { :uno  => 1, :dos => 2, :tres  => 3 }
          ] # end array
        } # end hash
      end # let

      it 'should convert the keys to symbols' do
        cpy = described_class.convert_keys_to_symbols(hsh)

        expect(cpy).to be == expected
      end # it
    end # describe

    describe 'with a hash with nested hashes' do
      let(:hsh) do
        {
          'english'  => { 'one'  => 1, 'two' => 2, 'three' => 3 },
          'japanese' => { 'ichi' => 1, 'ni'  => 2, 'san'   => 3 },
          'spanish'  => { 'uno'  => 1, 'dos' => 2, 'tres'  => 3 }
        } # end hash
      end # let
      let(:expected) do
        {
          :english  => { :one  => 1, :two => 2, :three => 3 },
          :japanese => { :ichi => 1, :ni  => 2, :san   => 3 },
          :spanish  => { :uno  => 1, :dos => 2, :tres  => 3 }
        } # end hash
      end # let

      it 'should convert the keys to symbols' do
        cpy = described_class.convert_keys_to_symbols(hsh)

        expect(cpy).to be == expected
      end # it
    end # describe
  end # describe

  describe '#deep_dup' do
    it { expect(instance).to respond_to(:deep_dup).with(1).argument }

    it { expect(described_class).to respond_to(:deep_dup).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.deep_dup nil }.
          to raise_error ArgumentError, /argument must be a hash/
      end # it
    end # describe

    describe 'with an object' do
      it 'should raise an error' do
        expect { described_class.deep_dup Object.new }.
          to raise_error ArgumentError, /argument must be a hash/
      end # it
    end # describe

    include_examples 'should create a deep copy of a hash'
  end # describe

  describe '#deep_freeze' do
    it { expect(instance).to respond_to(:deep_freeze).with(1).argument }

    it { expect(described_class).to respond_to(:deep_freeze).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.deep_freeze nil }.
          to raise_error ArgumentError, /argument must be a hash/
      end # it
    end # describe

    describe 'with an object' do
      it 'should raise an error' do
        expect { described_class.deep_freeze Object.new }.
          to raise_error ArgumentError, /argument must be a hash/
      end # it
    end # describe

    include_examples 'should perform a deep freeze of the hash'
  end # describe

  describe '#hash?' do
    it { expect(instance).to respond_to(:hash?).with(1).argument }

    it { expect(described_class).to respond_to(:hash?).with(1).argument }

    describe 'with nil' do
      it { expect(described_class.hash? nil).to be false }
    end # describe

    describe 'with an object' do
      it { expect(described_class.hash? Object.new).to be false }
    end # describe

    describe 'with a struct' do
      let(:struct_class) { Struct.new(:title) }
      let(:struct)       { struct_class.new 'The Art of War' }

      it { expect(described_class.hash? struct).to be false }
    end # describe

    describe 'with a string' do
      it { expect(described_class.hash? 'greetings,programs').to be false }
    end # describe

    describe 'with an integer' do
      it { expect(described_class.hash? 42).to be false }
    end # describe

    describe 'with an empty array' do
      it { expect(described_class.hash? []).to be false }
    end # describe

    describe 'with a non-empty array' do
      it { expect(described_class.hash? %w(ichi ni san)).to be false }
    end # describe

    describe 'with an empty hash' do
      it { expect(described_class.hash?({})).to be true }
    end # describe

    describe 'with a non-empty hash' do
      it { expect(described_class.hash?({ :greetings => 'programs' })).to be true }
    end # describe
  end # describe

  describe '#immutable?' do
    it { expect(instance).to respond_to(:immutable?).with(1).argument }

    it { expect(described_class).to respond_to(:immutable?).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.immutable? nil }.
          to raise_error ArgumentError, /argument must be a hash/
      end # it
    end # describe

    describe 'with an object' do
      it 'should raise an error' do
        expect { described_class.immutable? Object.new }.
          to raise_error ArgumentError, /argument must be a hash/
      end # it
    end # describe

    include_examples 'should test if the hash is immutable'
  end # describe

  describe '#mutable?' do
    let(:hsh) { {} }

    it { expect(instance).to respond_to(:mutable?).with(1).argument }

    it { expect(described_class).to respond_to(:mutable?).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.mutable? nil }.
          to raise_error ArgumentError, /argument must be a hash/
      end # it
    end # describe

    describe 'with an object' do
      it 'should raise an error' do
        expect { described_class.mutable? Object.new }.
          to raise_error ArgumentError, /argument must be a hash/
      end # it
    end # describe

    it 'should return the inverse of immutable' do
      expect(instance).to receive(:immutable?).with(hsh).and_return(false)

      expect(instance.mutable? hsh).to be true
    end # it
  end # describe
end # describe
