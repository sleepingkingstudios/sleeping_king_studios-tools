# spec/sleeping_king_studios/tools/array_tools_spec.rb

require 'spec_helper'

require 'sleeping_king_studios/tools/array_tools'

RSpec.describe SleepingKingStudios::Tools::ArrayTools do
  include Spec::Examples::ArrayExamples

  let(:instance) { Object.new.extend described_class }

  describe '#count_values' do
    it { expect(instance).to respond_to(:count_values).with(1).argument }

    it { expect(described_class).to respond_to(:count_values).with(1).argument }

    describe 'with an empty array' do
      it 'returns an empty hash' do
        expect(described_class.count_values []).to be == {}
      end # it
    end # describe

    describe 'with an array with one value' do
      let(:values) { %w(spam) }

      it 'returns the count of each value' do
        expect(described_class.count_values values).to be == { 'spam' => 1 }
      end # it

      describe 'with a block' do
        let(:values) do
          struct = Struct.new(:value)
          super().map { |value| struct.new(value) }
        end # let

        it 'returns the count of each value' do
          expect(described_class.count_values values, &:value).to be == { 'spam' => 1 }
        end # it
      end # describe
    end # describe

    describe 'with an array with many values' do
      let(:values) { %w(spam bacon eggs spam) }

      it 'returns the count of each value' do
        expect(described_class.count_values values).to be == { 'spam' => 2, 'bacon' => 1, 'eggs' => 1 }
      end # it

      describe 'with a block' do
        let(:values) do
          struct = Struct.new(:value)
          super().map { |value| struct.new(value) }
        end # let

        it 'returns the count of each value' do
          expect(described_class.count_values values, &:value).to be == { 'spam' => 2, 'bacon' => 1, 'eggs' => 1 }
        end # it
      end # describe
    end # describe
  end # describe

  describe '#deep_dup' do
    it { expect(instance).to respond_to(:deep_dup).with(1).argument }

    it { expect(described_class).to respond_to(:deep_dup).with(1).argument }

    include_examples 'should create a deep copy of an array'
  end # describe

  describe '#humanize_list' do
    it { expect(instance).to respond_to(:humanize_list).with(1).argument }

    it { expect(described_class).to respond_to(:humanize_list).with(1).argument }

    describe 'with an array with zero items' do
      let(:values) { [] }

      it 'returns an empty string' do
        expect(described_class.humanize_list values).to be == ''
      end # it
    end # describe

    describe 'with an array with one item' do
      let(:values) { %i(foo) }

      it 'returns the item converted to a string' do
        expect(described_class.humanize_list values).to be == values.first.to_s
      end # it
    end # describe

    describe 'with an array with two items' do
      let(:values) { %i(foo bar) }

      it 'returns the items joined by "and"' do
        expect(described_class.humanize_list values).to be == values.join(' and ')
      end # it

      describe 'with :last_separator => " or "' do
        it 'returns the items joined by "and"' do
          expect(described_class.humanize_list values, :last_separator => ' or ').to be == values.join(' or ')
        end # it
      end # describe
    end # describe

    describe 'with an array with three items' do
      let(:values) { %i(foo bar baz) }

      it 'returns the items joined by commas and the last value preceded by "and"' do
        expected = "#{values[0...-1].join(', ')}, and #{values.last}"
        expect(described_class.humanize_list values).to be == expected
      end # it

      describe 'with :separator => ";"' do
        it 'returns the items joined by semicolons and the last value preceded by "and"' do
          expected = "#{values[0...-1].join('; ')}; and #{values.last}"
          expect(described_class.humanize_list values, :separator => "; ").to be == expected
        end # it
      end # describe

      describe 'with :last_separator => " or "' do
        it 'returns the items joined by commas and the last value preceded by "or"' do
          expected = "#{values[0...-1].join(', ')}, or #{values.last}"
          expect(described_class.humanize_list values, :last_separator => ', or ').to be == expected
        end # it
      end # describe
    end # describe
  end # describe
end # describe
