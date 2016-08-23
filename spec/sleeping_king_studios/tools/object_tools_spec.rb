# spec/sleeping_king_studios/tools/object_tools_spec.rb

require 'spec_helper'

require 'sleeping_king_studios/tools/object_tools'

RSpec.describe SleepingKingStudios::Tools::ObjectTools do
  extend RSpec::SleepingKingStudios::Concerns::WrapExamples

  include Spec::Examples::ArrayExamples
  include Spec::Examples::HashExamples

  let(:instance) { Object.new.extend described_class }

  describe '#apply' do
    shared_examples 'should not change the objects on the method' do
      it 'should not change the objects on the method' do
        expect {
          begin; perform_action; rescue ArgumentError; end
        }.not_to change(base, :methods)
      end # it
    end # shared_examples

    let(:base) { double('base object', :instance_method => nil) }

    it { expect(instance).to respond_to(:apply).with(2).arguments }

    it { expect(described_class).to respond_to(:apply).with(2).arguments }

    describe 'with a proc with no parameters' do
      let(:proc) { ->() { self.instance_method() } }

      def perform_action
        described_class.apply base, proc
      end # method perform_action

      it 'should set the base object as the receiver and call the proc with no arguments' do
        expect(base).to receive(:instance_method).with(no_args).and_return(:return_value)

        expect(perform_action).to be == :return_value
      end # it

      include_examples 'should not change the objects on the method'
    end # describe

    describe 'with a proc with required parameters' do
      let(:proc) { ->(foo, bar, baz) { self.instance_method(foo, bar, baz) } }

      describe 'with no arguments' do
        def perform_action
          described_class.apply base, proc
        end # method perform_action

        it 'should raise an error' do
          expect { perform_action }.to raise_error ArgumentError, /wrong number of arguments/
        end # it

        include_examples 'should not change the objects on the method'
      end # describe

      describe 'with the required arguments' do
        let(:args) { %w(ichi ni san) }

        def perform_action
          described_class.apply base, proc, *args
        end # method perform_action

        it 'should set the base object as the receiver and call the proc with the provided arguments' do
          expect(base).to receive(:instance_method).with(*args).and_return(:return_value)

          expect(perform_action).to be == :return_value
        end # it

        include_examples 'should not change the objects on the method'
      end # describe
    end # it

    describe 'with a proc with required and optional parameters' do
      let(:proc) { ->(foo, bar, baz, wibble = nil, wobble = nil) { self.instance_method(foo, bar, baz, wibble, wobble) } }

      describe 'with no arguments' do
        def perform_action
          described_class.apply base, proc
        end # method perform_action

        it 'should raise an error' do
          expect { perform_action }.to raise_error ArgumentError, /wrong number of arguments/
        end # it

        include_examples 'should not change the objects on the method'
      end # describe

      describe 'with the required arguments' do
        let(:args) { %w(ichi ni san) }

        def perform_action
          described_class.apply base, proc, *args
        end # method perform_action

        it 'should set the base object as the receiver and call the proc with the provided arguments' do
          expect(base).to receive(:instance_method).with(*args, nil, nil).and_return(:return_value)

          expect(perform_action).to be == :return_value
        end # it

        include_examples 'should not change the objects on the method'
      end # describe

      describe 'with the required and optional arguments' do
        let(:args) { %w(ichi ni san yon go) }

        def perform_action
          described_class.apply base, proc, *args
        end # method perform_action

        it 'should set the base object as the receiver and call the proc with the provided arguments' do
          expect(base).to receive(:instance_method).with(*args).and_return(:return_value)

          expect(perform_action).to be == :return_value
        end # it

        include_examples 'should not change the objects on the method'
      end # describe
    end # it

    describe 'with a proc with a splat parameter' do
      let(:args) { %w(ichi ni san) }
      let(:proc) { ->(*args) { self.instance_method(*args) } }

      def perform_action
        described_class.apply base, proc, *args
      end # method perform_action

      it 'should set the base object as the receiver and call the proc with the provided arguments' do
        expect(base).to receive(:instance_method).with(*args).and_return(:return_value)

        expect(perform_action).to be == :return_value
      end # it

      include_examples 'should not change the objects on the method'
    end # describe

    describe 'with a proc with optional keyword parameters' do
      let(:kwargs) { { :first => 'Who', :second => 'What', :third => "I Don't Know" } }
      let(:proc)   { ->(first: nil, second: nil, third: nil) { self.instance_method(:first => first, :second => second, :third => third) } }

      describe 'with no arguments' do
        def perform_action
          described_class.apply base, proc
        end # method perform_action

        it 'should set the base object as the receiver and call the proc with no arguments' do
          expect(base).to receive(:instance_method).with(:first => nil, :second => nil, :third => nil).and_return(:return_value)

          expect(perform_action).to be == :return_value
        end # it

        include_examples 'should not change the objects on the method'
      end # describe

      describe 'with the optional keywords' do
        def perform_action
          described_class.apply base, proc, **kwargs
        end # method perform_action

        it 'should set the base object as the receiver and call the proc with no arguments' do
          expect(base).to receive(:instance_method).with(**kwargs).and_return(:return_value)

          expect(perform_action).to be == :return_value
        end # it

        include_examples 'should not change the objects on the method'
      end # describe
    end # describe

    describe 'with a proc with a keyword splat parameter' do
      let(:kwargs) { { :first => 'Who', :second => 'What', :third => "I Don't Know" } }
      let(:proc)   { ->(**kwargs) { self.instance_method(**kwargs) } }

      def perform_action
        described_class.apply base, proc, **kwargs
      end # method perform_action

      it 'should set the base object as the receiver and call the proc with no arguments' do
        expect(base).to receive(:instance_method).with(**kwargs).and_return(:return_value)

        expect(perform_action).to be == :return_value
      end # it

      include_examples 'should not change the objects on the method'
    end # describe

    describe 'with a proc with required, optional, and keyword parameters' do
      let(:proc) do
        ->(foo, bar, baz, wibble = nil, wobble = nil, first: nil, second: nil, third: nil) {
          self.instance_method(foo, bar, baz, wibble, wobble, :first => first, :second => second, :third => third)
        } # end lambda
      end # let

      describe 'with no arguments' do
        def perform_action
          described_class.apply base, proc
        end # method perform_action

        it 'should raise an error' do
          expect { perform_action }.to raise_error ArgumentError, /wrong number of arguments/
        end # it

        include_examples 'should not change the objects on the method'
      end # describe

      describe 'with the required arguments' do
        let(:args) { %w(ichi ni san) }

        def perform_action
          described_class.apply base, proc, *args
        end # method perform_action

        it 'should set the base object as the receiver and call the proc with the provided arguments' do
          expect(base).to receive(:instance_method).with(*args, nil, nil, :first => nil, :second => nil, :third => nil).and_return(:return_value)

          expect(perform_action).to be == :return_value
        end # it

        include_examples 'should not change the objects on the method'
      end # describe

      describe 'with the required arguments and keywords' do
        let(:args)   { %w(ichi ni san) }
        let(:kwargs) { { :first => 'Who', :second => 'What', :third => "I Don't Know" } }

        def perform_action
          described_class.apply base, proc, *args, **kwargs
        end # method perform_action

        it 'should set the base object as the receiver and call the proc with the provided arguments' do
          expect(base).to receive(:instance_method).with(*args, nil, nil, **kwargs).and_return(:return_value)

          expect(perform_action).to be == :return_value
        end # it

        include_examples 'should not change the objects on the method'
      end # describe

      describe 'with the required and optional arguments' do
        let(:args) { %w(ichi ni san yon go) }

        def perform_action
          described_class.apply base, proc, *args
        end # method perform_action

        it 'should set the base object as the receiver and call the proc with the provided arguments' do
          expect(base).to receive(:instance_method).with(*args, :first => nil, :second => nil, :third => nil).and_return(:return_value)

          expect(perform_action).to be == :return_value
        end # it

        include_examples 'should not change the objects on the method'
      end # describe

      describe 'with the required and optional arguments and keywords' do
        let(:args)   { %w(ichi ni san yon go) }
        let(:kwargs) { { :first => 'Who', :second => 'What', :third => "I Don't Know" } }

        def perform_action
          described_class.apply base, proc, *args, **kwargs
        end # method perform_action

        it 'should set the base object as the receiver and call the proc with the provided arguments' do
          expect(base).to receive(:instance_method).with(*args, **kwargs).and_return(:return_value)

          expect(perform_action).to be == :return_value
        end # it

        include_examples 'should not change the objects on the method'
      end # describe
    end # describe

    describe 'with a proc with a block parameter' do
      let(:args) { %w(ichi ni san) }
      let(:proc) { ->(*args, &block) { self.instance_method *args, &block } }

      def perform_action(&block)
        described_class.apply base, proc, *args, &block
      end # method perform_action

      it 'sets the base object as the receiver and calls the proc with the block' do
        expect(base).to receive(:instance_method) do |*args, &block|
          args.each { |arg| block.call(arg) }

          :return_value
        end # receive

        yielded = []

        expect(described_class.apply(base, proc, *args) { |arg| yielded << arg }).to be == :return_value

        expect(yielded).to be == args
      end # it

      include_examples 'should not change the objects on the method'
    end # describe
  end # describe

  describe '#deep_dup' do
    it { expect(instance).to respond_to(:deep_dup).with(1).argument }

    it { expect(described_class).to respond_to(:deep_dup).with(1).argument }

    include_examples 'should create a deep copy of an array'

    include_examples 'should create a deep copy of a hash'

    describe 'with false' do
      it { expect(instance.deep_dup false).to be false }
    end # describe

    describe 'with a float' do
      it { expect(instance.deep_dup 1.0).to be == 1.0 }
    end # describe

    describe 'with an integer' do
      it { expect(instance.deep_dup 42).to be == 42 }
    end # describe

    describe 'with nil' do
      it { expect(instance.deep_dup nil).to be nil }
    end # describe

    describe 'with an object' do
      let(:object) { Object.new }

      it 'should delegate to Object#dup' do
        expected = double 'copy'

        expect(object).to receive(:dup).and_return(expected)

        expect(instance.deep_dup object).to be == expected
      end # it

      context 'with a defined #deep_dup method' do
        before(:example) do
          instance.eigenclass(object).send :define_method, :deep_dup do; end
        end # before example

        it 'should delegate to Object#deep_dup' do
          expected = double 'copy'

          expect(object).not_to receive(:dup)
          expect(object).to receive(:deep_dup).and_return(expected)

          expect(instance.deep_dup object).to be == expected
        end # it
      end # context
    end # describe

    describe 'with a string' do
      it { expect(instance.deep_dup 'foo').to be == 'foo' }

      it 'should return a copy' do
        orig = 'foo'
        copy = instance.deep_dup orig

        expect { copy << 'bar' }.not_to change { orig }
      end # it
    end # describe

    describe 'with a struct' do
      let(:struct_class) { Struct.new(:prop) }
      let(:struct)       { struct_class.new('foo') }

      it { expect(instance.deep_dup struct).to be_a struct_class }

      it { expect(instance.deep_dup(struct).prop).to be == struct.prop }
    end # describe

    describe 'with a symbol' do
      it { expect(instance.deep_dup :foo).to be :foo }
    end # describe

    describe 'with true' do
      it { expect(instance.deep_dup true).to be true }
    end # describe

    describe 'with a complex data structure' do
      let(:hsh) do
        { :posts => [
            { :riddle => 'What lies beyond the furthest reaches of the sky?',
              :answer => 'That which will lead the lost child back to her mother\'s arms. Exile.',
              :tags   => ['House Eraclea', 'Exile', 'the Guild']
            }, # end hash
            { :riddle => 'The waves that flow and dye the land gold.',
              :answer => 'The blessed breath that nurtures life. A land of wheat.',
              :tags   => ['House Dagobert', 'Anatoray', 'Disith']
            }, # end hash
            { :riddle => 'The path the angels descend upon.',
              :answer => 'The path of great winds. The Grand Stream.',
              :tags   => ['House Bassianus', 'the Grand Stream']
            }, # end hash
            { :riddle => 'What lies within the furthest depths of one\'s memory?',
              :answer => 'The place where all are born and where all will return. A blue star.',
              :tags   => ['House Hamilton', 'Earth']
            }  # end hash
          ] # end array
        } # end hash
      end # let
      let(:cpy) { instance.deep_dup hsh }

      it { expect(cpy).to be == hsh }

      it 'should return a copy of the data structure' do
        expect { cpy[:author] = {} }.not_to change { hsh }

        expect { cpy[:posts]  = [] }.not_to change { hsh }
      end # it

      it 'should return a copy of the posts array' do
        posts = cpy[:posts]

        expect { posts << {} }.not_to change { hsh }
      end # it

      it 'should return a copy of the posts array items' do
        posts = cpy[:posts]
        post  = cpy[:posts].first

        expect { post[:episode] = 3 }.not_to change { hsh }

        riddle = 'Why do hot dogs come in packages of ten, and hot dog buns come in packages of eight?'
        expect { post[:riddle ] = riddle }.not_to change { hsh }
      end # it

      it 'should return a copy of the post tags array' do
        posts = cpy[:posts]
        post  = cpy[:posts].first
        tags  = post[:tags]

        expect { tags << 'Lavie Head' }.not_to change { hsh }
      end # it

      it 'should return a copy of the post tags array items' do
        posts = cpy[:posts]
        post  = cpy[:posts].first
        tags  = post[:tags]

        expect { tags.last << ' Wars' }.not_to change { hsh }
      end # it
    end # describe
  end # describe

  describe '#eigenclass' do
    let(:object) { Object.new }

    it { expect(instance).to respond_to(:eigenclass).with(1).argument }

    it { expect(described_class).to respond_to(:eigenclass).with(1).argument }

    it "returns the object's metaclass" do
      metaclass = class << object; self; end

      expect(described_class.eigenclass(object)).to be == metaclass
    end # it
  end # describe

  describe '#immutable?' do
    it { expect(instance).to respond_to(:immutable?).with(1).argument }

    it { expect(described_class).to respond_to(:immutable?).with(1).argument }

    include_examples 'should test if the array is immutable'

    include_examples 'should test if the hash is immutable'

    describe 'with nil' do
      it { expect(described_class.immutable? nil).to be true }
    end # describe

    describe 'with false' do
      it { expect(described_class.immutable? false).to be true }
    end # describe

    describe 'with true' do
      it { expect(described_class.immutable? true).to be true }
    end # describe

    describe 'with an Integer' do
      it { expect(described_class.immutable? 0).to be true }
    end # describe

    describe 'with a Float' do
      it { expect(described_class.immutable? 0.0).to be true }
    end # describe

    describe 'with a Symbol' do
      it { expect(described_class.immutable? :symbol).to be true }
    end # describe

    describe 'with an Object' do
      it { expect(described_class.immutable? Object.new).to be false }
    end # describe

    describe 'with a frozen Object' do
      it { expect(described_class.immutable? Object.new.freeze).to be true }
    end # describe
  end # describe

  describe '#metaclass' do
    let(:object) { Object.new }

    it { expect(instance).to respond_to(:metaclass).with(1).argument }

    it { expect(described_class).to respond_to(:metaclass).with(1).argument }

    it "returns the object's metaclass" do
      metaclass = class << object; self; end

      expect(described_class.metaclass(object)).to be == metaclass
    end # it
  end # describe

  describe '#object?' do
    it { expect(instance).to respond_to(:object?).with(1).argument }

    it { expect(described_class).to respond_to(:object?).with(1).argument }

    describe 'with nil' do
      it { expect(described_class.object? nil).to be true }
    end # describe

    describe 'with a basic object' do
      it { expect(described_class.object? BasicObject.new).to be false }
    end # describe

    describe 'with an object' do
      it { expect(described_class.object? Object.new).to be true }
    end # describe

    describe 'with a string' do
      it { expect(described_class.object? 'greetings,programs').to be true }
    end # describe

    describe 'with an integer' do
      it { expect(described_class.object? 42).to be true }
    end # describe

    describe 'with an empty array' do
      it { expect(described_class.object? []).to be true }
    end # describe

    describe 'with a non-empty array' do
      it { expect(described_class.object? %w(ichi ni san)).to be true }
    end # describe

    describe 'with an empty hash' do
      it { expect(described_class.object?({})).to be true }
    end # describe

    describe 'with a non-empty hash' do
      it { expect(described_class.object?({ :greetings => 'programs' })).to be true }
    end # describe
  end # describe

  describe '#try' do
    let(:object) { Object.new }

    it { expect(instance).to respond_to(:try).with(2).arguments.and_unlimited_arguments }

    it { expect(described_class).to respond_to(:try).with(2).arguments.and_unlimited_arguments }

    describe 'with nil' do
      let(:object) { nil }

      describe 'with a method name that the object responds to' do
        it { expect(described_class.try object, :nil?).to be true }
      end # describe

      describe 'with a method name that the object does not respond to' do
        it { expect(described_class.try object, :foo).to be nil }
      end # describe
    end # describe

    describe 'with an object that responds to :try' do
      let(:object) { double('object', :nil? => false, :try => nil) }

      describe 'with a method name that the object responds to' do
        it 'should delegate to object#try' do
          expect(object).to receive(:try) do |method_name, *args|
            "tried :#{method_name} with #{args.count} arguments"
          end # expect

          expected = 'tried :nil? with 3 arguments'
          received = described_class.try object, :nil?, 'ichi', 'ni', 'san'

          expect(received).to be == expected
        end # it
      end # describe

      describe 'with a method name that the object does not respond to' do
        it 'should delegate to object#try' do
          expect(object).to receive(:try) do |method_name, *args|
            "tried :#{method_name} with #{args.count} arguments"
          end # expect

          expected = 'tried :foo with 3 arguments'
          received = described_class.try object, :foo, 'ichi', 'ni', 'san'

          expect(received).to be == expected
        end # it
      end # describe
    end # describe

    describe 'with an object that does not respond to :try' do
      let(:object) do
        Class.new do
          def foo *args; end
        end.new # class
      end # let

      describe 'with a method name that the object responds to' do
        it 'should call the method' do
          expect(object).to receive(:foo) do |*args|
            "called :foo with #{args.count} arguments"
          end # expect

          expected = 'called :foo with 3 arguments'
          received = described_class.try object, :foo, 'ichi', 'ni', 'san'

          expect(received).to be == expected
        end # it
      end # describe

      describe 'with a method name that the object does not respond to' do
        it { expect(described_class.try object, :bar).to be nil }
      end # describe
    end # describe
  end # describe
end # describe
