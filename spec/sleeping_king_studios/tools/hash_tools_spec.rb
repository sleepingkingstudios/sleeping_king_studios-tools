# spec/sleeping_king_studios/tools/hash_tools_spec.rb

require 'spec_helper'

require 'sleeping_king_studios/tools/hash_tools'

RSpec.describe SleepingKingStudios::Tools::HashTools do
  include Spec::Examples::HashExamples

  let(:instance) { Object.new.extend described_class }

  describe '#deep_dup' do
    it { expect(instance).to respond_to(:deep_dup).with(1).argument }

    it { expect(described_class).to respond_to(:deep_dup).with(1).argument }

    include_examples 'should create a deep copy of a hash'
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
end # describe
