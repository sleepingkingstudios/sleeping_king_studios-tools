# spec/sleeping_king_studios/tools/array_tools_spec.rb

require 'spec_helper'

require 'sleeping_king_studios/tools/array_tools'

RSpec.describe SleepingKingStudios::Tools::ArrayTools do
  include Spec::Examples::ArrayExamples

  let(:instance) { Object.new.extend described_class }

  describe '#array?' do
    it { expect(instance).to respond_to(:array?).with(1).argument }

    it { expect(described_class).to respond_to(:array?).with(1).argument }

    describe 'with nil' do
      it { expect(described_class.array? nil).to be false }
    end # describe

    describe 'with an object' do
      it { expect(described_class.array? Object.new).to be false }
    end # describe

    describe 'with a struct' do
      let(:struct_class) { Struct.new(:title) }
      let(:struct)       { struct_class.new 'The Art of War' }

      it { expect(described_class.array? struct).to be false }
    end # describe

    describe 'with a string' do
      it { expect(described_class.array? 'greetings,programs').to be false }
    end # describe

    describe 'with an integer' do
      it { expect(described_class.array? 42).to be false }
    end # describe

    describe 'with an empty array' do
      it { expect(described_class.array? []).to be true }
    end # describe

    describe 'with a non-empty array' do
      it { expect(described_class.array? %w(ichi ni san)).to be true }
    end # describe

    describe 'with an empty hash' do
      it { expect(described_class.array?({})).to be false }
    end # describe

    describe 'with a non-empty hash' do
      it { expect(described_class.array?({ :greetings => 'programs' })).to be false }
    end # describe
  end # describe

  describe '#bisect' do
    it { expect(instance).to respond_to(:bisect).with(1).arguments.and_a_block }

    it { expect(described_class).to respond_to(:bisect).with(1).argument.and_a_block }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.bisect nil }.to raise_error ArgumentError, /argument must be an array/
      end # it
    end # describe

    describe 'with an empty array' do
      it 'should raise an error' do
        expect { described_class.bisect [] }.to raise_error ArgumentError, /no block given/
      end # it

      describe 'with a block' do
        it 'should return two empty arrays' do
          expect(described_class.bisect([]) { |item| item }).to be == [[], []]
        end # it
      end # describe
    end # describe

    describe 'with an array with many items' do
      let(:ary) { [*0...10] }

      it 'should raise an error' do
        expect { described_class.bisect ary }.to raise_error ArgumentError, /no block given/
      end # it

      describe 'with a block matching no array items' do
        it 'should return an empty array and a copy of the original array' do
          selected, rejected = described_class.bisect(ary) { |item| item < 0 }

          expect(selected).to be == []
          expect(rejected).to be == ary

          expect { rejected << 10 }.not_to change { ary }
        end # it
      end # describe

      describe 'with a block matching some array items' do
        it 'should return an array containing the matching items and an array containing the non-matching items' do
          selected, rejected = described_class.bisect(ary) { |item| item.even? }

          expect(selected).to be == ary.select { |item| item.even? }
          expect(rejected).to be == ary.reject { |item| item.even? }
        end # it
      end # described_class

      describe 'with a block matching all array items' do
        it 'should return a copy of the original array and an empty array' do
          selected, rejected = described_class.bisect(ary) { |item| item >= 0 }

          expect(selected).to be == ary
          expect(rejected).to be == []

          expect { selected << 10 }.not_to change { ary }
        end # it
      end # describe
    end # describe
  end # describe

  describe '#count_values' do
    it { expect(instance).to respond_to(:count_values).with(1).argument }

    it { expect(described_class).to respond_to(:count_values).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.count_values nil }.to raise_error ArgumentError, /argument must be an array/
      end # it
    end # describe

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

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.deep_dup nil }.to raise_error ArgumentError, /argument must be an array/
      end # it
    end # describe

    include_examples 'should create a deep copy of an array'
  end # describe

  describe '#humanize_list' do
    it { expect(instance).to respond_to(:humanize_list).with(1).argument }

    it { expect(described_class).to respond_to(:humanize_list).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.humanize_list nil }.to raise_error ArgumentError, /argument must be an array/
      end # it
    end # describe

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

  describe '#splice' do
    shared_examples 'should splice the array' do
      let(:normalized) { start < 0 ? start + values.count : start }
      let!(:deleted)   { values[normalized...normalized+delete_count] }
      let!(:remaining) { values.dup.tap { |ary| ary[normalized...normalized+delete_count] = insert } }

      describe 'with no deleted or inserted items' do
        it 'should return an empty array' do
          expect(perform_action).to be == []
        end # it

        it 'should not change the array' do
          expect { perform_action }.not_to change { values }
        end # it
      end # describe

      describe 'with deleted items' do
        let(:delete_count) { 2 }

        it 'should return the deleted items' do
          expect(perform_action).to be == deleted
        end # it

        it 'should delete the items from the array' do
          perform_action

          expect(values).to be == remaining
        end # it
      end # describe

      describe 'with inserted items' do
        let(:insert) { %w(zweihänder) }

        it 'should return the deleted items' do
          expect(perform_action).to be == deleted
        end # it

        it 'should insert the items into the array' do
          perform_action

          expect(values).to be == remaining
        end # it
      end # describe

      describe 'with inserted and deleted items' do
        let(:delete_count) { 2 }
        let(:insert)       { %w(zweihänder) }

        it 'should return the deleted items' do
          expect(perform_action).to be == deleted
        end # it

        it 'should delete the items from and insert the items into the array' do
          perform_action

          expect(values).to be == remaining
        end # it
      end # describe

      describe 'with more deleted items than items in the array' do
        let(:delete_count) { 1 + values.count }

        it 'should return the deleted items' do
          expect(perform_action).to be == deleted
        end # it

        it 'should delete the items from the array' do
          perform_action

          expect(values).to be == remaining
        end # it
      end # describe
    end # shared_examples

    def perform_action
      described_class.splice values, start, delete_count, *insert
    end # method perform_action

    it { expect(instance).to respond_to(:splice).with(3).arguments.and_unlimited_arguments }

    it { expect(described_class).to respond_to(:splice).with(3).arguments.and_unlimited_arguments }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.splice nil, 0, 0 }.to raise_error ArgumentError, /argument must be an array/
      end # it
    end # describe

    describe 'with an array with many items' do
      let(:values)       { %w(katana wakizashi tachi daito shoto) }
      let(:delete_count) { 0 }
      let(:insert)       { [] }

      describe 'with a start value of 0' do
        let(:start) { 0 }

        include_examples 'should splice the array'
      end # describe

      describe 'with a start value of -1' do
        let(:start) { -1 }

        include_examples 'should splice the array'
      end # describe

      describe 'with a positive start value' do
        let(:start) { 2 }

        include_examples 'should splice the array'
      end # describe

      describe 'with a negative start value' do
        let(:start) { -3 }

        include_examples 'should splice the array'
      end # describe

      describe 'with a start value at the end of the array' do
        let(:start) { values.count }

        include_examples 'should splice the array'
      end # describe
    end # describe
  end # describe
end # describe
