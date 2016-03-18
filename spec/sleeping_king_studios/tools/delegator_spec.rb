# spec/sleeping_king_studios/tools/delegator_spec.rb

require 'spec_helper'

require 'sleeping_king_studios/tools/delegator'

RSpec.describe SleepingKingStudios::Tools::Delegator do
  let(:concern)         { SleepingKingStudios::Tools::Delegator }
  let(:described_class) { Class.new.extend(concern) }
  let(:instance)        { described_class.new }

  describe '#delegate' do
    shared_examples 'should delegate method' do |method_name|
      let(:args)   { %w(foo bar baz) }
      let(:kwargs) { { :wibble => nil, :wobble => nil } }

      it { expect(instance).to respond_to(method_name) }

      describe 'with no arguments' do
        it 'should delegate the method' do
          expect(delegate).to receive(method_name).with(no_args)

          instance.send(method_name)
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
end # describe
