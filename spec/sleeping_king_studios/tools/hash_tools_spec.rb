# spec/sleeping_king_studios/tools/hash_tools_spec.rb

require 'spec_helper'

require 'sleeping_king_studios/tools/hash_tools'

RSpec.describe SleepingKingStudios::Tools::HashTools do
  extend RSpec::SleepingKingStudios::Concerns::WrapExamples

  include Spec::Examples::HashExamples

  let(:instance) { Object.new.extend described_class }

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
