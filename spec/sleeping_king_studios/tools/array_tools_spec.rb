# frozen_string_literal: true

require 'spec_helper'

require 'sleeping_king_studios/tools/array_tools'

RSpec.describe SleepingKingStudios::Tools::ArrayTools do
  extend RSpec::SleepingKingStudios::Concerns::WrapExamples

  include Spec::Examples::ArrayExamples

  let(:instance) { described_class.instance }

  describe '#array?' do
    it { expect(instance).to respond_to(:array?).with(1).argument }

    it { expect(described_class).to respond_to(:array?).with(1).argument }

    describe 'with nil' do
      it { expect(described_class.array? nil).to be false }
    end

    describe 'with an object' do
      it { expect(described_class.array? Object.new).to be false }
    end

    describe 'with a struct' do
      let(:struct_class) { Struct.new(:title) }
      let(:struct)       { struct_class.new 'The Art of War' }

      it { expect(described_class.array? struct).to be false }
    end

    describe 'with a string' do
      it { expect(described_class.array? 'greetings,programs').to be false }
    end

    describe 'with an integer' do
      it { expect(described_class.array? 42).to be false }
    end

    describe 'with an empty array' do
      it { expect(described_class.array? []).to be true }
    end

    describe 'with a non-empty array' do
      it { expect(described_class.array? %w[ichi ni san]).to be true }
    end

    describe 'with an empty hash' do
      it { expect(described_class.array?({})).to be false }
    end

    describe 'with a non-empty hash' do
      it 'should return false' do
        expect(described_class.array?({ greetings: 'programs' })).to be false
      end
    end
  end

  describe '#bisect' do
    it { expect(instance).to respond_to(:bisect).with(1).arguments }

    it { expect(described_class).to respond_to(:bisect).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.bisect nil }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    describe 'with an empty array' do
      it 'should raise an error' do
        expect { described_class.bisect [] }
          .to raise_error ArgumentError, /no block given/
      end

      describe 'with a block' do
        it 'should return two empty arrays' do
          expect(described_class.bisect([]) { |item| item }).to be == [[], []]
        end
      end
    end

    describe 'with an array with many items' do
      let(:ary) { [*0...10] }

      it 'should raise an error' do
        expect { described_class.bisect ary }
          .to raise_error ArgumentError, /no block given/
      end

      describe 'with a block matching no array items' do
        it 'should filter the matching items' do
          selected, = described_class.bisect(ary) { |item| item < 0 }

          expect(selected).to be == []
        end

        it 'should filter the non-matching items' do
          _, rejected = described_class.bisect(ary) { |item| item < 0 }

          expect(rejected).to be == ary
        end

        it 'should return a copy of the original array' do
          _, rejected = described_class.bisect(ary) { |item| item < 0 }

          expect { rejected << 10 }.not_to(change { ary })
        end
      end

      describe 'with a block matching some array items' do
        it 'should filter the matching items' do
          selected, = described_class.bisect(ary, &:even?)

          expect(selected).to be == ary.select(&:even?)
        end

        it 'should filter the non-matching items' do
          _, rejected = described_class.bisect(ary, &:even?)

          expect(rejected).to be == ary.reject(&:even?)
        end
      end

      describe 'with a block matching all array items' do
        it 'should filter the matching items' do
          selected, = described_class.bisect(ary) { |item| item >= 0 }

          expect(selected).to be == ary
        end

        it 'should filter the non-matching items' do
          _, rejected = described_class.bisect(ary) { |item| item >= 0 }

          expect(rejected).to be == []
        end

        it 'should return a copy of the original array' do
          selected, = described_class.bisect(ary) { |item| item >= 0 }

          expect { selected << 10 }.not_to(change { ary })
        end
      end
    end
  end

  describe '#count_values' do
    it { expect(instance).to respond_to(:count_values).with(1).argument }

    it { expect(described_class).to respond_to(:count_values).with(1).argument }

    it { expect(instance).to have_aliased_method(:count_values).as(:tally) }

    it { expect(described_class).to respond_to(:tally).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.count_values nil }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    describe 'with an empty array' do
      it 'returns an empty hash' do
        expect(described_class.count_values []).to be == {}
      end
    end

    describe 'with an array with one value' do
      let(:values) { %w[spam] }

      it 'returns the count of each value' do
        expect(described_class.count_values values).to be == { 'spam' => 1 }
      end

      describe 'with a block' do
        let(:values) do
          struct = Struct.new(:value)
          super().map { |value| struct.new(value) }
        end

        it 'returns the count of each value' do
          expect(described_class.count_values values, &:value)
            .to be == { 'spam' => 1 }
        end
      end
    end

    describe 'with an array with many values' do
      let(:values) { %w[spam bacon eggs spam] }

      it 'returns the count of each value' do
        expect(described_class.count_values values)
          .to be == { 'spam' => 2, 'bacon' => 1, 'eggs' => 1 }
      end

      describe 'with a block' do
        let(:values) do
          struct = Struct.new(:value)
          super().map { |value| struct.new(value) }
        end

        it 'returns the count of each value' do
          expect(described_class.count_values values, &:value)
            .to be == { 'spam' => 2, 'bacon' => 1, 'eggs' => 1 }
        end
      end
    end
  end

  describe '#deep_dup' do
    it { expect(instance).to respond_to(:deep_dup).with(1).argument }

    it { expect(described_class).to respond_to(:deep_dup).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.deep_dup nil }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    include_examples 'should create a deep copy of an array'
  end

  describe '#deep_freeze' do
    it { expect(instance).to respond_to(:deep_freeze).with(1).argument }

    it { expect(described_class).to respond_to(:deep_freeze).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.deep_freeze nil }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    include_examples 'should perform a deep freeze of the array'
  end

  describe '#humanize_list' do
    it 'should define the method' do
      expect(instance)
        .to respond_to(:humanize_list)
        .with(1)
        .argument.and_a_block
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:humanize_list)
        .with(1).argument
        .and_a_block
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.humanize_list nil }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    describe 'with an array with zero items' do
      let(:values) { [] }

      it 'returns an empty string' do
        expect(described_class.humanize_list values).to be == ''
      end

      describe 'with a block' do
        it 'returns an empty string' do
          expect(described_class.humanize_list values, &:upcase).to be == ''
        end
      end
    end

    describe 'with an array with one item' do
      let(:values)   { %i[foo] }
      let(:mapped)   { values }
      let(:expected) { mapped.first.to_s }

      it 'returns the item converted to a string' do
        expect(described_class.humanize_list values).to be == expected
      end

      describe 'with a block' do
        let(:mapped) { values.map(&:upcase) }

        it 'passes the item to the block' do
          expect(described_class.humanize_list values, &:upcase)
            .to be == expected
        end
      end
    end

    describe 'with an array with two items' do
      let(:values)   { %i[foo bar] }
      let(:mapped)   { values }
      let(:expected) { mapped.join(' and ') }

      it 'returns the items joined by "and"' do
        expect(described_class.humanize_list values).to be == expected
      end

      describe 'with :last_separator => " or "' do
        let(:expected) { mapped.join(' or ') }

        it 'returns the items joined by "or"' do
          expect(described_class.humanize_list values, last_separator: ' or ')
            .to be == expected
        end
      end

      describe 'with a block' do
        let(:mapped) { values.map(&:upcase) }

        it 'passes the items to the block' do
          expect(described_class.humanize_list values, &:upcase)
            .to be == expected
        end
      end
    end

    describe 'with an array with three items' do
      let(:values)   { %i[foo bar baz] }
      let(:mapped)   { values }
      let(:expected) { "#{mapped[0...-1].join(', ')}, and #{mapped.last}" }

      it 'returns the items joined by commas and the last value preceded by' \
         ' "and"' \
      do
        expect(described_class.humanize_list values).to be == expected
      end

      describe 'with :separator => ";"' do
        let(:expected) { "#{mapped[0...-1].join('; ')}; and #{mapped.last}" }

        it 'returns the items joined by semicolons and the last value' \
           ' preceded by "and"' \
        do
          expect(described_class.humanize_list values, separator: '; ')
            .to be == expected
        end
      end

      describe 'with :last_separator => " or "' do
        let(:expected) { "#{mapped[0...-1].join(', ')}, or #{mapped.last}" }

        it 'returns the items joined by commas and the last value preceded' \
           ' by "or"' \
        do
          expect(described_class.humanize_list values, last_separator: ', or ')
            .to be == expected
        end
      end

      describe 'with a block' do
        let(:mapped) { values.map(&:upcase) }

        it 'passes the items to the block' do
          expect(described_class.humanize_list values, &:upcase)
            .to be == expected
        end
      end
    end
  end

  describe '#immutable?' do
    it { expect(instance).to respond_to(:immutable?).with(1).argument }

    it { expect(described_class).to respond_to(:immutable?).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.immutable? nil }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    include_examples 'should test if the array is immutable'
  end

  describe '#mutable?' do
    let(:ary) { [] }

    before(:example) do
      allow(instance).to receive(:immutable?).with(ary).and_return(false)
    end

    it { expect(instance).to respond_to(:mutable?).with(1).argument }

    it { expect(described_class).to respond_to(:mutable?).with(1).argument }

    it { expect(instance.mutable? ary).to be true }

    it 'should delegate to #immutable?' do
      instance.mutable?(ary)

      expect(instance).to have_received(:immutable?).with(ary)
    end
  end

  describe '#splice' do
    shared_examples 'should splice the array' do
      let(:normalized) { start < 0 ? start + values.count : start }
      let!(:deleted)   { values[normalized...(normalized + delete_count)] }
      let!(:remaining) do
        values.dup.tap do |ary|
          ary[normalized...(normalized + delete_count)] = insert
        end
      end

      describe 'with no deleted or inserted items' do
        it 'should return an empty array' do
          expect(perform_action).to be == []
        end

        it 'should not change the array' do
          expect { perform_action }.not_to(change { values })
        end
      end

      describe 'with deleted items' do
        let(:delete_count) { 2 }

        it 'should return the deleted items' do
          expect(perform_action).to be == deleted
        end

        it 'should delete the items from the array' do
          perform_action

          expect(values).to be == remaining
        end
      end

      describe 'with inserted items' do
        let(:insert) { %w[zweihänder] }

        it 'should return the deleted items' do
          expect(perform_action).to be == deleted
        end

        it 'should insert the items into the array' do
          perform_action

          expect(values).to be == remaining
        end
      end

      describe 'with inserted and deleted items' do
        let(:delete_count) { 2 }
        let(:insert)       { %w[zweihänder] }

        it 'should return the deleted items' do
          expect(perform_action).to be == deleted
        end

        it 'should delete the items from and insert the items into the array' do
          perform_action

          expect(values).to be == remaining
        end
      end

      describe 'with more deleted items than items in the array' do
        let(:delete_count) { 1 + values.count }

        it 'should return the deleted items' do
          expect(perform_action).to be == deleted
        end

        it 'should delete the items from the array' do
          perform_action

          expect(values).to be == remaining
        end
      end
    end

    def perform_action
      described_class.splice values, start, delete_count, *insert
    end

    it 'should define the method' do
      expect(instance)
        .to respond_to(:splice)
        .with(3).arguments
        .and_unlimited_arguments
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:splice)
        .with(3).arguments
        .and_unlimited_arguments
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.splice nil, 0, 0 }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    describe 'with an array with many items' do
      let(:values)       { %w[katana wakizashi tachi daito shoto] }
      let(:delete_count) { 0 }
      let(:insert)       { [] }

      describe 'with a start value of 0' do
        let(:start) { 0 }

        include_examples 'should splice the array'
      end

      describe 'with a start value of -1' do
        let(:start) { -1 }

        include_examples 'should splice the array'
      end

      describe 'with a positive start value' do
        let(:start) { 2 }

        include_examples 'should splice the array'
      end

      describe 'with a negative start value' do
        let(:start) { -3 }

        include_examples 'should splice the array'
      end

      describe 'with a start value at the end of the array' do
        let(:start) { values.count }

        include_examples 'should splice the array'
      end
    end
  end
end
