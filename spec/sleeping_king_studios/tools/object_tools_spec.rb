# spec/sleeping_king_studios/tools/object_tools_spec.rb

require 'sleeping_king_studios/tools/object_tools'

RSpec.describe SleepingKingStudios::Tools::ObjectTools do
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

  describe '#eigenclass' do
    let(:object) { Object.new }

    it { expect(instance).to respond_to(:eigenclass).with(1).argument }

    it { expect(described_class).to respond_to(:eigenclass).with(1).argument }

    it "returns the object's metaclass" do
      metaclass = class << object; self; end

      expect(described_class.eigenclass(object)).to be == metaclass
    end # it
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
end # describe
