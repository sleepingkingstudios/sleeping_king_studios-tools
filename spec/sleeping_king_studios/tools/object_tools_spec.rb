# frozen_string_literaL: true

require 'spec_helper'

require 'sleeping_king_studios/tools/object_tools'

RSpec.describe SleepingKingStudios::Tools::ObjectTools do
  extend RSpec::SleepingKingStudios::Concerns::WrapExamples

  include Spec::Examples::ArrayExamples
  include Spec::Examples::HashExamples

  let(:instance) { described_class.instance }

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
      double('base object', instance_method: nil)
      # rubocop:enable RSpec/VerifiedDoubles
    end

    before(:example) do
      allow(receiver).to receive(:instance_method).and_return(:return_value)
    end

    it { expect(instance).to respond_to(:apply).with(2).arguments }

    it { expect(described_class).to respond_to(:apply).with(2).arguments }

    describe 'with a proc with no parameters' do
      let(:proc) { ->(*args) { instance_method(*args) } }

      def apply_proc
        described_class.apply receiver, proc
      end

      it { expect(apply_proc).to be == :return_value }

      it 'should call the instance method' do
        apply_proc

        expect(receiver).to have_received(:instance_method).with(no_args)
      end

      include_examples 'should not change the objects on the method'
    end

    describe 'with a proc with required parameters' do
      let(:proc) { ->(foo, bar, baz) { instance_method(foo, bar, baz) } }

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

        it 'should call the instance method with the arguments' do
          apply_proc

          expect(receiver).to have_received(:instance_method).with(*args)
        end

        include_examples 'should not change the objects on the method'
      end
    end

    describe 'with a proc with required and optional parameters' do
      let(:proc) do
        lambda do |foo, bar, baz, wibble = nil, wobble = nil|
          instance_method(foo, bar, baz, wibble, wobble)
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

        it 'should call the instance method with the arguments' do
          apply_proc

          expect(receiver).to have_received(:instance_method).with(*expected)
        end

        include_examples 'should not change the objects on the method'
      end

      describe 'with the required and optional arguments' do
        let(:args) { %w[ichi ni san yon go] }

        def apply_proc
          described_class.apply receiver, proc, *args
        end

        it 'should call the instance method with the arguments' do
          apply_proc

          expect(receiver).to have_received(:instance_method).with(*args)
        end

        include_examples 'should not change the objects on the method'
      end
    end

    describe 'with a proc with a splat parameter' do
      let(:args) { %w[ichi ni san] }
      let(:proc) { ->(*args) { instance_method(*args) } }

      def apply_proc
        described_class.apply receiver, proc, *args
      end

      it 'should call the instance method with the arguments' do
        apply_proc

        expect(receiver).to have_received(:instance_method).with(*args)
      end

      include_examples 'should not change the objects on the method'
    end

    describe 'with a proc with optional keyword parameters' do
      let(:kwargs) { { first: 'Who', second: 'What', third: "I Don't Know" } }
      let(:proc) do
        lambda do |first: nil, second: nil, third: nil|
          instance_method(first: first, second: second, third: third)
        end
      end

      describe 'with no arguments' do
        let(:expected) { { first: nil, second: nil, third: nil } }

        def apply_proc
          described_class.apply receiver, proc
        end

        it 'should call the instance method with the default arguments' do
          apply_proc

          expect(receiver).to have_received(:instance_method).with(**expected)
        end

        include_examples 'should not change the objects on the method'
      end

      describe 'with the optional keywords' do
        def apply_proc
          described_class.apply receiver, proc, **kwargs
        end

        it 'should call the instance method with the arguments' do
          apply_proc

          expect(receiver).to have_received(:instance_method).with(**kwargs)
        end

        include_examples 'should not change the objects on the method'
      end
    end

    describe 'with a proc with a keyword splat parameter' do
      let(:kwargs) { { first: 'Who', second: 'What', third: "I Don't Know" } }
      let(:proc)   { ->(**kwargs) { instance_method(**kwargs) } }

      def apply_proc
        described_class.apply receiver, proc, **kwargs
      end

      it 'should call the instance method with the arguments' do
        apply_proc

        expect(receiver).to have_received(:instance_method).with(**kwargs)
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
          instance_method(
            foo,
            bar,
            baz,
            wibble,
            wobble,
            first:  first,
            second: second,
            third:  third
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

        it 'should call the instance method with the arguments and defaults' do
          apply_proc

          expect(receiver)
            .to have_received(:instance_method)
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

        it 'should call the instance method with the arguments and defaults' do
          apply_proc

          expect(receiver)
            .to have_received(:instance_method)
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

        it 'should call the instance method with the arguments and defaults' do
          apply_proc

          expect(receiver)
            .to have_received(:instance_method)
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

        it 'should call the instance method with the arguments' do
          apply_proc

          expect(receiver)
            .to have_received(:instance_method)
            .with(*args, **kwargs)
        end

        include_examples 'should not change the objects on the method'
      end
    end

    describe 'with a proc with a block parameter' do
      let(:args) { %w[ichi ni san] }
      let(:proc) { ->(*args, &block) { instance_method(*args, &block) } }

      def apply_proc(&block)
        described_class.apply receiver, proc, *args, &block
      end

      it 'should call the instance method with the arguments' do
        apply_proc

        expect(receiver).to have_received(:instance_method).with(*args)
      end

      it 'should pass the block to the instance method' do
        allow(receiver).to receive(:instance_method) do |*_args, &block|
          block.call('in_instance_method')
        end

        expect { |block| apply_proc(&block) }
          .to yield_with_args('in_instance_method')
      end

      include_examples 'should not change the objects on the method'
    end
  end

  describe '#deep_dup' do
    it { expect(instance).to respond_to(:deep_dup).with(1).argument }

    it { expect(described_class).to respond_to(:deep_dup).with(1).argument }

    include_examples 'should create a deep copy of an array'

    include_examples 'should create a deep copy of a hash'

    describe 'with false' do
      it { expect(instance.deep_dup false).to be false }
    end

    describe 'with a float' do
      it { expect(instance.deep_dup 1.0).to be == 1.0 }
    end

    describe 'with an integer' do
      it { expect(instance.deep_dup 42).to be == 42 }
    end

    describe 'with nil' do
      it { expect(instance.deep_dup nil).to be nil }
    end

    describe 'with an object' do
      let(:object) { Object.new }
      let(:copy)   { Object.new }

      before(:example) do
        allow(object).to receive(:dup).and_return(copy)
      end

      it { expect(instance.deep_dup object).to be copy }
    end

    describe 'with an object that responds to #deep_dup' do
      let(:object) { Object.new }
      let(:copy)   { Object.new }

      before(:example) do
        copied_object = copy

        object.define_singleton_method(:deep_dup) { copied_object }
      end

      it { expect(instance.deep_dup object).to be copy }
    end

    describe 'with a string' do
      it { expect(instance.deep_dup 'foo').to be == 'foo' }

      it 'should return a copy' do
        orig = 'foo'
        copy = instance.deep_dup orig

        expect { copy << 'bar' }.not_to(change { orig })
      end
    end

    describe 'with a struct' do
      let(:struct_class) { Struct.new(:prop) }
      let(:struct)       { struct_class.new('foo') }

      it { expect(instance.deep_dup struct).to be_a struct_class }

      it { expect(instance.deep_dup(struct).prop).to be == struct.prop }
    end

    describe 'with a symbol' do
      it { expect(instance.deep_dup :foo).to be :foo }
    end

    describe 'with true' do
      it { expect(instance.deep_dup true).to be true }
    end

    describe 'with a complex data structure' do
      let(:hsh) do
        {
          posts: [
            {
              riddle: 'What lies beyond the furthest reaches of the sky?',
              answer: 'That which will lead the lost child back to her' \
                      ' mother\'s arms. Exile.',
              tags:   ['House Eraclea', 'Exile', 'the Guild']
            },
            {
              riddle: 'The waves that flow and dye the land gold.',
              answer: 'The blessed breath that nurtures life. A land of' \
                      ' wheat.',
              tags:   ['House Dagobert', 'Anatoray', 'Disith']
            },
            {
              riddle: 'The path the angels descend upon.',
              answer: 'The path of great winds. The Grand Stream.',
              tags:   ['House Bassianus', 'the Grand Stream']
            },
            {
              riddle: 'What lies within the furthest depths of one\'s' \
                      ' memory?',
              answer: 'The place where all are born and where all will' \
                      ' return. A blue star.',
              tags:   ['House Hamilton', 'Earth']
            }
          ]
        }
      end
      let(:cpy) { instance.deep_dup hsh }

      it { expect(cpy).to be == hsh }

      it { expect { cpy[:author] = {} }.not_to(change { hsh }) }

      it { expect { cpy[:posts] = [] }.not_to(change { hsh }) }

      it { expect { cpy[:posts] << {} }.not_to(change { hsh }) }

      it { expect { cpy[:posts].first[:episode] = 3 }.not_to(change { hsh }) }

      it 'should return a copy of the posts array items' do
        riddle =
          'Why do hot dogs come in packages of ten, and hot dog buns come in' \
          ' packages of eight?'

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
    it { expect(instance).to respond_to(:deep_freeze).with(1).argument }

    it { expect(described_class).to respond_to(:deep_freeze).with(1).argument }

    include_examples 'should perform a deep freeze of the array'

    include_examples 'should perform a deep freeze of the hash'

    describe 'with an immutable object' do
      let(:objects) { [nil, false, true, 1.0, 42, :symbol] }

      it 'should not raise an error' do
        objects.each do |object|
          expect { instance.deep_freeze object }.not_to raise_error
        end
      end
    end

    describe 'with an object' do
      let(:object) { Object.new }

      it 'should freeze the object' do
        expect { instance.deep_freeze object }
          .to change(object, :frozen?)
          .to be true
      end
    end

    describe 'with an object that responds to #deep_freeze' do
      let(:object) { Object.new }

      before(:example) do
        object.define_singleton_method(:deep_freeze) {}

        allow(object).to receive(:deep_freeze)
      end

      it 'should delegate to #deep_freeze' do
        instance.deep_freeze object

        expect(object).to have_received(:deep_freeze)
      end
    end
  end

  describe '#dig' do
    it 'should define the method' do
      expect(instance)
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
  end

  describe '#eigenclass' do
    let(:object) { Object.new }

    it { expect(instance).to respond_to(:eigenclass).with(1).argument }

    it { expect(described_class).to respond_to(:eigenclass).with(1).argument }

    it { expect(instance).to alias_method(:eigenclass).as(:metaclass) }

    it { expect(described_class).to alias_method(:eigenclass).as(:metaclass) }

    it "returns the object's singleton class" do
      metaclass = class << object; self; end

      expect(described_class.eigenclass(object)).to be == metaclass
    end
  end

  describe '#immutable?' do
    it { expect(instance).to respond_to(:immutable?).with(1).argument }

    it { expect(described_class).to respond_to(:immutable?).with(1).argument }

    include_examples 'should test if the array is immutable'

    include_examples 'should test if the hash is immutable'

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
  end

  describe '#mutable?' do
    let(:object) { Object.new }

    before(:example) do
      allow(instance).to receive(:immutable?).and_return(false)
    end

    it { expect(instance).to respond_to(:mutable?).with(1).argument }

    it { expect(described_class).to respond_to(:mutable?).with(1).argument }

    it { expect(instance.mutable? object).to be true }

    it 'should delegate to #immutable?' do
      instance.mutable?(object)

      expect(instance).to have_received(:immutable?).with(object)
    end
  end

  describe '#object?' do
    it { expect(instance).to respond_to(:object?).with(1).argument }

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
      expect(instance)
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
end
