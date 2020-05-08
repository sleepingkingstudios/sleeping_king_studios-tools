# frozen_string_literal: true

require 'spec_helper'

require 'sleeping_king_studios/tools/toolbox/delegator'

# rubocop:disable RSpec/ExampleLength
# rubocop:disable RSpec/MultipleExpectations
# rubocop:disable RSpec/NestedGroups
RSpec.describe SleepingKingStudios::Tools::Toolbox::Delegator do
  let(:concern) do
    # rubocop:disable RSpec/DescribedClass
    SleepingKingStudios::Tools::Toolbox::Delegator
    # rubocop:enable RSpec/DescribedClass
  end
  let(:described_class) { Class.new.extend(concern) }
  let(:instance)        { described_class.new }

  describe '#delegate' do
    shared_examples 'should delegate method' do |method_name|
      let(:args)   { %w[foo bar baz] }
      let(:kwargs) { { wibble: nil, wobble: nil } }
      let(:result) { nil }

      it { expect(instance).to respond_to(method_name) }

      describe 'with no arguments' do
        let(:result) { Object.new }

        before(:example) do
          allow(delegate).to receive(method_name).and_return(result)
        end

        it 'should delegate the method and return the result' do
          allow(delegate).to receive(method_name).and_return(result)

          3.times do
            expect(instance.send(method_name)).to be result
          end

          expect(delegate)
            .to have_received(method_name)
            .with(no_args)
            .exactly(3).times
        end
      end

      describe 'with an empty hash argument' do
        let(:args) { [{}] }

        before(:example) do
          allow(delegate).to receive(method_name).and_return(result)
        end

        it 'should delegate the method' do
          allow(delegate).to receive(method_name)

          instance.send(method_name, *args)

          expect(delegate).to have_received(method_name).with(*args)
        end
      end

      describe 'with a non-empty hash argument' do
        let(:args) { [{ greetings: :programs }] }

        before(:example) do
          allow(delegate).to receive(method_name).and_return(result)
        end

        it 'should delegate the method' do
          instance.send(method_name, *args)

          expect(delegate).to have_received(method_name).with(*args)
        end
      end

      describe 'with many arguments' do
        before(:example) do
          allow(delegate).to receive(method_name).and_return(result)
        end

        it 'should delegate the method' do
          instance.send(method_name, *args)

          expect(delegate).to have_received(method_name).with(*args)
        end
      end

      describe 'with many arguments and a block' do
        before(:example) do
          allow(delegate).to receive(method_name).and_return(result)
        end

        it 'should delegate the method' do
          allow(delegate).to receive(method_name).with(*args) do |*, &block|
            block.call
          end

          block_called = false

          instance.send(method_name, *args) { block_called = true }

          expect(block_called).to be true

          expect(delegate).to have_received(method_name).with(*args)
        end
      end

      describe 'with keyword arguments' do
        before(:example) do
          allow(delegate).to receive(method_name).and_return(result)
        end

        it 'should delegate the method' do
          instance.send(method_name, **kwargs)

          expect(delegate).to have_received(method_name).with(**kwargs)
        end
      end

      describe 'with many arguments and keyword arguments and a block' do
        before(:example) do
          allow(delegate).to receive(method_name).and_return(result)
        end

        it 'should delegate the method' do
          allow(delegate).to receive(method_name) do |*, &block|
            block.call
          end

          block_called = false

          instance.send(method_name, *args, **kwargs) { block_called = true }

          expect(block_called).to be true

          expect(delegate).to have_received(method_name).with(*args, **kwargs)
        end
      end
    end

    let(:delegate) do
      double( # rubocop:disable RSpec/VerifiedDoubles
        'delegate',
        first_method:  nil,
        second_method: nil,
        third_method:  nil
      )
    end
    let(:options) { {} }

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:delegate)
        .with(1).arguments
        .and_unlimited_arguments
        .and_keywords(:allow_nil, :to)
    end

    describe 'with an undefined delegate' do
      it 'should raise an error' do
        expect { described_class.delegate }
          .to raise_error ArgumentError, 'must specify a delegate'
      end
    end

    describe 'with a nil delegate' do
      describe 'with one method name' do
        let(:delegate) { nil }

        it 'should raise an error' do
          expect do
            described_class.delegate :first_method, to: delegate
          end
            .to raise_error(ArgumentError, 'must specify a delegate')
        end

        describe 'with :allow_nil => true' do
          let(:options) { super().merge allow_nil: true }

          before(:example) do
            described_class.delegate(:first_method, to: delegate, **options)
          end

          it 'should return nil' do
            expect(instance.first_method).to be nil
          end
        end
      end
    end

    describe 'with an object delegate' do
      describe 'with one method name' do
        before(:example) do
          described_class.delegate(:first_method, to: delegate, **options)
        end

        include_examples 'should delegate method', :first_method
      end

      describe 'with many method names' do
        before(:example) do
          described_class.delegate(
            :first_method,
            :second_method,
            :third_method,
            to: delegate,
            **options
          )
        end

        include_examples 'should delegate method', :first_method

        include_examples 'should delegate method', :second_method

        include_examples 'should delegate method', :third_method
      end
    end

    describe 'with a method name delegate' do
      shared_context 'with a defined delegate method' do
        let(:described_class) do
          delegate_object = delegate

          super().tap do |klass|
            klass.send(:define_method, :delegate_method, -> { delegate_object })
          end
        end
      end

      describe 'with one method name' do
        before(:example) do
          described_class.delegate(
            :first_method,
            to: :delegate_method,
            **options
          )
        end

        it 'should raise an error' do
          expect do
            instance.first_method
          end
            .to raise_error NoMethodError, /undefined method `delegate_method'/
        end

        wrap_context 'with a defined delegate method' do
          include_examples 'should delegate method', :first_method

          context 'with a nil delegate' do
            let(:delegate) { nil }

            it 'should raise an error' do
              expect do
                instance.first_method
              end
                .to raise_error NoMethodError, /undefined method `first_method'/
            end

            describe 'with :allow_nil => true' do
              let(:options) { super().merge allow_nil: true }

              it 'should return nil' do
                expect(instance.first_method).to be nil
              end
            end
          end
        end
      end

      describe 'with many method names' do
        before(:example) do
          described_class.delegate(
            :first_method,
            :second_method,
            :third_method,
            to: :delegate_method,
            **options
          )
        end

        it 'should raise an error' do
          expect do
            instance.first_method
          end
            .to raise_error NoMethodError, /undefined method `delegate_method'/
        end

        wrap_context 'with a defined delegate method' do
          include_examples 'should delegate method', :first_method

          include_examples 'should delegate method', :second_method

          include_examples 'should delegate method', :third_method
        end
      end
    end

    describe 'with an instance variable delegate' do
      shared_context 'with a delegate at the instance variable' do
        before(:example) do
          instance.instance_variable_set(:@delegate_variable, delegate)
        end
      end

      describe 'with one method name' do
        before(:example) do
          described_class.delegate(
            :first_method,
            to: :@delegate_variable,
            **options
          )
        end

        it 'should raise an error' do
          expect do
            instance.first_method
          end
            .to raise_error NoMethodError, /undefined method `first_method'/
        end

        wrap_context 'with a delegate at the instance variable' do
          include_examples 'should delegate method', :first_method

          context 'with a nil delegate' do
            let(:delegate) { nil }

            it 'should raise an error' do
              expect do
                instance.first_method
              end
                .to raise_error NoMethodError, /undefined method `first_method'/
            end

            describe 'with :allow_nil => true' do
              let(:options) { super().merge allow_nil: true }

              it 'should return nil' do
                expect(instance.first_method).to be nil
              end
            end
          end
        end
      end

      describe 'with many method names' do
        before(:example) do
          described_class.delegate(
            :first_method,
            :second_method,
            :third_method,
            to: :@delegate_variable,
            **options
          )
        end

        wrap_context 'with a delegate at the instance variable' do
          include_examples 'should delegate method', :first_method

          include_examples 'should delegate method', :second_method

          include_examples 'should delegate method', :third_method
        end
      end
    end
  end

  describe '#wrap_delegate' do
    shared_context 'with a delegate with a custom class' do
      let(:delegate_superclass) do
        Class.new do
          attr_reader :first_method, :second_method, :third_method
        end
      end
      let(:delegate_class) do
        Class.new(delegate_superclass) do
          attr_reader :fourth_method, :fifth_method, :sixth_method
        end
      end
      let(:method_names) do
        delegate_class.instance_methods - Object.instance_methods
      end
      let(:delegate) { delegate_class.new }
    end

    shared_examples 'should not delegate the skipped methods to the target' do
      it 'should not delegate the skipped methods to the target' do
        aggregate_failures 'should not define the delegated methods' do
          skipped_methods.each do |method_name|
            expect(instance).not_to respond_to(method_name)
          end
        end
      end
    end

    shared_examples 'should delegate the specified methods to the target' do
      it 'should delegate the specified methods to the target' do
        aggregate_failures 'should define the delegated methods' do
          delegated_methods.each do |method_name|
            allow(delegate).to receive(:send).with(method_name)

            expect(instance).to respond_to(method_name)

            instance.send(method_name)

            expect(delegate).to have_received(:send).with(method_name)
          end
        end
      end
    end

    shared_examples 'should delegate to the target' do
      let(:skipped_methods) { defined?(super()) ? super() : [] }

      describe 'with no options' do
        let(:delegated_methods) { method_names }

        before(:example) { described_class.wrap_delegate target, **options }

        include_examples 'should not delegate the skipped methods to the target'

        include_examples 'should delegate the specified methods to the target'
      end

      describe 'with :except => methods' do
        let(:skipped_methods) do
          super() + method_names[0...method_names.count / 2]
        end
        let(:delegated_methods) { method_names - skipped_methods }
        let(:options)           { super().merge except: skipped_methods }

        before(:example) { described_class.wrap_delegate target, **options }

        include_examples 'should not delegate the skipped methods to the target'

        include_examples 'should delegate the specified methods to the target'
      end

      describe 'with :only => methods' do
        let(:delegated_methods) { method_names[0...method_names.count / 2] }
        let(:skipped_methods)   { super() + (method_names - delegated_methods) }
        let(:options)           { super().merge only: delegated_methods }

        before(:example) { described_class.wrap_delegate target, **options }

        include_examples 'should not delegate the skipped methods to the target'

        include_examples 'should delegate the specified methods to the target'
      end
    end

    let(:options) { {} }

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:wrap_delegate)
        .with(1).arguments
        .and_keywords(:klass, :except, :only)
    end

    describe 'with a nil delegate' do
      let(:target) { nil }

      it 'should raise an error' do
        expect do
          described_class.wrap_delegate(target, **options)
        end
          .to raise_error ArgumentError, 'must specify a delegate'
      end

      describe 'with :klass => NilClass' do
        let(:options) { super().merge klass: NilClass }

        it 'should raise an error' do
          expect do
            described_class.wrap_delegate(target, **options)
          end
            .to raise_error ArgumentError, 'must specify a delegate'
        end
      end

      describe 'with :klass => unrelated class' do
        let(:options) { super().merge klass: String }

        it 'should raise an error' do
          expect do
            described_class.wrap_delegate target, **options
          end
            .to raise_error ArgumentError, 'expected delegate to be a String'
        end
      end
    end

    describe 'with an object delegate' do
      include_context 'with a delegate with a custom class'

      let(:target) { delegate }

      include_examples 'should delegate to the target'

      describe 'with :klass => delegate_class' do
        let(:options) { super().merge klass: delegate_class }

        include_examples 'should delegate to the target'
      end

      describe 'with :klass => delegate_superclass' do
        let(:options) do
          super().merge klass: delegate_superclass
        end
        let(:method_names) do
          delegate_superclass.instance_methods - Object.instance_methods
        end
        let(:skipped_methods) do
          delegate_class.instance_methods -
            delegate_superclass.instance_methods
        end

        include_examples 'should delegate to the target'
      end

      describe 'with :klass => unrelated class' do
        let(:options) { super().merge klass: String }

        it 'should raise an error' do
          expect do
            described_class.wrap_delegate(target, **options)
          end
            .to raise_error ArgumentError, 'expected delegate to be a String'
        end
      end
    end

    describe 'with a method name delegate' do
      include_context 'with a delegate with a custom class'

      let(:target) { :delegate_method }
      let(:described_class) do
        delegate_object = delegate

        super().tap do |klass|
          klass.send(:define_method, :delegate_method, -> { delegate_object })
        end
      end

      it 'should raise an error' do
        expect do
          described_class.wrap_delegate(target, **options)
        end
          .to raise_error ArgumentError, 'must specify a delegate class'
      end

      describe 'with :klass => delegate_class' do
        let(:options) { super().merge klass: delegate_class }

        include_examples 'should delegate to the target'
      end

      describe 'with :klass => delegate_superclass' do
        let(:options) do
          super().merge klass: delegate_superclass
        end
        let(:method_names) do
          delegate_superclass.instance_methods - Object.instance_methods
        end
        let(:skipped_methods) do
          delegate_class.instance_methods - delegate_superclass.instance_methods
        end

        include_examples 'should delegate to the target'
      end
    end

    describe 'with an instance variable delegate' do
      include_context 'with a delegate with a custom class'

      let(:target) { :@delegate_variable }

      before(:example) do
        instance.instance_variable_set(:@delegate_variable, delegate)
      end

      it 'should raise an error' do
        expect do
          described_class.wrap_delegate(target, **options)
        end
          .to raise_error ArgumentError, 'must specify a delegate class'
      end

      describe 'with :klass => delegate_class' do
        let(:options) { super().merge klass: delegate_class }

        include_examples 'should delegate to the target'
      end

      describe 'with :klass => delegate_superclass' do
        let(:options) do
          super().merge klass: delegate_superclass
        end
        let(:method_names) do
          delegate_superclass.instance_methods - Object.instance_methods
        end
        let(:skipped_methods) do
          delegate_class.instance_methods - delegate_superclass.instance_methods
        end

        include_examples 'should delegate to the target'
      end
    end
  end
end
# rubocop:enable RSpec/ExampleLength
# rubocop:enable RSpec/MultipleExpectations
# rubocop:enable RSpec/NestedGroups
