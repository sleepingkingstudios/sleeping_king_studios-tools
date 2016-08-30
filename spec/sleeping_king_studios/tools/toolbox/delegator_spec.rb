# spec/sleeping_king_studios/tools/toolbox/delegator_spec.rb

require 'spec_helper'

require 'sleeping_king_studios/tools/toolbox/delegator'

RSpec.describe SleepingKingStudios::Tools::Toolbox::Delegator do
  let(:concern)         { SleepingKingStudios::Tools::Toolbox::Delegator }
  let(:described_class) { Class.new.extend(concern) }
  let(:instance)        { described_class.new }

  describe '#delegate' do
    shared_examples 'should delegate method' do |method_name|
      let(:args)   { %w(foo bar baz) }
      let(:kwargs) { { :wibble => nil, :wobble => nil } }

      it { expect(instance).to respond_to(method_name) }

      describe 'with no arguments' do
        let(:result) { Object.new }

        it 'should delegate the method and return the result' do
          expect(delegate).
            to receive(method_name).
            with(no_args).
            exactly(3).times.
            and_return(result)

          3.times do
            expect(instance.send(method_name)).to be result
          end # times
        end # it
      end # describe

      describe 'with an empty hash argument' do
        let(:args) { [{}] }

        it 'should delegate the method' do
          expect(delegate).to receive(method_name).with(*args)

          instance.send(method_name, *args)
        end # it
      end # describe

      describe 'with a non-empty hash argument' do
        let(:args) { [{ :greetings => :programs }] }

        it 'should delegate the method' do
          expect(delegate).to receive(method_name).with(*args)

          instance.send(method_name, *args)
        end # it
      end # describe

      describe 'with many arguments' do
        it 'should delegate the method' do
          expect(delegate).to receive(method_name).with(*args)

          instance.send(method_name, *args)
        end # it
      end # describe

      describe 'with many arguments and a block' do
        it 'should delegate the method' do
          expect(delegate).to receive(method_name).with(*args) do |*, &block|
            block.call
          end # expect

          block_called = false

          instance.send(method_name, *args) { block_called = true }

          expect(block_called).to be true
        end # it
      end # describe

      describe 'with keyword arguments' do
        it 'should delegate the method' do
          expect(delegate).to receive(method_name).with(**kwargs)

          instance.send(method_name, **kwargs)
        end # it
      end # describe

      describe 'with many arguments and keyword arguments and a block' do
        it 'should delegate the method' do
          expect(delegate).to receive(method_name).with(*args, **kwargs) do |*, &block|
            block.call
          end # expect

          block_called = false

          instance.send(method_name, *args, **kwargs) { block_called = true }

          expect(block_called).to be true
        end # it
      end # describe
    end # shared_examples

    let(:delegate) { double('delegate', :first_method => nil, :second_method => nil, :third_method => nil) }
    let(:options)  { {} }

    it { expect(described_class).to respond_to(:delegate).with(1).arguments.and_unlimited_arguments.and_keywords(:allow_nil, :to) }

    describe 'with an undefined delegate' do
      it 'should raise an error' do
        expect { described_class.delegate }.to raise_error ArgumentError, 'must specify a delegate'
      end # it
    end # describe

    describe 'with a nil delegate' do
      describe 'with one method name' do
        let(:delegate) { nil }

        it 'should raise an error' do
          expect { described_class.delegate :first_method, :to => delegate }.to raise_error ArgumentError, 'must specify a delegate'
        end # it

        describe 'with :allow_nil => true' do
          let(:options) { super().merge :allow_nil => true }

          before(:each) { described_class.delegate :first_method, :to => delegate, **options }

          it 'should return nil' do
            expect(instance.first_method).to be nil
          end # it
        end # describe
      end # describe
    end # describe

    describe 'with an object delegate' do
      describe 'with one method name' do
        before(:each) { described_class.delegate :first_method, :to => delegate, **options }

        include_examples 'should delegate method', :first_method
      end # describe

      describe 'with many method names' do
        before(:each) { described_class.delegate :first_method, :second_method, :third_method, :to => delegate, **options }

        include_examples 'should delegate method', :first_method

        include_examples 'should delegate method', :second_method

        include_examples 'should delegate method', :third_method
      end # describe
    end # it

    describe 'with a method name delegate' do
      shared_context 'with a defined delegate method' do
        let(:described_class) do
          delegate_object = delegate

          super().tap do |klass|
            klass.send(:define_method, :delegate_method, ->() { delegate_object })
          end # tap
        end # let
      end # shared_context

      describe 'with one method name' do
        before(:each) { described_class.delegate :first_method, :to => :delegate_method, **options }

        it 'should raise an error' do
          expect {
            instance.first_method
          }.to raise_error NoMethodError, /undefined method `delegate_method'/
        end # it

        wrap_context 'with a defined delegate method' do
          include_examples 'should delegate method', :first_method

          context 'with a nil delegate' do
            let(:delegate) { nil }

            it 'should raise an error' do
              expect {
                instance.first_method
              }.to raise_error NoMethodError, /undefined method `first_method'/
            end # it

            describe 'with :allow_nil => true' do
              let(:options) { super().merge :allow_nil => true }

              it 'should return nil' do
                expect(instance.first_method).to be nil
              end # it
            end # describe
          end # context
        end # it
      end # describe

      describe 'with many method names' do
        before(:each) { described_class.delegate :first_method, :second_method, :third_method, :to => :delegate_method, **options }

        it 'should raise an error' do
          expect {
            instance.first_method
          }.to raise_error NoMethodError, /undefined method `delegate_method'/
        end # it

        wrap_context 'with a defined delegate method' do
          include_examples 'should delegate method', :first_method

          include_examples 'should delegate method', :second_method

          include_examples 'should delegate method', :third_method
        end # it
      end # describe
    end # describe

    describe 'with an instance variable delegate' do
      shared_context 'with a delegate at the instance variable' do
        before(:each) { instance.instance_variable_set(:@delegate_variable, delegate) }
      end # shared_context

      describe 'with one method name' do
        before(:each) { described_class.delegate :first_method, :to => :@delegate_variable, **options }

        it 'should raise an error' do
          expect {
            instance.first_method
          }.to raise_error NoMethodError, /undefined method `first_method'/
        end # it

        wrap_context 'with a delegate at the instance variable' do
          include_examples 'should delegate method', :first_method

          context 'with a nil delegate' do
            let(:delegate) { nil }

            it 'should raise an error' do
              expect {
                instance.first_method
              }.to raise_error NoMethodError, /undefined method `first_method'/
            end # it

            describe 'with :allow_nil => true' do
              let(:options) { super().merge :allow_nil => true }

              it 'should return nil' do
                expect(instance.first_method).to be nil
              end # it
            end # describe
          end # context
        end # it
      end # describe

      describe 'with many method names' do
        before(:each) { described_class.delegate :first_method, :second_method, :third_method, :to => :@delegate_variable, **options }

        wrap_context 'with a delegate at the instance variable' do
          include_examples 'should delegate method', :first_method

          include_examples 'should delegate method', :second_method

          include_examples 'should delegate method', :third_method
        end # it
      end # describe
    end # describe
  end # describe

  describe '#wrap_delegate' do
    shared_context 'with a delegate with a custom class' do
      let(:delegate_superclass) do
        Class.new do
          attr_reader :first_method, :second_method, :third_method
        end # class
      end # let
      let(:delegate_class) do
        Class.new(delegate_superclass) do
          attr_reader :fourth_method, :fifth_method, :sixth_method
        end # class
      end # let
      let(:method_names) { delegate_class.instance_methods - Object.instance_methods }
      let(:delegate)     { delegate_class.new }
    end # shared_context

    shared_examples 'should not delegate the skipped methods to the target' do
      it 'should not delegate the skipped methods to the target' do
        aggregate_failures 'should not define the delegated methods' do
          skipped_methods.each do |method_name|
            expect(instance).not_to respond_to(method_name)
          end # each
        end # aggregate_failures
      end # it
    end # shared_examples

    shared_examples 'should delegate the specified methods to the target' do
      it 'should delegate the specified methods to the target' do
        aggregate_failures 'should define the delegated methods' do
          delegated_methods.each do |method_name|
            expect(instance).to respond_to(method_name)

            expect(delegate).to receive(:send).with(method_name)

            instance.send(method_name)
          end # each
        end # aggregate_failures
      end # it
    end # shared_examples

    shared_examples 'should delegate to the target' do
      let(:skipped_methods) { defined?(super()) ? super() : [] }

      describe 'with no options' do
        let(:delegated_methods) { method_names }

        before(:example) { described_class.wrap_delegate target, **options }

        include_examples 'should not delegate the skipped methods to the target'

        include_examples 'should delegate the specified methods to the target'
      end # describe

      describe 'with :except => methods' do
        let(:skipped_methods)   { super() + method_names[0...method_names.count/2] }
        let(:delegated_methods) { method_names - skipped_methods }
        let(:options)           { super().merge :except => skipped_methods }

        before(:example) { described_class.wrap_delegate target, **options }

        include_examples 'should not delegate the skipped methods to the target'

        include_examples 'should delegate the specified methods to the target'
      end # describe

      describe 'with :only => methods' do
        let(:delegated_methods) { method_names[0...method_names.count/2] }
        let(:skipped_methods)   { super() + (method_names - delegated_methods) }
        let(:options)           { super().merge :only => delegated_methods }

        before(:example) { described_class.wrap_delegate target, **options }

        include_examples 'should not delegate the skipped methods to the target'

        include_examples 'should delegate the specified methods to the target'
      end # describe
    end # shared_examples

    let(:options) { {} }

    it { expect(described_class).to respond_to(:wrap_delegate).with(1).arguments.and_keywords(:klass, :except, :only) }

    describe 'with a nil delegate' do
      let(:target) { nil }

      it 'should raise an error' do
        expect {
          described_class.wrap_delegate target, **options
        }.to raise_error ArgumentError, 'must specify a delegate'
      end # it

      describe 'with :klass => NilClass' do
        let(:options) { super().merge :klass => NilClass }

        it 'should raise an error' do
          expect {
            described_class.wrap_delegate target, **options
          }.to raise_error ArgumentError, 'must specify a delegate'
        end # it
      end # describe

      describe 'with :klass => unrelated class' do
        let(:options) { super().merge :klass => String }

        it 'should raise an error' do
          expect {
            described_class.wrap_delegate target, **options
          }.to raise_error ArgumentError, 'expected delegate to be a String'
        end # it
      end # describe
    end # describe

    describe 'with an object delegate' do
      include_context 'with a delegate with a custom class'

      let(:target) { delegate }

      include_examples 'should delegate to the target'

      describe 'with :klass => delegate_class' do
        let(:options) { super().merge :klass => delegate_class }

        include_examples 'should delegate to the target'
      end # describe

      describe 'with :klass => delegate_superclass' do
        let(:options)         { super().merge :klass => delegate_superclass }
        let(:method_names)    { delegate_superclass.instance_methods - Object.instance_methods }
        let(:skipped_methods) { delegate_class.instance_methods - delegate_superclass.instance_methods }

        include_examples 'should delegate to the target'
      end # describe

      describe 'with :klass => unrelated class' do
        let(:options) { super().merge :klass => String }

        it 'should raise an error' do
          expect {
            described_class.wrap_delegate target, **options
          }.to raise_error ArgumentError, 'expected delegate to be a String'
        end # it
      end # describe
    end # describe

    describe 'with a method name delegate' do
      include_context 'with a delegate with a custom class'

      let(:target) { :delegate_method }
      let(:described_class) do
        delegate_object = delegate

        super().tap do |klass|
          klass.send(:define_method, :delegate_method, ->() { delegate_object })
        end # tap
      end # let

      it 'should raise an error' do
        expect {
          described_class.wrap_delegate target, **options
        }.to raise_error ArgumentError, 'must specify a delegate class'
      end # it

      describe 'with :klass => delegate_class' do
        let(:options) { super().merge :klass => delegate_class }

        include_examples 'should delegate to the target'
      end # describe

      describe 'with :klass => delegate_superclass' do
        let(:options)         { super().merge :klass => delegate_superclass }
        let(:method_names)    { delegate_superclass.instance_methods - Object.instance_methods }
        let(:skipped_methods) { delegate_class.instance_methods - delegate_superclass.instance_methods }

        include_examples 'should delegate to the target'
      end # describe
    end # describe

    describe 'with an instance variable delegate' do
      include_context 'with a delegate with a custom class'

      let(:target) { :@delegate_variable }

      before(:each) { instance.instance_variable_set(:@delegate_variable, delegate) }

      it 'should raise an error' do
        expect {
          described_class.wrap_delegate target, **options
        }.to raise_error ArgumentError, 'must specify a delegate class'
      end # it

      describe 'with :klass => delegate_class' do
        let(:options) { super().merge :klass => delegate_class }

        include_examples 'should delegate to the target'
      end # describe

      describe 'with :klass => delegate_superclass' do
        let(:options)         { super().merge :klass => delegate_superclass }
        let(:method_names)    { delegate_superclass.instance_methods - Object.instance_methods }
        let(:skipped_methods) { delegate_class.instance_methods - delegate_superclass.instance_methods }

        include_examples 'should delegate to the target'
      end # describe
    end # describe
  end # describe
end # describe
