# frozen_string_literal: true

require 'sleeping_king_studios/tools/object_tools'

RSpec.describe SleepingKingStudios::Tools::ObjectTools do
  subject(:object_tools) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:toolbelt)
    end
  end

  describe '#apply' do
    shared_examples 'should not change the objects on the method' do
      it 'should not change the objects on the method' do
        expect do
          apply_proc
        rescue ArgumentError # rubocop:disable Lint/SuppressedException
        end.not_to change(receiver, :methods)
      end
    end

    let(:receiver) do
      # rubocop:disable RSpec/VerifiedDoubles
      double('base object', object_tools_method: nil)
      # rubocop:enable RSpec/VerifiedDoubles
    end

    before(:example) do
      allow(receiver).to receive(:object_tools_method).and_return(:return_value)
    end

    it { expect(object_tools).to respond_to(:apply).with(2).arguments }

    it { expect(described_class).to respond_to(:apply).with(2).arguments }

    describe 'with a proc with no parameters' do
      let(:proc) { ->(*args) { object_tools_method(*args) } }

      def apply_proc
        described_class.apply receiver, proc
      end

      it { expect(apply_proc).to be == :return_value }

      it 'should call the object_tools method' do
        apply_proc

        expect(receiver).to have_received(:object_tools_method).with(no_args)
      end

      include_examples 'should not change the objects on the method'
    end

    describe 'with a proc with required parameters' do
      let(:proc) { ->(foo, bar, baz) { object_tools_method(foo, bar, baz) } }

      describe 'with no arguments' do
        def apply_proc
          described_class.apply receiver, proc
        end

        it 'should raise an error' do
          expect { apply_proc }
            .to raise_error ArgumentError, /wrong number of arguments/
        end

        include_examples 'should not change the objects on the method'
      end

      describe 'with the required arguments' do
        let(:args) { %w[ichi ni san] }

        def apply_proc
          described_class.apply receiver, proc, *args
        end

        it 'should call the object_tools method with the arguments' do
          apply_proc

          expect(receiver).to have_received(:object_tools_method).with(*args)
        end

        include_examples 'should not change the objects on the method'
      end
    end

    describe 'with a proc with required and optional parameters' do
      let(:proc) do
        lambda do |foo, bar, baz, wibble = nil, wobble = nil|
          object_tools_method(foo, bar, baz, wibble, wobble)
        end
      end

      describe 'with no arguments' do
        def apply_proc
          described_class.apply receiver, proc
        end

        it 'should raise an error' do
          expect { apply_proc }
            .to raise_error ArgumentError, /wrong number of arguments/
        end

        include_examples 'should not change the objects on the method'
      end

      describe 'with the required arguments' do
        let(:args)     { %w[ichi ni san] }
        let(:expected) { [*args, nil, nil] }

        def apply_proc
          described_class.apply receiver, proc, *args
        end

        it 'should call the object_tools method with the arguments' do
          apply_proc

          expect(receiver)
            .to have_received(:object_tools_method)
            .with(*expected)
        end

        include_examples 'should not change the objects on the method'
      end

      describe 'with the required and optional arguments' do
        let(:args) { %w[ichi ni san yon go] }

        def apply_proc
          described_class.apply receiver, proc, *args
        end

        it 'should call the object_tools method with the arguments' do
          apply_proc

          expect(receiver).to have_received(:object_tools_method).with(*args)
        end

        include_examples 'should not change the objects on the method'
      end
    end

    describe 'with a proc with a splat parameter' do
      let(:args) { %w[ichi ni san] }
      let(:proc) { ->(*args) { object_tools_method(*args) } }

      def apply_proc
        described_class.apply receiver, proc, *args
      end

      it 'should call the object_tools method with the arguments' do
        apply_proc

        expect(receiver).to have_received(:object_tools_method).with(*args)
      end

      include_examples 'should not change the objects on the method'
    end

    describe 'with a proc with optional keyword parameters' do
      let(:kwargs) { { first: 'Who', second: 'What', third: "I Don't Know" } }
      let(:proc) do
        lambda do |first: nil, second: nil, third: nil|
          object_tools_method(first:, second:, third:)
        end
      end

      describe 'with no arguments' do
        let(:expected) { { first: nil, second: nil, third: nil } }

        def apply_proc
          described_class.apply receiver, proc
        end

        it 'should call the object_tools method with the default arguments' do
          apply_proc

          expect(receiver)
            .to have_received(:object_tools_method)
            .with(**expected)
        end

        include_examples 'should not change the objects on the method'
      end

      describe 'with the optional keywords' do
        def apply_proc
          described_class.apply receiver, proc, **kwargs
        end

        it 'should call the object_tools method with the arguments' do
          apply_proc

          expect(receiver).to have_received(:object_tools_method).with(**kwargs)
        end

        include_examples 'should not change the objects on the method'
      end
    end

    describe 'with a proc with a keyword splat parameter' do
      let(:kwargs) { { first: 'Who', second: 'What', third: "I Don't Know" } }
      let(:proc)   { ->(**kwargs) { object_tools_method(**kwargs) } }

      def apply_proc
        described_class.apply receiver, proc, **kwargs
      end

      it 'should call the object_tools method with the arguments' do
        apply_proc

        expect(receiver).to have_received(:object_tools_method).with(**kwargs)
      end

      include_examples 'should not change the objects on the method'
    end

    describe 'with a proc with required, optional, and keyword parameters' do
      let(:proc) do
        lambda do |
          foo,
          bar,
          baz,
          wibble = nil,
          wobble = nil,
          first: nil,
          second: nil,
          third: nil
        |
          object_tools_method(
            foo,
            bar,
            baz,
            wibble,
            wobble,
            first:,
            second:,
            third:
          )
        end
      end

      describe 'with no arguments' do
        def apply_proc
          described_class.apply receiver, proc
        end

        it 'should raise an error' do
          expect { apply_proc }
            .to raise_error ArgumentError, /wrong number of arguments/
        end

        include_examples 'should not change the objects on the method'
      end

      describe 'with the required arguments' do
        let(:args)          { %w[ichi ni san] }
        let(:expected_args) { [*args, nil, nil] }
        let(:expected_kwargs) do
          { first: nil, second: nil, third: nil }
        end

        def apply_proc
          described_class.apply receiver, proc, *args
        end

        it 'should call the method with the arguments and defaults' do
          apply_proc

          expect(receiver)
            .to have_received(:object_tools_method)
            .with(*expected_args, **expected_kwargs)
        end

        include_examples 'should not change the objects on the method'
      end

      describe 'with the required arguments and keywords' do
        let(:args)          { %w[ichi ni san] }
        let(:expected_args) { [*args, nil, nil] }
        let(:kwargs) do
          { first: 'Who', second: 'What', third: "I Don't Know" }
        end

        def apply_proc
          described_class.apply receiver, proc, *args, **kwargs
        end

        it 'should call the method with the arguments and defaults' do
          apply_proc

          expect(receiver)
            .to have_received(:object_tools_method)
            .with(*expected_args, **kwargs)
        end

        include_examples 'should not change the objects on the method'
      end

      describe 'with the required and optional arguments' do
        let(:args) { %w[ichi ni san yon go] }
        let(:expected_kwargs) do
          { first: nil, second: nil, third: nil }
        end

        def apply_proc
          described_class.apply receiver, proc, *args
        end

        it 'should call the method with the arguments and defaults' do
          apply_proc

          expect(receiver)
            .to have_received(:object_tools_method)
            .with(*args, **expected_kwargs)
        end

        include_examples 'should not change the objects on the method'
      end

      describe 'with the required and optional arguments and keywords' do
        let(:args)   { %w[ichi ni san yon go] }
        let(:kwargs) { { first: 'Who', second: 'What', third: "I Don't Know" } }

        def apply_proc
          described_class.apply receiver, proc, *args, **kwargs
        end

        it 'should call the object_tools method with the arguments' do
          apply_proc

          expect(receiver)
            .to have_received(:object_tools_method)
            .with(*args, **kwargs)
        end

        include_examples 'should not change the objects on the method'
      end
    end

    describe 'with a proc with a block parameter' do
      let(:args) { %w[ichi ni san] }
      let(:proc) { ->(*args, &block) { object_tools_method(*args, &block) } }

      def apply_proc(&block)
        described_class.apply receiver, proc, *args, &block
      end

      it 'should call the object_tools method with the arguments' do
        apply_proc

        expect(receiver).to have_received(:object_tools_method).with(*args)
      end

      it 'should pass the block to the object_tools method' do
        allow(receiver).to receive(:object_tools_method) do |*_args, &block|
          block.call('in_object_tools_method')
        end

        expect { |block| apply_proc(&block) }
          .to yield_with_args('in_object_tools_method')
      end

      include_examples 'should not change the objects on the method'
    end
  end

  describe '#deep_dup' do
    it { expect(object_tools).to respond_to(:deep_dup).with(1).argument }

    it { expect(described_class).to respond_to(:deep_dup).with(1).argument }

    describe 'with an Array' do
      let(:ary)      { %w[ichi ni san] }
      let(:toolbelt) { object_tools.toolbelt }
      let(:expected) { toolbelt.array_tools.deep_dup(ary) }

      it { expect(object_tools.deep_dup ary).to eq(expected) }

      it 'should delegate to ArrayTools' do
        allow(toolbelt.array_tools).to receive(:deep_dup)

        object_tools.deep_dup(ary)

        expect(toolbelt.array_tools).to have_received(:deep_dup).with(ary)
      end
    end

    describe 'with false' do
      it { expect(object_tools.deep_dup false).to be false }
    end

    describe 'with a float' do
      it { expect(object_tools.deep_dup 1.0).to eq 1.0 }
    end

    describe 'with a Hash' do
      let(:hsh)      { { 'foo' => 'foo', 'bar' => 'bar', 'baz' => 'baz' } }
      let(:toolbelt) { object_tools.toolbelt }
      let(:expected) { toolbelt.hash_tools.deep_dup(hsh) }

      it { expect(object_tools.deep_dup hsh).to eq(expected) }

      it 'should delegate to HashTools' do
        allow(toolbelt.hash_tools).to receive(:deep_dup)

        object_tools.deep_dup(hsh)

        expect(toolbelt.hash_tools).to have_received(:deep_dup).with(hsh)
      end
    end

    describe 'with an integer' do
      it { expect(object_tools.deep_dup 42).to be == 42 }
    end

    describe 'with nil' do
      it { expect(object_tools.deep_dup nil).to be nil }
    end

    describe 'with an object' do
      let(:object) { Object.new }
      let(:copy)   { Object.new }

      before(:example) do
        allow(object).to receive(:dup).and_return(copy)
      end

      it { expect(object_tools.deep_dup object).to be copy }
    end

    describe 'with an object that responds to #deep_dup' do
      let(:object) { Object.new }
      let(:copy)   { Object.new }

      before(:example) do
        copied_object = copy

        object.define_singleton_method(:deep_dup) { copied_object }
      end

      it { expect(object_tools.deep_dup object).to be copy }
    end

    describe 'with a string' do
      it { expect(object_tools.deep_dup 'foo').to be == 'foo' }

      it 'should return a copy' do
        orig = 'foo'
        copy = object_tools.deep_dup orig

        expect { copy << 'bar' }.not_to(change { orig })
      end
    end

    describe 'with a struct' do
      let(:struct_class) { Struct.new(:prop) }
      let(:struct)       { struct_class.new('foo') }

      it { expect(object_tools.deep_dup struct).to be_a struct_class }

      it { expect(object_tools.deep_dup(struct).prop).to be == struct.prop }
    end

    describe 'with a symbol' do
      it { expect(object_tools.deep_dup :foo).to be :foo }
    end

    describe 'with true' do
      it { expect(object_tools.deep_dup true).to be true }
    end

    describe 'with a complex data structure' do
      let(:hsh) do
        {
          posts: [
            {
              riddle: 'What lies beyond the furthest reaches of the sky?',
              answer: 'That which will lead the lost child back to her ' \
                      'mother\'s arms. Exile.',
              tags:   ['House Eraclea', 'Exile', 'the Guild']
            },
            {
              riddle: 'The waves that flow and dye the land gold.',
              answer: 'The blessed breath that nurtures life. A land of ' \
                      'wheat.',
              tags:   ['House Dagobert', 'Anatoray', 'Disith']
            },
            {
              riddle: 'The path the angels descend upon.',
              answer: 'The path of great winds. The Grand Stream.',
              tags:   ['House Bassianus', 'the Grand Stream']
            },
            {
              riddle: 'What lies within the furthest depths of one\'s ' \
                      'memory?',
              answer: 'The place where all are born and where all will ' \
                      'return. A blue star.',
              tags:   ['House Hamilton', 'Earth']
            }
          ]
        }
      end
      let(:cpy) { object_tools.deep_dup hsh }

      it { expect(cpy).to be == hsh }

      it { expect { cpy[:author] = {} }.not_to(change { hsh }) }

      it { expect { cpy[:posts] = [] }.not_to(change { hsh }) }

      it { expect { cpy[:posts] << {} }.not_to(change { hsh }) }

      it { expect { cpy[:posts].first[:episode] = 3 }.not_to(change { hsh }) }

      it 'should return a copy of the posts array items' do
        riddle =
          'Why do hot dogs come in packages of ten, and hot dog buns come in ' \
          'packages of eight?'

        expect { cpy[:posts].first[:riddle] = riddle }.not_to(change { hsh })
      end

      it 'should return a copy of the post tags array' do
        expect { cpy[:posts].first[:tags] << 'Claus Valca' }
          .not_to(change { hsh })
      end

      it 'should return a copy of the post tags array items' do
        expect { cpy[:posts].first[:tags].last << ' Wars' }
          .not_to(change { hsh })
      end
    end
  end

  describe '#deep_freeze' do
    it { expect(object_tools).to respond_to(:deep_freeze).with(1).argument }

    it { expect(described_class).to respond_to(:deep_freeze).with(1).argument }

    describe 'with an immutable object' do
      let(:objects) { [nil, false, true, 1.0, 42, :symbol] }

      it 'should not raise an error' do
        objects.each do |object|
          expect { object_tools.deep_freeze object }.not_to raise_error
        end
      end
    end

    describe 'with an object' do
      let(:object) { Object.new }

      it 'should freeze the object' do
        expect { object_tools.deep_freeze object }
          .to change(object, :frozen?)
          .to be true
      end
    end

    describe 'with an Array' do
      let(:ary)      { %w[ichi ni san] }
      let(:toolbelt) { object_tools.toolbelt }

      it 'should freeze the array' do
        expect { object_tools.deep_freeze ary }
          .to change(ary, :frozen?)
          .to be true
      end

      it 'should delegate to ArrayTools' do
        allow(toolbelt.array_tools).to receive(:deep_freeze)

        object_tools.deep_freeze(ary)

        expect(toolbelt.array_tools).to have_received(:deep_freeze).with(ary)
      end
    end

    describe 'with a Hash' do
      let(:hsh) do
        {
          +'foo' => 'foo',
          +'bar' => 'bar',
          +'baz' => 'baz'
        }
      end
      let(:toolbelt) { object_tools.toolbelt }

      it 'should freeze the array' do
        expect { object_tools.deep_freeze hsh }
          .to change(hsh, :frozen?)
          .to be true
      end

      it 'should delegate to ArrayTools' do
        allow(toolbelt.hash_tools).to receive(:deep_freeze)

        object_tools.deep_freeze(hsh)

        expect(toolbelt.hash_tools).to have_received(:deep_freeze).with(hsh)
      end
    end

    describe 'with an object that responds to #deep_freeze' do
      let(:object) { Object.new }

      before(:example) do
        object.define_singleton_method(:deep_freeze) { nil }

        allow(object).to receive(:deep_freeze)
      end

      it 'should delegate to #deep_freeze' do
        object_tools.deep_freeze object

        expect(object).to have_received(:deep_freeze)
      end
    end
  end

  # rubocop:disable Style/SingleArgumentDig
  describe '#dig' do
    it 'should define the method' do
      expect(object_tools)
        .to respond_to(:dig)
        .with(1).argument
        .and_unlimited_arguments
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:dig)
        .with(1).argument
        .and_unlimited_arguments
    end

    describe 'with nil' do
      let(:object) { nil }

      it { expect(described_class.dig object).to be nil }

      describe 'with a method that the object responds to' do
        it { expect(described_class.dig object, :nil?).to be true }
      end

      describe 'with a method that the object does not respond to' do
        it { expect(described_class.dig object, :foo).to be nil }
      end

      describe 'with an invalid method chain' do
        it { expect(described_class.dig object, :foo, :bar, :baz).to be nil }
      end
    end

    describe 'with an object' do
      let(:baz)    { Object.new }
      let(:bar)    { Struct.new(:baz).new(baz) }
      let(:foo)    { Struct.new(:bar).new(bar) }
      let(:object) { Struct.new(:foo).new(foo) }

      it { expect(described_class.dig object).to be object }

      describe 'with a method that the object responds to' do
        it { expect(described_class.dig object, :foo).to be foo }
      end

      describe 'with a method that the object does not respond to' do
        it { expect(described_class.dig object, :wibble).to be nil }
      end

      describe 'with a valid method chain' do
        it { expect(described_class.dig object, :foo, :bar, :baz).to be baz }
      end

      describe 'with an invalid method chain' do
        it 'should return nil' do
          expect(described_class.dig object, :foo, :wibble, :wobble).to be nil
        end
      end
    end

    describe 'with a nested data structure' do
      let(:user)   { Struct.new(:name).new('Alan Bradley') }
      let(:users)  { [user] }
      let(:data)   { { 'users' => users } }
      let(:result) { Struct.new(:data).new(data) }

      describe 'with a valid method chain' do
        it 'should return the nested value' do
          expect(described_class.dig(result, :data, 'users', 0, :name))
            .to be == 'Alan Bradley'
        end
      end
    end
  end
  # rubocop:enable Style/SingleArgumentDig

  describe '#eigenclass' do
    let(:object) { Object.new }

    it { expect(object_tools).to respond_to(:eigenclass).with(1).argument }

    it { expect(described_class).to respond_to(:eigenclass).with(1).argument }

    it 'should define the aliased method' do
      expect(object_tools).to have_aliased_method(:eigenclass).as(:metaclass)
    end

    it { expect(described_class).to respond_to(:metaclass).with(1).argument }

    it "returns the object's singleton class" do
      metaclass = class << object; self; end

      expect(described_class.eigenclass(object)).to be == metaclass
    end
  end

  describe '#immutable?' do
    it { expect(object_tools).to respond_to(:immutable?).with(1).argument }

    it { expect(described_class).to respond_to(:immutable?).with(1).argument }

    describe 'with nil' do
      it { expect(described_class.immutable? nil).to be true }
    end

    describe 'with false' do
      it { expect(described_class.immutable? false).to be true }
    end

    describe 'with true' do
      it { expect(described_class.immutable? true).to be true }
    end

    describe 'with an Integer' do
      it { expect(described_class.immutable? 0).to be true }
    end

    describe 'with a Float' do
      it { expect(described_class.immutable? 0.0).to be true }
    end

    describe 'with a Symbol' do
      it { expect(described_class.immutable? :symbol).to be true }
    end

    describe 'with an Object' do
      it { expect(described_class.immutable? Object.new).to be false }
    end

    describe 'with a frozen Object' do
      it { expect(described_class.immutable? Object.new.freeze).to be true }
    end

    describe 'with an Array' do
      let(:ary)      { %w[ichi ni san] }
      let(:toolbelt) { object_tools.toolbelt }

      it { expect(described_class.immutable? ary).to be false }

      it 'should delegate to ArrayTools' do
        allow(toolbelt.array_tools).to receive(:deep_freeze)

        object_tools.deep_freeze(ary)

        expect(toolbelt.array_tools).to have_received(:deep_freeze).with(ary)
      end

      context 'when the Array is frozen' do
        let(:ary) { super().freeze }

        it { expect(described_class.immutable? ary).to be true }
      end
    end

    describe 'with a Hash' do
      let(:hsh) do
        {
          +'foo' => 'foo',
          +'bar' => 'bar',
          +'baz' => 'baz'
        }
      end
      let(:toolbelt) { object_tools.toolbelt }

      it { expect(described_class.immutable? hsh).to be false }

      it 'should delegate to HashTools' do
        allow(toolbelt.hash_tools).to receive(:deep_freeze)

        object_tools.deep_freeze(hsh)

        expect(toolbelt.hash_tools).to have_received(:deep_freeze).with(hsh)
      end

      context 'when the Array is frozen' do
        let(:hsh) { super().freeze }

        it { expect(described_class.immutable? hsh).to be true }
      end
    end
  end

  describe '#mutable?' do
    let(:object) { Object.new }

    it { expect(object_tools).to respond_to(:mutable?).with(1).argument }

    it { expect(described_class).to respond_to(:mutable?).with(1).argument }

    it 'should delegate to #immutable?' do
      allow(object_tools).to receive(:immutable?) # rubocop:disable RSpec/SubjectStub

      object_tools.mutable?(object)

      expect(object_tools).to have_received(:immutable?).with(object) # rubocop:disable RSpec/SubjectStub
    end

    describe 'with an immutable object' do
      let(:object) { super().freeze }

      it { expect(object_tools.mutable?(object)).to be false }
    end

    describe 'with a mutable object' do
      it { expect(object_tools.mutable?(object)).to be true }
    end
  end

  describe '#object?' do
    it { expect(object_tools).to respond_to(:object?).with(1).argument }

    it { expect(described_class).to respond_to(:object?).with(1).argument }

    describe 'with nil' do
      it { expect(described_class.object? nil).to be true }
    end

    describe 'with a basic object' do
      it { expect(described_class.object? BasicObject.new).to be false }
    end

    describe 'with an object' do
      it { expect(described_class.object? Object.new).to be true }
    end

    describe 'with a string' do
      it { expect(described_class.object? 'greetings,programs').to be true }
    end

    describe 'with an integer' do
      it { expect(described_class.object? 42).to be true }
    end

    describe 'with an empty array' do
      it { expect(described_class.object? []).to be true }
    end

    describe 'with a non-empty array' do
      it { expect(described_class.object? %w[ichi ni san]).to be true }
    end

    describe 'with an empty hash' do
      it { expect(described_class.object?({})).to be true }
    end

    describe 'with a non-empty hash' do
      let(:object) { { greetings: 'programs' } }

      it { expect(described_class.object?(object)).to be true }
    end
  end

  describe '#try' do
    let(:object) { Object.new }

    it 'should define the method' do
      expect(object_tools)
        .to respond_to(:try)
        .with(2).arguments
        .and_unlimited_arguments
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:try)
        .with(2).arguments
        .and_unlimited_arguments
    end

    describe 'with nil' do
      let(:object) { nil }

      describe 'with a method name that the object responds to' do
        it { expect(described_class.try object, :nil?).to be true }
      end

      describe 'with a method name that the object does not respond to' do
        it { expect(described_class.try object, :foo).to be nil }
      end
    end

    describe 'with an object that responds to #try' do
      let(:object_class) do
        Class.new do
          def try(method_name, *args)
            "tried :#{method_name} with #{args.count} arguments"
          end
        end
      end
      let(:object)   { object_class.new }
      let(:expected) { 'tried :nil? with 3 arguments' }

      it 'should delegate to object#try' do
        expect(described_class.try object, :nil?, 'ichi', 'ni', 'san')
          .to be == expected
      end
    end

    describe 'with an object that does not respond to :try' do
      let(:object) { Object.new }

      before(:example) do
        allow(object).to receive(:is_a?).and_return(false)
      end

      describe 'with a method name that the object responds to' do
        it { expect(described_class.try(object, :is_a?, Object)).to be false }

        it 'should call the method' do
          described_class.try(object, :is_a?, Object)

          expect(object).to have_received(:is_a?).with(Object)
        end
      end

      describe 'with a method name that the object does not respond to' do
        it { expect(described_class.try object, :bar).to be nil }
      end
    end
  end

  describe '#toolbelt' do
    let(:expected) { SleepingKingStudios::Tools::Toolbelt.global }

    it { expect(object_tools.toolbelt).to be expected }

    it { expect(object_tools).to have_aliased_method(:toolbelt).as(:tools) }

    context 'when initialized with toolbelt: value' do
      let(:toolbelt) { SleepingKingStudios::Tools::Toolbelt.new }
      let(:constructor_options) do
        super().merge(toolbelt:)
      end

      it { expect(object_tools.toolbelt).to be toolbelt }
    end
  end
end
