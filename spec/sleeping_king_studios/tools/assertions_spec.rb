# frozen_string_literal: true

require 'sleeping_king_studios/tools/assertions'

RSpec.describe SleepingKingStudios::Tools::Assertions do
  extend RSpec::SleepingKingStudios::Concerns::ExampleConstants

  subject(:assertions) { described_class.instance }

  shared_context 'with as: value' do
    let(:as)      { 'named_value' }
    let(:options) { super().merge(as: as) }
  end

  shared_context 'with error_class: value' do
    let(:error_class) { ArgumentError }
    let(:options)     { super().merge(error_class: error_class) }
  end

  shared_context 'with message: value' do
    let(:error_message) { 'something went wrong' }
    let(:options)       { super().merge(message: error_message) }
  end

  shared_context 'with optional: false' do
    let(:options) { super().merge(optional: false) }
  end

  shared_context 'with optional: true' do
    let(:options) { super().merge(optional: true) }
  end

  shared_examples 'should raise an exception' do
    it { expect { assert }.to raise_error error_class, error_message }
  end

  shared_examples 'should not raise an exception' do
    it { expect { assert }.not_to raise_error }
  end

  let(:error_class) { described_class::AssertionError }
  let(:options)     { {} }

  describe '::AssertionError' do
    it { expect(described_class::AssertionError).to be_a Class }

    it { expect(described_class::AssertionError).to be < StandardError }
  end

  describe '.instance' do
    it { expect(described_class).to respond_to(:instance).with(0).arguments }

    it { expect(described_class.instance).to be_a described_class }

    it 'should cache the instance' do
      cached = described_class.instance

      expect(described_class.instance).to be cached
    end
  end

  describe '#assert' do
    let(:error_message) { 'block returned a falsy value' }

    def assert
      assertions.assert(**options, &block)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:assert)
        .with(0).arguments
        .and_keywords(:error_class, :message)
        .and_a_block
    end

    describe 'with a block that returns a falsy value' do
      let(:block) { -> {} }

      include_examples 'should raise an exception'
    end

    describe 'with a block that returns a truthy value' do
      let(:block) { -> { :ok } }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with error_class: value' do
      describe 'with a block that returns a falsy value' do
        let(:block) { -> {} }

        include_examples 'should raise an exception'
      end

      describe 'with a block that returns a truthy value' do
        let(:block) { -> { :ok } }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with message: value' do
      describe 'with a block that returns a falsy value' do
        let(:block) { -> {} }

        include_examples 'should raise an exception'
      end

      describe 'with a block that returns a truthy value' do
        let(:block) { -> { :ok } }

        include_examples 'should not raise an exception'
      end
    end
  end

  describe '#assert_class' do
    let(:error_message) { 'value is not a Class' }

    def assert
      assertions.assert_class(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:assert_class)
        .with(1).argument
        .and_keywords(:as, :error_class, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception'
    end

    describe 'with a Class' do
      let(:value) { Class.new }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with as: value' do
      let(:error_message) { "#{as} is not a Class" }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with a Class' do
        let(:value) { Class.new }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with error_class: value' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with a Class' do
        let(:value) { Class.new }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with message: value' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with a Class' do
        let(:value) { Class.new }

        include_examples 'should not raise an exception'
      end
    end
  end

  describe '#assert_instance_of' do
    let(:expected)      { StandardError }
    let(:error_message) { "value is not an instance of #{expected}" }

    def assert
      assertions.assert_instance_of(value, expected: expected, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:assert_instance_of)
        .with(1).argument
        .and_keywords(:as, :error_class, :expected, :message, :optional)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception'
    end

    describe 'with an instance of the class' do
      let(:value) { StandardError.new }

      include_examples 'should not raise an exception'
    end

    describe 'with an instance of a subclass of the class' do
      let(:value) { RuntimeError.new }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with as: value' do
      let(:error_message) { "#{as} is not an instance of #{expected}" }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { StandardError.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { RuntimeError.new }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with error_class: value' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { StandardError.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { RuntimeError.new }

        include_examples 'should not raise an exception'
      end
    end

    describe 'with expected: nil' do
      it 'should raise an exception' do
        expect { assertions.assert_instance_of(nil, expected: nil) }
          .to raise_error ArgumentError, 'expected must be a Class'
      end
    end

    describe 'with expected: an Object' do
      it 'should raise an exception' do
        expect do
          assertions.assert_instance_of(nil, expected: Object.new.freeze)
        end
          .to raise_error ArgumentError, 'expected must be a Class'
      end
    end

    describe 'with expected: an anonymous subclass' do
      let(:expected) { Class.new(StandardError) }
      let(:error_message) do
        "value is not an instance of #{expected} (StandardError)"
      end

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { expected.new }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with message: value' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { StandardError.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { RuntimeError.new }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: false' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { StandardError.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { RuntimeError.new }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: true' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should not raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { StandardError.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { RuntimeError.new }

        include_examples 'should not raise an exception'
      end
    end
  end

  describe '#assert_matches' do
    let(:as)            { 'value' }
    let(:expected)      { Spec::ExampleMatcher.new('expected') }
    let(:error_message) { "#{as} does not match the expected value" }
    let(:matching)      { 'expected' }
    let(:nonmatching)   { 'actual' }

    example_class 'Spec::ExampleMatcher', Struct.new(:value) do |klass|
      klass.define_method(:===) { |other| other == value }
    end

    def assert
      assertions.assert_matches(value, expected: expected, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:assert_matches)
        .with(1).argument
        .and_keywords(:as, :error_class, :expected, :message, :optional)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception'
    end

    describe 'with a non-matching value' do
      let(:value) { nonmatching }

      include_examples 'should raise an exception'
    end

    describe 'with a matching value' do
      let(:value) { matching }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with as: value' do
      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception'
      end

      describe 'with a matching value' do
        let(:value) { matching }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with error_class: value' do
      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception'
      end

      describe 'with a matching value' do
        let(:value) { matching }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with message: value' do
      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception'
      end

      describe 'with a matching value' do
        let(:value) { matching }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: false' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception'
      end

      describe 'with a matching value' do
        let(:value) { matching }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: true' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should not raise an exception'
      end

      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception'
      end

      describe 'with a matching value' do
        let(:value) { matching }

        include_examples 'should not raise an exception'
      end
    end

    context 'when the expected value is a Class' do
      let(:error_message) { "#{as} is not an instance of StandardError" }
      let(:expected)      { StandardError }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { StandardError.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { RuntimeError.new }

        include_examples 'should not raise an exception'
      end

      wrap_context 'with as: value' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should raise an exception'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_examples 'should raise an exception'
        end

        describe 'with an instance of the class' do
          let(:value) { StandardError.new }

          include_examples 'should not raise an exception'
        end

        describe 'with an instance of a subclass of the class' do
          let(:value) { RuntimeError.new }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with error_class: value' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should raise an exception'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_examples 'should raise an exception'
        end

        describe 'with an instance of the class' do
          let(:value) { StandardError.new }

          include_examples 'should not raise an exception'
        end

        describe 'with an instance of a subclass of the class' do
          let(:value) { RuntimeError.new }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with message: value' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should raise an exception'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_examples 'should raise an exception'
        end

        describe 'with an instance of the class' do
          let(:value) { StandardError.new }

          include_examples 'should not raise an exception'
        end

        describe 'with an instance of a subclass of the class' do
          let(:value) { RuntimeError.new }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with optional: false' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should raise an exception'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_examples 'should raise an exception'
        end

        describe 'with an instance of the class' do
          let(:value) { StandardError.new }

          include_examples 'should not raise an exception'
        end

        describe 'with an instance of a subclass of the class' do
          let(:value) { RuntimeError.new }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with optional: true' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should not raise an exception'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_examples 'should raise an exception'
        end

        describe 'with an instance of the class' do
          let(:value) { StandardError.new }

          include_examples 'should not raise an exception'
        end

        describe 'with an instance of a subclass of the class' do
          let(:value) { RuntimeError.new }

          include_examples 'should not raise an exception'
        end
      end
    end

    context 'when the expected value is an anonymous Class' do
      let(:expected) { Class.new(StandardError) }
      let(:error_message) do
        "value is not an instance of #{expected} (StandardError)"
      end

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { expected.new }

        include_examples 'should not raise an exception'
      end

      wrap_context 'with optional: false' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should raise an exception'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_examples 'should raise an exception'
        end

        describe 'with an instance of the class' do
          let(:value) { expected.new }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with optional: true' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should not raise an exception'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_examples 'should raise an exception'
        end

        describe 'with an instance of the class' do
          let(:value) { expected.new }

          include_examples 'should not raise an exception'
        end
      end
    end

    context 'when the expected value is a Proc' do
      let(:expected)      { ->(value) { value >= 0 } }
      let(:error_message) { "#{as} does not match the Proc" }

      describe 'with nil' do
        let(:value) { nil }

        it { expect { assert }.to raise_error NoMethodError }
      end

      describe 'with a non-matching value' do
        let(:value) { -1 }

        include_examples 'should raise an exception'
      end

      describe 'with a matching value' do
        let(:value) { 1 }

        include_examples 'should not raise an exception'
      end

      wrap_context 'with as: value' do
        describe 'with a non-matching value' do
          let(:value) { -1 }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 1 }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with error_class: value' do
        describe 'with a non-matching value' do
          let(:value) { -1 }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 1 }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with message: value' do
        describe 'with a non-matching value' do
          let(:value) { -1 }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 1 }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with optional: false' do
        describe 'with nil' do
          let(:value) { nil }

          it { expect { assert }.to raise_error NoMethodError }
        end

        describe 'with a non-matching value' do
          let(:value) { -1 }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 1 }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with optional: true' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should not raise an exception'
        end

        describe 'with a non-matching value' do
          let(:value) { -1 }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 1 }

          include_examples 'should not raise an exception'
        end
      end
    end

    context 'when the expected value is a Regexp' do
      let(:expected) { /foo/ }
      let(:error_message) do
        "#{as} does not match the pattern #{expected.inspect}"
      end

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with a non-matching value' do
        let(:value) { 'bar' }

        include_examples 'should raise an exception'
      end

      describe 'with a matching value' do
        let(:value) { 'foo' }

        include_examples 'should not raise an exception'
      end

      wrap_context 'with as: value' do
        describe 'with a non-matching value' do
          let(:value) { 'bar' }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 'foo' }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with error_class: value' do
        describe 'with a non-matching value' do
          let(:value) { 'bar' }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 'foo' }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with message: value' do
        describe 'with a non-matching value' do
          let(:value) { 'bar' }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 'foo' }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with optional: false' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should raise an exception'
        end

        describe 'with a non-matching value' do
          let(:value) { 'bar' }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 'foo' }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with optional: true' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should not raise an exception'
        end

        describe 'with a non-matching value' do
          let(:value) { 'bar' }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 'foo' }

          include_examples 'should not raise an exception'
        end
      end
    end
  end

  describe '#assert_name' do
    let(:as)            { 'value' }
    let(:error_message) { "#{as} is not a String or a Symbol" }

    def assert
      assertions.assert_name(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:assert_name)
        .with(1).argument
        .and_keywords(:as, :error_class, :message, :optional)
    end

    describe 'with nil' do
      let(:value)         { nil }
      let(:error_message) { "#{as} can't be blank" }

      include_examples 'should raise an exception'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception'
    end

    describe 'with an empty String' do
      let(:value)         { '' }
      let(:error_message) { "#{as} can't be blank" }

      include_examples 'should raise an exception'
    end

    describe 'with an empty Symbol' do
      let(:value)         { :'' }
      let(:error_message) { "#{as} can't be blank" }

      include_examples 'should raise an exception'
    end

    describe 'with a String' do
      let(:value) { 'string' }

      include_examples 'should not raise an exception'
    end

    describe 'with a Symbol' do
      let(:value) { :symbol }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with as: value' do
      describe 'with nil' do
        let(:value)         { nil }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an empty String' do
        let(:value)         { '' }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with an empty Symbol' do
        let(:value)         { :'' }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with a String' do
        let(:value) { 'string' }

        include_examples 'should not raise an exception'
      end

      describe 'with a Symbol' do
        let(:value) { :symbol }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with error_class: value' do
      describe 'with nil' do
        let(:value)         { nil }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an empty String' do
        let(:value)         { '' }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with an empty Symbol' do
        let(:value)         { :'' }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with a String' do
        let(:value) { 'string' }

        include_examples 'should not raise an exception'
      end

      describe 'with a Symbol' do
        let(:value) { :symbol }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with message: value' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an empty String' do
        let(:value) { '' }

        include_examples 'should raise an exception'
      end

      describe 'with an empty Symbol' do
        let(:value) { :'' }

        include_examples 'should raise an exception'
      end

      describe 'with a String' do
        let(:value) { 'string' }

        include_examples 'should not raise an exception'
      end

      describe 'with a Symbol' do
        let(:value) { :symbol }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: false' do
      describe 'with nil' do
        let(:value)         { nil }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an empty String' do
        let(:value)         { '' }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with an empty Symbol' do
        let(:value)         { :'' }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with a String' do
        let(:value) { 'string' }

        include_examples 'should not raise an exception'
      end

      describe 'with a Symbol' do
        let(:value) { :symbol }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: true' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should not raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an empty String' do
        let(:value)         { '' }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with an empty Symbol' do
        let(:value)         { :'' }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with a String' do
        let(:value) { 'string' }

        include_examples 'should not raise an exception'
      end

      describe 'with a Symbol' do
        let(:value) { :symbol }

        include_examples 'should not raise an exception'
      end
    end
  end

  describe '#validate' do
    let(:error_class)   { ArgumentError }
    let(:error_message) { 'block returned a falsy value' }

    def assert
      assertions.validate(**options, &block)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:validate)
        .with(0).arguments
        .and_keywords(:message)
        .and_a_block
    end

    describe 'with a block that returns a falsy value' do
      let(:block) { -> {} }

      include_examples 'should raise an exception'
    end

    describe 'with a block that returns a truthy value' do
      let(:block) { -> { :ok } }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with message: value' do
      describe 'with a block that returns a falsy value' do
        let(:block) { -> {} }

        include_examples 'should raise an exception'
      end

      describe 'with a block that returns a truthy value' do
        let(:block) { -> { :ok } }

        include_examples 'should not raise an exception'
      end
    end
  end

  describe '#validate_class' do
    let(:error_class)   { ArgumentError }
    let(:error_message) { 'value is not a Class' }

    def assert
      assertions.validate_class(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:validate_class)
        .with(1).argument
        .and_keywords(:as, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception'
    end

    describe 'with a Class' do
      let(:value) { Class.new }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with as: value' do
      let(:error_message) { "#{as} is not a Class" }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with a Class' do
        let(:value) { Class.new }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with message: value' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with a Class' do
        let(:value) { Class.new }

        include_examples 'should not raise an exception'
      end
    end
  end

  describe '#validate_instance_of' do
    let(:expected)      { StandardError }
    let(:error_class)   { ArgumentError }
    let(:error_message) { "value is not an instance of #{expected}" }

    def assert
      assertions.validate_instance_of(value, expected: expected, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:validate_instance_of)
        .with(1).argument
        .and_keywords(:as, :expected, :message, :optional)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception'
    end

    describe 'with an instance of the class' do
      let(:value) { StandardError.new }

      include_examples 'should not raise an exception'
    end

    describe 'with an instance of a subclass of the class' do
      let(:value) { RuntimeError.new }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with as: value' do
      let(:error_message) { "#{as} is not an instance of #{expected}" }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { StandardError.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { RuntimeError.new }

        include_examples 'should not raise an exception'
      end
    end

    describe 'with expected: nil' do
      it 'should raise an exception' do
        expect { assertions.validate_instance_of(nil, expected: nil) }
          .to raise_error ArgumentError, 'expected must be a Class'
      end
    end

    describe 'with expected: an Object' do
      it 'should raise an exception' do
        expect do
          assertions.validate_instance_of(nil, expected: Object.new.freeze)
        end
          .to raise_error ArgumentError, 'expected must be a Class'
      end
    end

    describe 'with expected: an anonymous subclass' do
      let(:expected) { Class.new(StandardError) }
      let(:error_message) do
        "value is not an instance of #{expected} (StandardError)"
      end

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { expected.new }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with message: value' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { StandardError.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { RuntimeError.new }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: false' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { StandardError.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { RuntimeError.new }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: true' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should not raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { StandardError.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { RuntimeError.new }

        include_examples 'should not raise an exception'
      end
    end
  end

  describe '#validate_matches' do
    let(:as)            { 'value' }
    let(:expected)      { Spec::ExampleMatcher.new('expected') }
    let(:error_class)   { ArgumentError }
    let(:error_message) { "#{as} does not match the expected value" }
    let(:matching)      { 'expected' }
    let(:nonmatching)   { 'actual' }

    example_class 'Spec::ExampleMatcher', Struct.new(:value) do |klass|
      klass.define_method(:===) { |other| other == value }
    end

    def assert
      assertions.validate_matches(value, expected: expected, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:validate_matches)
        .with(1).argument
        .and_keywords(:as, :expected, :message, :optional)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception'
    end

    describe 'with a non-matching value' do
      let(:value) { nonmatching }

      include_examples 'should raise an exception'
    end

    describe 'with a matching value' do
      let(:value) { matching }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with as: value' do
      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception'
      end

      describe 'with a matching value' do
        let(:value) { matching }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with message: value' do
      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception'
      end

      describe 'with a matching value' do
        let(:value) { matching }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: false' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception'
      end

      describe 'with a matching value' do
        let(:value) { matching }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: true' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should not raise an exception'
      end

      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception'
      end

      describe 'with a matching value' do
        let(:value) { matching }

        include_examples 'should not raise an exception'
      end
    end

    context 'when the expected value is a Class' do
      let(:error_message) { "#{as} is not an instance of StandardError" }
      let(:expected)      { StandardError }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { StandardError.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { RuntimeError.new }

        include_examples 'should not raise an exception'
      end

      wrap_context 'with as: value' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should raise an exception'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_examples 'should raise an exception'
        end

        describe 'with an instance of the class' do
          let(:value) { StandardError.new }

          include_examples 'should not raise an exception'
        end

        describe 'with an instance of a subclass of the class' do
          let(:value) { RuntimeError.new }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with message: value' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should raise an exception'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_examples 'should raise an exception'
        end

        describe 'with an instance of the class' do
          let(:value) { StandardError.new }

          include_examples 'should not raise an exception'
        end

        describe 'with an instance of a subclass of the class' do
          let(:value) { RuntimeError.new }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with optional: false' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should raise an exception'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_examples 'should raise an exception'
        end

        describe 'with an instance of the class' do
          let(:value) { StandardError.new }

          include_examples 'should not raise an exception'
        end

        describe 'with an instance of a subclass of the class' do
          let(:value) { RuntimeError.new }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with optional: true' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should not raise an exception'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_examples 'should raise an exception'
        end

        describe 'with an instance of the class' do
          let(:value) { StandardError.new }

          include_examples 'should not raise an exception'
        end

        describe 'with an instance of a subclass of the class' do
          let(:value) { RuntimeError.new }

          include_examples 'should not raise an exception'
        end
      end
    end

    context 'when the expected value is an anonymous Class' do
      let(:expected) { Class.new(StandardError) }
      let(:error_message) do
        "value is not an instance of #{expected} (StandardError)"
      end

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an instance of the class' do
        let(:value) { expected.new }

        include_examples 'should not raise an exception'
      end

      wrap_context 'with optional: false' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should raise an exception'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_examples 'should raise an exception'
        end

        describe 'with an instance of the class' do
          let(:value) { expected.new }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with optional: true' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should not raise an exception'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_examples 'should raise an exception'
        end

        describe 'with an instance of the class' do
          let(:value) { expected.new }

          include_examples 'should not raise an exception'
        end
      end
    end

    context 'when the expected value is a Proc' do
      let(:expected)      { ->(value) { value >= 0 } }
      let(:error_message) { "#{as} does not match the Proc" }

      describe 'with nil' do
        let(:value) { nil }

        it { expect { assert }.to raise_error NoMethodError }
      end

      describe 'with a non-matching value' do
        let(:value) { -1 }

        include_examples 'should raise an exception'
      end

      describe 'with a matching value' do
        let(:value) { 1 }

        include_examples 'should not raise an exception'
      end

      wrap_context 'with as: value' do
        describe 'with a non-matching value' do
          let(:value) { -1 }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 1 }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with message: value' do
        describe 'with a non-matching value' do
          let(:value) { -1 }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 1 }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with optional: false' do
        describe 'with nil' do
          let(:value) { nil }

          it { expect { assert }.to raise_error NoMethodError }
        end

        describe 'with a non-matching value' do
          let(:value) { -1 }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 1 }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with optional: true' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should not raise an exception'
        end

        describe 'with a non-matching value' do
          let(:value) { -1 }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 1 }

          include_examples 'should not raise an exception'
        end
      end
    end

    context 'when the expected value is a Regexp' do
      let(:expected) { /foo/ }
      let(:error_message) do
        "#{as} does not match the pattern #{expected.inspect}"
      end

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with a non-matching value' do
        let(:value) { 'bar' }

        include_examples 'should raise an exception'
      end

      describe 'with a matching value' do
        let(:value) { 'foo' }

        include_examples 'should not raise an exception'
      end

      wrap_context 'with as: value' do
        describe 'with a non-matching value' do
          let(:value) { 'bar' }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 'foo' }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with message: value' do
        describe 'with a non-matching value' do
          let(:value) { 'bar' }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 'foo' }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with optional: false' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should raise an exception'
        end

        describe 'with a non-matching value' do
          let(:value) { 'bar' }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 'foo' }

          include_examples 'should not raise an exception'
        end
      end

      wrap_context 'with optional: true' do
        describe 'with nil' do
          let(:value) { nil }

          include_examples 'should not raise an exception'
        end

        describe 'with a non-matching value' do
          let(:value) { 'bar' }

          include_examples 'should raise an exception'
        end

        describe 'with a matching value' do
          let(:value) { 'foo' }

          include_examples 'should not raise an exception'
        end
      end
    end
  end

  describe '#validate_name' do
    let(:as)            { 'value' }
    let(:error_class)   { ArgumentError }
    let(:error_message) { "#{as} is not a String or a Symbol" }

    def assert
      assertions.validate_name(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:validate_name)
        .with(1).argument
        .and_keywords(:as, :message, :optional)
    end

    describe 'with nil' do
      let(:value)         { nil }
      let(:error_message) { "#{as} can't be blank" }

      include_examples 'should raise an exception'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception'
    end

    describe 'with an empty String' do
      let(:value)         { '' }
      let(:error_message) { "#{as} can't be blank" }

      include_examples 'should raise an exception'
    end

    describe 'with an empty Symbol' do
      let(:value)         { :'' }
      let(:error_message) { "#{as} can't be blank" }

      include_examples 'should raise an exception'
    end

    describe 'with a String' do
      let(:value) { 'string' }

      include_examples 'should not raise an exception'
    end

    describe 'with a Symbol' do
      let(:value) { :symbol }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with as: value' do
      describe 'with nil' do
        let(:value)         { nil }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an empty String' do
        let(:value)         { '' }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with an empty Symbol' do
        let(:value)         { :'' }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with a String' do
        let(:value) { 'string' }

        include_examples 'should not raise an exception'
      end

      describe 'with a Symbol' do
        let(:value) { :symbol }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with message: value' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an empty String' do
        let(:value) { '' }

        include_examples 'should raise an exception'
      end

      describe 'with an empty Symbol' do
        let(:value) { :'' }

        include_examples 'should raise an exception'
      end

      describe 'with a String' do
        let(:value) { 'string' }

        include_examples 'should not raise an exception'
      end

      describe 'with a Symbol' do
        let(:value) { :symbol }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: false' do
      describe 'with nil' do
        let(:value)         { nil }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an empty String' do
        let(:value)         { '' }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with an empty Symbol' do
        let(:value)         { :'' }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with a String' do
        let(:value) { 'string' }

        include_examples 'should not raise an exception'
      end

      describe 'with a Symbol' do
        let(:value) { :symbol }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: true' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should not raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception'
      end

      describe 'with an empty String' do
        let(:value)         { '' }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with an empty Symbol' do
        let(:value)         { :'' }
        let(:error_message) { "#{as} can't be blank" }

        include_examples 'should raise an exception'
      end

      describe 'with a String' do
        let(:value) { 'string' }

        include_examples 'should not raise an exception'
      end

      describe 'with a Symbol' do
        let(:value) { :symbol }

        include_examples 'should not raise an exception'
      end
    end
  end
end
