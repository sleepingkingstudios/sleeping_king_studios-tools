# frozen_string_literal: true

require 'sleeping_king_studios/tools/array_tools'

RSpec.describe SleepingKingStudios::Tools::ArrayTools do
  subject(:array_tools) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  shared_context 'when the array is frozen' do
    let(:ary) { super().freeze }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:toolbelt)
    end
  end

  describe '#array?' do
    it { expect(array_tools).to respond_to(:array?).with(1).argument }

    it { expect(described_class).to respond_to(:array?).with(1).argument }

    describe 'with nil' do
      it { expect(array_tools.array? nil).to be false }
    end

    describe 'with an object' do
      it { expect(array_tools.array? Object.new).to be false }
    end

    describe 'with a struct' do
      let(:struct_class) { Struct.new(:title) }
      let(:struct)       { struct_class.new 'The Art of War' }

      it { expect(array_tools.array? struct).to be false }
    end

    describe 'with a string' do
      it { expect(array_tools.array? 'greetings,programs').to be false }
    end

    describe 'with an integer' do
      it { expect(array_tools.array? 42).to be false }
    end

    describe 'with an empty array' do
      it { expect(array_tools.array? []).to be true }
    end

    describe 'with a non-empty array' do
      it { expect(array_tools.array? %w[ichi ni san]).to be true }
    end

    describe 'with an empty hash' do
      it { expect(array_tools.array?({})).to be false }
    end

    describe 'with a non-empty hash' do
      it 'should return false' do
        expect(array_tools.array?({ greetings: 'programs' })).to be false
      end
    end
  end

  describe '#bisect' do
    let(:toolbelt) { SleepingKingStudios::Tools::Toolbelt.global }

    before(:example) { allow(toolbelt.core_tools).to receive(:deprecate) }

    it { expect(array_tools).to respond_to(:bisect).with(1).arguments }

    it { expect(described_class).to respond_to(:bisect).with(1).argument }

    it 'should print a deprecation warning' do # rubocop:disable RSpec/ExampleLength
      array_tools.bisect([]) { false }

      expect(toolbelt.core_tools)
        .to have_received(:deprecate)
        .with(
          "#{described_class.name}#bisect",
          message: 'Use Enumerable#partition instead.'
        )
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { array_tools.bisect nil }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    describe 'with an empty array' do
      it 'should raise an error' do
        expect { array_tools.bisect [] }
          .to raise_error ArgumentError, /no block given/
      end

      describe 'with a block' do
        it 'should return two empty arrays' do
          expect(array_tools.bisect([]) { |item| item }).to be == [[], []]
        end
      end
    end

    describe 'with an array with many items' do
      let(:ary) { [*0...10] }

      it 'should raise an error' do
        expect { array_tools.bisect ary }
          .to raise_error ArgumentError, /no block given/
      end

      describe 'with a block matching no array items' do
        it 'should filter the matching items' do
          selected, = array_tools.bisect(ary) { |item| item < 0 }

          expect(selected).to be == []
        end

        it 'should filter the non-matching items' do
          _, rejected = array_tools.bisect(ary) { |item| item < 0 }

          expect(rejected).to be == ary
        end

        it 'should return a copy of the original array' do
          _, rejected = array_tools.bisect(ary) { |item| item < 0 }

          expect { rejected << 10 }.not_to(change { ary })
        end
      end

      describe 'with a block matching some array items' do
        it 'should filter the matching items' do
          selected, = array_tools.bisect(ary, &:even?)

          expect(selected).to be == ary.select(&:even?)
        end

        it 'should filter the non-matching items' do
          _, rejected = array_tools.bisect(ary, &:even?)

          expect(rejected).to be == ary.reject(&:even?)
        end
      end

      describe 'with a block matching all array items' do
        it 'should filter the matching items' do
          selected, = array_tools.bisect(ary) { |item| item >= 0 }

          expect(selected).to be == ary
        end

        it 'should filter the non-matching items' do
          _, rejected = array_tools.bisect(ary) { |item| item >= 0 }

          expect(rejected).to be == []
        end

        it 'should return a copy of the original array' do
          selected, = array_tools.bisect(ary) { |item| item >= 0 }

          expect { selected << 10 }.not_to(change { ary })
        end
      end
    end
  end

  describe '#count_values' do
    let(:toolbelt) { SleepingKingStudios::Tools::Toolbelt.global }

    before(:example) { allow(toolbelt.core_tools).to receive(:deprecate) }

    it { expect(array_tools).to respond_to(:count_values).with(1).argument }

    it { expect(described_class).to respond_to(:count_values).with(1).argument }

    it { expect(array_tools).to have_aliased_method(:count_values).as(:tally) }

    it { expect(described_class).to respond_to(:tally).with(1).argument }

    it 'should print a deprecation warning' do # rubocop:disable RSpec/ExampleLength
      array_tools.count_values([])

      expect(toolbelt.core_tools)
        .to have_received(:deprecate)
        .with(
          "#{described_class.name}#count_values",
          message: 'Use Enumerable#tally instead.'
        )
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { array_tools.count_values nil }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    describe 'with an empty array' do
      it 'returns an empty hash' do
        expect(array_tools.count_values []).to be == {}
      end
    end

    describe 'with an array with one value' do
      let(:values) { %w[spam] }

      it 'returns the count of each value' do
        expect(array_tools.count_values values).to be == { 'spam' => 1 }
      end

      describe 'with a block' do
        let(:values) do
          struct = Struct.new(:value)
          super().map { |value| struct.new(value) }
        end

        it 'returns the count of each value' do
          expect(array_tools.count_values values, &:value)
            .to be == { 'spam' => 1 }
        end
      end
    end

    describe 'with an array with many values' do
      let(:values) { %w[spam bacon eggs spam] }

      it 'returns the count of each value' do
        expect(array_tools.count_values values)
          .to be == { 'spam' => 2, 'bacon' => 1, 'eggs' => 1 }
      end

      describe 'with a block' do
        let(:values) do
          struct = Struct.new(:value)
          super().map { |value| struct.new(value) }
        end

        it 'returns the count of each value' do
          expect(array_tools.count_values values, &:value)
            .to be == { 'spam' => 2, 'bacon' => 1, 'eggs' => 1 }
        end
      end
    end
  end

  describe '#deep_dup' do
    it { expect(array_tools).to respond_to(:deep_dup).with(1).argument }

    it { expect(described_class).to respond_to(:deep_dup).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { array_tools.deep_dup nil }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    describe 'with an array of arrays' do
      let(:ary) { [%w[ichi ni san], %w[yon go roku], %w[hachi nana kyuu]] }
      let(:cpy) { array_tools.deep_dup ary }

      it { expect(cpy).to be == ary }

      it 'should return a copy of the array' do
        expect { cpy << 'jyuu' }.not_to(change { ary })
      end

      it 'should return a copy of the child arrays' do
        expect { cpy.first << 'jyuu' }.not_to(change { ary })
      end

      it 'should return a copy of the child array items' do
        expect { cpy.first.first << 'jyuu' }.not_to(change { ary })
      end
    end

    describe 'with an array of integers' do
      let(:ary) { [1, 2, 3] }
      let(:cpy) { array_tools.deep_dup ary }

      it { expect(cpy).to be == ary }

      it 'should return a copy of the array' do
        expect { cpy << 4 }.not_to(change { ary })
      end
    end

    describe 'with an array of strings' do
      let(:ary) { %w[ichi ni san] }
      let(:cpy) { array_tools.deep_dup ary }

      it { expect(cpy).to be == ary }

      it 'should return a copy of the array' do
        expect { cpy << 'yon' }.not_to(change { ary })
      end

      it 'should return a copy of the array items' do
        expect { cpy.first << 'yon' }.not_to(change { ary })
      end
    end

    describe 'with a heterogenous array' do
      let(:ary) { ['0', 1.0, :'2', 3, 4..5] }
      let(:cpy) { array_tools.deep_dup ary }

      it { expect(cpy).to be == ary }

      it 'should return a copy of the array' do
        expect { cpy << 'yon' }.not_to(change { ary })
      end

      it 'should return a copy of the array items' do
        expect { cpy.first << 'yon' }.not_to(change { ary })
      end
    end
  end

  describe '#deep_freeze' do
    it { expect(array_tools).to respond_to(:deep_freeze).with(1).argument }

    it { expect(described_class).to respond_to(:deep_freeze).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { array_tools.deep_freeze nil }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    describe 'with an array of arrays' do
      let(:ary) { [%w[ichi ni san], %w[yon go roku], %w[hachi nana kyuu]] }

      it 'should freeze the array' do
        expect { array_tools.deep_freeze ary }
          .to change(ary, :frozen?)
          .to be true
      end

      it 'should freeze the array items' do
        array_tools.deep_freeze ary

        expect(ary.all?(&:frozen?)).to be true
      end

      it 'should freeze the nested array items' do
        array_tools.deep_freeze ary

        expect(ary.flatten.all?(&:frozen?)).to be true
      end
    end

    describe 'with an array of integers' do
      let(:ary) { [1, 2, 3] }

      it 'should freeze the array' do
        expect { array_tools.deep_freeze ary }
          .to change(ary, :frozen?)
          .to be true
      end
    end

    describe 'with an array of strings' do
      let(:ary) { %w[ichi ni san] }

      it 'should freeze the array' do
        expect { array_tools.deep_freeze ary }
          .to change(ary, :frozen?)
          .to be true
      end

      it 'should freeze the array items' do
        array_tools.deep_freeze ary

        expect(ary.all?(&:frozen?)).to be true
      end
    end

    describe 'with a heterogenous array' do
      let(:ary) { ['0', 1.0, :'2', 3, 4..5] }

      it 'should freeze the array' do
        expect { array_tools.deep_freeze ary }
          .to change(ary, :frozen?)
          .to be true
      end

      it 'should freeze the array items' do
        array_tools.deep_freeze ary

        expect(ary.all?(&:frozen?)).to be true
      end
    end
  end

  describe '#fetch' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:fetch)
        .with(2..3)
        .arguments
        .and_a_block
    end

    it 'should define the method' do
      expect(array_tools)
        .to respond_to(:fetch)
        .with(2..3)
        .arguments
        .and_a_block
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { array_tools.fetch(nil, 0) }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    describe 'with an Object' do
      it 'should raise an error' do
        expect { array_tools.fetch(Object.new.freeze, 0) }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    describe 'with an Array' do
      let(:ary) { %w[foo bar baz] }

      describe 'with an invalid negative index' do
        let(:error_message) do
          'index -4 outside of array bounds: -3...3'
        end

        it 'should raise an exception' do
          expect { array_tools.fetch(ary, -4) }
            .to raise_error IndexError, error_message
        end

        describe 'with default: block' do
          let(:default) { ->(index) { "missing index #{index}" } }

          it 'should generate the default value' do
            expect(array_tools.fetch(ary, -4, &default))
              .to be == 'missing index -4'
          end
        end

        describe 'with default: value' do
          it 'should return the default value' do
            expect(array_tools.fetch(ary, -4, 'qux')).to be == 'qux'
          end
        end
      end

      describe 'with an invalid positive index' do
        let(:error_message) do
          'index 3 outside of array bounds: -3...3'
        end

        it 'should raise an exception' do
          expect { array_tools.fetch(ary, 3) }
            .to raise_error IndexError, error_message
        end

        describe 'with default: block' do
          let(:default) { ->(index) { "missing index #{index}" } }

          it 'should generate the default value' do
            expect(array_tools.fetch(ary, 3, &default))
              .to be == 'missing index 3'
          end
        end

        describe 'with default: value' do
          it 'should return the default value' do
            expect(array_tools.fetch(ary, 3, 'qux')).to be == 'qux'
          end
        end
      end

      describe 'with a valid negative index' do
        it { expect(array_tools.fetch(ary, -3)).to be == 'foo' }
      end

      describe 'with a valid positive index' do
        it { expect(array_tools.fetch(ary, 2)).to be == 'baz' }
      end
    end

    describe 'with an Array-like object' do
      let(:ary) { Spec::ArrayLike.new(%w[foo bar baz]) }

      example_class 'Spec::ArrayLike' do |klass|
        klass.define_method :initialize do |data|
          @data = data
        end

        klass.attr_reader :data

        klass.define_method :[] do |index|
          data[index]
        end

        klass.define_method :count do
          data.count
        end

        klass.define_method :each do |&block|
          # :nocov:
          data.each(&block)
          # :nocov:
        end
      end

      describe 'with an invalid negative index' do
        let(:error_message) do
          'index -4 outside of array bounds: -3...3'
        end

        it 'should raise an exception' do
          expect { array_tools.fetch(ary, -4) }
            .to raise_error IndexError, error_message
        end

        describe 'with default: block' do
          let(:default) { ->(index) { "missing index #{index}" } }

          it 'should generate the default value' do
            expect(array_tools.fetch(ary, -4, &default))
              .to be == 'missing index -4'
          end
        end

        describe 'with default: value' do
          it 'should return the default value' do
            expect(array_tools.fetch(ary, -4, 'qux')).to be == 'qux'
          end
        end
      end

      describe 'with an invalid positive index' do
        let(:error_message) do
          'index 3 outside of array bounds: -3...3'
        end

        it 'should raise an exception' do
          expect { array_tools.fetch(ary, 3) }
            .to raise_error IndexError, error_message
        end

        describe 'with default: block' do
          let(:default) { ->(index) { "missing index #{index}" } }

          it 'should generate the default value' do
            expect(array_tools.fetch(ary, 3, &default))
              .to be == 'missing index 3'
          end
        end

        describe 'with default: value' do
          it 'should return the default value' do
            expect(array_tools.fetch(ary, 3, 'qux')).to be == 'qux'
          end
        end
      end

      describe 'with a valid negative index' do
        it { expect(array_tools.fetch(ary, -3)).to be == 'foo' }
      end

      describe 'with a valid positive index' do
        it { expect(array_tools.fetch(ary, 2)).to be == 'baz' }
      end
    end
  end

  describe '#humanize_list' do
    it 'should define the method' do
      expect(array_tools)
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
        expect { array_tools.humanize_list nil }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    describe 'with an array with zero items' do
      let(:values) { [] }

      it 'returns an empty string' do
        expect(array_tools.humanize_list values).to be == ''
      end

      describe 'with a block' do
        it 'returns an empty string' do
          expect(array_tools.humanize_list values, &:upcase).to be == ''
        end
      end
    end

    describe 'with an array with one item' do
      let(:values)   { %i[foo] }
      let(:mapped)   { values }
      let(:expected) { mapped.first.to_s }

      it 'returns the item converted to a string' do
        expect(array_tools.humanize_list values).to be == expected
      end

      describe 'with a block' do
        let(:mapped) { values.map(&:upcase) }

        it 'passes the item to the block' do
          expect(array_tools.humanize_list values, &:upcase)
            .to be == expected
        end
      end
    end

    describe 'with an array with two items' do
      let(:values)   { %i[foo bar] }
      let(:mapped)   { values }
      let(:expected) { mapped.join(' and ') }

      it 'returns the items joined by "and"' do
        expect(array_tools.humanize_list values).to be == expected
      end

      describe 'with :last_separator => " or "' do
        let(:expected) { mapped.join(' or ') }

        it 'returns the items joined by "or"' do
          expect(array_tools.humanize_list values, last_separator: ' or ')
            .to be == expected
        end
      end

      describe 'with a block' do
        let(:mapped) { values.map(&:upcase) }

        it 'passes the items to the block' do
          expect(array_tools.humanize_list values, &:upcase)
            .to be == expected
        end
      end
    end

    describe 'with an array with three items' do
      let(:values)   { %i[foo bar baz] }
      let(:mapped)   { values }
      let(:expected) { "#{mapped[0...-1].join(', ')}, and #{mapped.last}" }

      it 'returns the items joined by commas and the last value preceded by ' \
         '"and"' \
      do
        expect(array_tools.humanize_list values).to be == expected
      end

      describe 'with :separator => ";"' do
        let(:expected) { "#{mapped[0...-1].join('; ')}; and #{mapped.last}" }

        it 'returns the items joined by semicolons and the last value ' \
           'preceded by "and"' \
        do
          expect(array_tools.humanize_list values, separator: '; ')
            .to be == expected
        end
      end

      describe 'with :last_separator => " or "' do
        let(:expected) { "#{mapped[0...-1].join(', ')}, or #{mapped.last}" }

        it 'returns the items joined by commas and the last value preceded ' \
           'by "or"' \
        do
          expect(array_tools.humanize_list values, last_separator: ', or ')
            .to be == expected
        end
      end

      describe 'with a block' do
        let(:mapped) { values.map(&:upcase) }

        it 'passes the items to the block' do
          expect(array_tools.humanize_list values, &:upcase)
            .to be == expected
        end
      end
    end
  end

  describe '#immutable?' do
    it { expect(array_tools).to respond_to(:immutable?).with(1).argument }

    it { expect(described_class).to respond_to(:immutable?).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { array_tools.immutable? nil }
          .to raise_error ArgumentError, /argument must be an array/
      end
    end

    describe 'with an array of arrays' do
      let(:ary) do
        [
          [+'ichi', +'ni', +'san'],
          [+'yon', +'go', +'roku'],
          [+'hachi', +'nana', +'kyuu']
        ]
      end

      it { expect(array_tools.immutable? ary).to be false }

      context 'when the array is frozen' do
        include_context 'when the array is frozen'

        it { expect(array_tools.immutable? ary).to be false }

        context 'when the child arrays are frozen' do
          before(:example) { ary.each(&:freeze) }

          it { expect(array_tools.immutable? ary).to be false }

          context 'when the child array items are frozen' do # rubocop:disable RSpec/NestedGroups
            before(:example) { ary.flatten.each(&:freeze) }

            it { expect(array_tools.immutable? ary).to be true }
          end
        end
      end
    end

    describe 'with an array of integers' do
      let(:ary) { [1, 2, 3] }

      it { expect(array_tools.immutable? ary).to be false }

      wrap_context 'when the array is frozen' do
        it { expect(array_tools.immutable? ary).to be true }
      end
    end

    describe 'with an array of mutable strings' do
      let(:ary) { [+'ichi', +'ni', +'san'] }

      it { expect(array_tools.immutable? ary).to be false }

      context 'when the array is frozen' do
        include_context 'when the array is frozen'

        it { expect(array_tools.immutable? ary).to be false }

        context 'when some of the strings are frozen' do
          before(:example) do
            ary.each.with_index { |item, index| item.freeze if index.odd? }
          end

          it { expect(array_tools.immutable? ary).to be false }
        end

        context 'when all of the strings are frozen' do
          before(:example) { ary.each(&:freeze) }

          it { expect(array_tools.immutable? ary).to be true }
        end
      end
    end

    describe 'with a heterogenous array' do
      let(:ary) { [+'0', 1.0, :'2', 3, 4..5] }

      it { expect(array_tools.immutable? ary).to be false }

      context 'when the array is frozen' do
        include_context 'when the array is frozen'

        let(:toolbelt) { SleepingKingStudios::Tools::Toolbelt.instance }

        it { expect(array_tools.immutable? ary).to be false }

        context 'when the mutable items are frozen' do
          before(:example) do
            ary.each do |item|
              item.freeze unless toolbelt.object_tools.immutable?(item)
            end
          end

          it { expect(array_tools.immutable? ary).to be true }
        end
      end
    end
  end

  describe '#mutable?' do
    let(:ary) { [] }

    it { expect(array_tools).to respond_to(:mutable?).with(1).argument }

    it { expect(described_class).to respond_to(:mutable?).with(1).argument }

    it 'should delegate to #immutable?' do
      allow(array_tools).to receive(:immutable?) # rubocop:disable RSpec/SubjectStub

      array_tools.mutable?(ary)

      expect(array_tools).to have_received(:immutable?).with(ary) # rubocop:disable RSpec/SubjectStub
    end

    describe 'with an immutable Array' do
      let(:ary) { super().freeze }

      it { expect(array_tools.mutable?(ary)).to be false }
    end

    describe 'with a mutable Array' do
      it { expect(array_tools.mutable?(ary)).to be true }
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

    let(:toolbelt) { SleepingKingStudios::Tools::Toolbelt.global }

    before(:example) { allow(toolbelt.core_tools).to receive(:deprecate) }

    define_method :perform_action do
      array_tools.splice values, start, delete_count, *insert
    end

    it 'should define the method' do
      expect(array_tools)
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

    it 'should print a deprecation warning' do # rubocop:disable RSpec/ExampleLength
      array_tools.splice([], 0, 0)

      expect(toolbelt.core_tools)
        .to have_received(:deprecate)
        .with(
          "#{described_class.name}#splice",
          message: 'Use Array#[]= with a block instead.'
        )
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { array_tools.splice nil, 0, 0 }
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

  describe '#toolbelt' do
    let(:expected) { SleepingKingStudios::Tools::Toolbelt.global }

    it { expect(array_tools.toolbelt).to be expected }

    it { expect(array_tools).to have_aliased_method(:toolbelt).as(:tools) }

    context 'when initialized with toolbelt: value' do
      let(:toolbelt) { SleepingKingStudios::Tools::Toolbelt.new }
      let(:constructor_options) do
        super().merge(toolbelt:)
      end

      it { expect(array_tools.toolbelt).to be toolbelt }
    end
  end
end
