# frozen_string_literal: true

require 'sleeping_king_studios/tools/assertions'

RSpec.describe SleepingKingStudios::Tools::Assertions do
  extend RSpec::SleepingKingStudios::Concerns::ExampleConstants

  subject(:assertions) { described_class.instance }

  shared_context 'with error_class: value' do
    let(:error_class) { ArgumentError }
    let(:options)     { super().merge(error_class:) }
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

  shared_examples 'should raise an exception with the failure message' \
  do |**example_options|
    let(:message_options) do
      hsh = defined?(super()) ? super() : options
      hsh = hsh.merge(as: false) unless example_options.fetch(:as, true)
      hsh
    end
    let(:generated_message) do
      scope =
        "sleeping_king_studios.tools.assertions.#{example_options[:scope]}"

      assertions.error_message_for(scope, **message_options)
    end

    it { expect { assert }.to raise_error error_class, error_message }

    it { expect { assert }.to raise_error error_class, generated_message }

    if example_options.fetch(:as, true)
      describe 'with as: value' do
        let(:options) { super().merge(as: 'custom name') }

        it { expect { assert }.to raise_error error_class, error_message }

        it { expect { assert }.to raise_error error_class, generated_message }
      end
    end

    describe 'with message: value' do
      let(:options) { super().merge(message: 'something went wrong') }

      it { expect { assert }.to raise_error error_class, options[:message] }
    end
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

  describe '#aggregator_class' do
    it { expect(assertions).to respond_to(:aggregator_class).with(0).arguments }

    it { expect(assertions.aggregator_class).to be described_class::Aggregator }
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

      include_examples 'should raise an exception with the failure message',
        as:    false,
        scope: 'block'
    end

    describe 'with a block that returns a truthy value' do
      let(:block) { -> { :ok } }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with error_class: value' do
      describe 'with a block that returns a falsy value' do
        let(:block) { -> {} }

        include_examples 'should raise an exception with the failure message',
          as:    false,
          scope: 'block'
      end

      describe 'with a block that returns a truthy value' do
        let(:block) { -> { :ok } }

        include_examples 'should not raise an exception'
      end
    end
  end

  describe '#assert_blank' do
    let(:error_message) do
      "#{options.fetch(:as, 'value')} must be nil or empty"
    end

    def assert
      assertions.assert_blank(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:assert_blank)
        .with(1).argument
        .and_keywords(:as, :error_class, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should not raise an exception'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception with the failure message',
        scope: 'blank'
    end

    describe 'with an empty value' do
      let(:value) { Struct.new(:empty) { def empty? = empty }.new(true) }

      include_examples 'should not raise an exception'
    end

    describe 'with a non-empty value' do
      let(:value) { Struct.new(:empty) { def empty? = empty }.new(false) }

      include_examples 'should raise an exception with the failure message',
        scope: 'blank'
    end

    wrap_context 'with error_class: value' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should not raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception with the failure message',
          scope: 'blank'
      end

      describe 'with an empty value' do
        let(:value) { Struct.new(:empty) { def empty? = empty }.new(true) }

        include_examples 'should not raise an exception'
      end

      describe 'with a non-empty value' do
        let(:value) { Struct.new(:empty) { def empty? = empty }.new(false) }

        include_examples 'should raise an exception with the failure message',
          scope: 'blank'
      end
    end
  end

  describe '#assert_boolean' do
    let(:error_message) do
      "#{options.fetch(:as, 'value')} must be true or false"
    end

    def assert
      assertions.assert_boolean(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:assert_boolean)
        .with(1).argument
        .and_keywords(:as, :error_class, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception with the failure message',
        scope: 'boolean'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception with the failure message',
        scope: 'boolean'
    end

    describe 'with false' do
      let(:value) { false }

      include_examples 'should not raise an exception'
    end

    describe 'with true' do
      let(:value) { true }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with error_class: value' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'boolean'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception with the failure message',
          scope: 'boolean'
      end

      describe 'with false' do
        let(:value) { false }

        include_examples 'should not raise an exception'
      end

      describe 'with true' do
        let(:value) { true }

        include_examples 'should not raise an exception'
      end
    end
  end

  describe '#assert_class' do
    let(:error_message) do
      "#{options.fetch(:as, 'value')} is not a Class"
    end

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

      include_examples 'should raise an exception with the failure message',
        scope: 'class'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception with the failure message',
        scope: 'class'
    end

    describe 'with a Module' do
      let(:value) { Module.new }

      include_examples 'should raise an exception with the failure message',
        scope: 'class'
    end

    describe 'with a Class' do
      let(:value) { Class.new }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with error_class: value' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'class'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception with the failure message',
          scope: 'class'
      end

      describe 'with a Module' do
        let(:value) { Module.new }

        include_examples 'should raise an exception with the failure message',
          scope: 'class'
      end

      describe 'with a Class' do
        let(:value) { Class.new }

        include_examples 'should not raise an exception'
      end
    end
  end

  describe '#assert_group' do
    let(:block)   { ->(_) {} }
    let(:options) { {} }

    def assert
      assertions.assert_group(**options, &block)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:assert_group)
        .with(0).arguments
        .and_keywords(:error_class, :message)
        .and_a_block
    end

    it 'should alias the method' do
      expect(assertions).to have_aliased_method(:assert_group).as(:aggregate)
    end

    describe 'without a block' do
      let(:error_message) { 'no block given' }

      it 'should raise an exception' do
        expect { assertions.assert_group }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a block that raises an exception' do
      let(:label) { nil }
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_instance_of(label, as: 'label')
        end
      end
      let(:error_message) { 'missing keyword: :expected' }

      it 'should raise an exception' do
        expect { assertions.assert_group(&block) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a block with no assertions' do
      let(:block) { ->(_) {} }

      include_examples 'should not raise an exception'
    end

    describe 'with a block with a failing assertion' do
      let(:value)         { Object.new.freeze }
      let(:error_message) { 'value is not a String or a Symbol' }
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_name(value)
        end
      end

      include_examples 'should raise an exception'
    end

    describe 'with a block with a passing assertion' do
      let(:value) { 'ok' }
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_name(value)
        end
      end

      include_examples 'should not raise an exception'
    end

    describe 'with a block with many failing assertions' do
      let(:label) { nil }
      let(:value) { Object.new.freeze }
      let(:error_message) do
        'value is not a String or a Symbol, label is not an instance of ' \
          'String, something went wrong'
      end
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_name(value)
          aggregator.assert_instance_of(label, expected: String, as: 'label')
          aggregator.validate(message: 'something went wrong') { false }
        end
      end

      include_examples 'should raise an exception'
    end

    describe 'with a block with many passing assertions' do
      let(:label) { 'self-sealing stem bolts' }
      let(:value) { 'Quantity: 1,000' }
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_name(value)
          aggregator.assert_instance_of(label, expected: String, as: 'label')
          aggregator.validate(message: 'something went wrong') { true }
        end
      end

      include_examples 'should not raise an exception'
    end

    describe 'with a block with nested aggregations' do
      let(:quantity) { nil }
      let(:label)    { nil }
      let(:error_message) do
        "label is not an instance of String, label can't be blank, quantity " \
          'is not an instance of Integer'
      end
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_group do |inner|
            inner.assert_instance_of(label, expected: String, as: 'label')
            inner.assert_presence(label, as: 'label')
          end

          aggregator
            .assert_instance_of(quantity, expected: Integer, as: 'quantity')
        end
      end

      include_examples 'should raise an exception'
    end

    describe 'with a block with nested aggregations and message: value' do
      let(:quantity) { nil }
      let(:label)    { nil }
      let(:error_message) do
        'label is invalid, quantity is not an instance of Integer'
      end
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_group(message: 'label is invalid') do |inner|
            inner.assert_instance_of(label, expected: String, as: 'label')
            inner.assert_presence(label, as: 'label')
          end

          aggregator
            .assert_instance_of(quantity, expected: Integer, as: 'quantity')
        end
      end

      include_examples 'should raise an exception'
    end

    wrap_context 'with error_class: value' do
      describe 'with a block with no assertions' do
        let(:block) { ->(_) {} }

        include_examples 'should not raise an exception'
      end

      describe 'with a block with a failing assertion' do
        let(:value)         { Object.new.freeze }
        let(:error_message) { 'value is not a String or a Symbol' }
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_name(value)
          end
        end

        include_examples 'should raise an exception'
      end

      describe 'with a block with a passing assertion' do
        let(:value) { 'ok' }
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_name(value)
          end
        end

        include_examples 'should not raise an exception'
      end

      describe 'with a block with many failing assertions' do
        let(:label) { nil }
        let(:value) { Object.new.freeze }
        let(:error_message) do
          'value is not a String or a Symbol, label is not an instance of ' \
            'String, something went wrong'
        end
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_name(value)
            aggregator.assert_instance_of(label, expected: String, as: 'label')
            aggregator.validate(message: 'something went wrong') { false }
          end
        end

        include_examples 'should raise an exception'
      end

      describe 'with a block with many passing assertions' do
        let(:label) { 'self-sealing stem bolts' }
        let(:value) { 'Quantity: 1,000' }
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_name(value)
            aggregator.assert_instance_of(label, expected: String, as: 'label')
            aggregator.validate(message: 'something went wrong') { true }
          end
        end

        include_examples 'should not raise an exception'
      end

      describe 'with a block with nested aggregations' do
        let(:quantity) { nil }
        let(:label)    { nil }
        let(:error_message) do
          "label is not an instance of String, label can't be blank, " \
            'quantity is not an instance of Integer'
        end
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_group do |inner|
              inner.assert_instance_of(label, expected: String, as: 'label')
              inner.assert_presence(label, as: 'label')
            end

            aggregator
              .assert_instance_of(quantity, expected: Integer, as: 'quantity')
          end
        end

        include_examples 'should raise an exception'
      end

      describe 'with a block with nested aggregations and message: value' do
        let(:quantity) { nil }
        let(:label)    { nil }
        let(:error_message) do
          'label is invalid, quantity is not an instance of Integer'
        end
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_group(message: 'label is invalid') do |inner|
              inner.assert_instance_of(label, expected: String, as: 'label')
              inner.assert_presence(label, as: 'label')
            end

            aggregator
              .assert_instance_of(quantity, expected: Integer, as: 'quantity')
          end
        end

        include_examples 'should raise an exception'
      end
    end

    wrap_context 'with message: value' do
      describe 'with a block with no assertions' do
        let(:block) { ->(_) {} }

        include_examples 'should not raise an exception'
      end

      describe 'with a block with a failing assertion' do
        let(:value) { Object.new.freeze }
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_name(value)
          end
        end

        include_examples 'should raise an exception'
      end

      describe 'with a block with a passing assertion' do
        let(:value) { 'ok' }
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_name(value)
          end
        end

        include_examples 'should not raise an exception'
      end

      describe 'with a block with many failing assertions' do
        let(:label) { nil }
        let(:value) { Object.new.freeze }
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_name(value)
            aggregator.assert_instance_of(label, expected: String, as: 'label')
            aggregator.validate(message: 'something went wrong') { false }
          end
        end

        include_examples 'should raise an exception'
      end

      describe 'with a block with many passing assertions' do
        let(:label) { 'self-sealing stem bolts' }
        let(:value) { 'Quantity: 1,000' }
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_name(value)
            aggregator.assert_instance_of(label, expected: String, as: 'label')
            aggregator.validate(message: 'something went wrong') { true }
          end
        end

        include_examples 'should not raise an exception'
      end

      describe 'with a block with nested aggregations' do
        let(:quantity) { nil }
        let(:label)    { nil }
        let(:error_message) do
          "label is not an instance of String, label can't be blank, " \
            'quantity is not an instance of Integer'
        end
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_group do |inner|
              inner.assert_instance_of(label, expected: String, as: 'label')
              inner.assert_presence(label, as: 'label')
            end

            aggregator
              .assert_instance_of(quantity, expected: Integer, as: 'quantity')
          end
        end

        include_examples 'should raise an exception'
      end

      describe 'with a block with nested aggregations and message: value' do
        let(:quantity) { nil }
        let(:label)    { nil }
        let(:error_message) do
          'label is invalid, quantity is not an instance of Integer'
        end
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_group(message: 'label is invalid') do |inner|
              inner.assert_instance_of(label, expected: String, as: 'label')
              inner.assert_presence(label, as: 'label')
            end

            aggregator
              .assert_instance_of(quantity, expected: Integer, as: 'quantity')
          end
        end

        include_examples 'should raise an exception'
      end
    end
  end

  describe '#assert_instance_of' do
    let(:expected) { StandardError }
    let(:options)  { { expected: } }
    let(:error_message) do
      "#{options.fetch(:as, 'value')} is not an instance of #{expected}"
    end

    def assert
      assertions.assert_instance_of(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:assert_instance_of)
        .with(1).argument
        .and_keywords(:as, :error_class, :expected, :message, :optional)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception with the failure message',
        scope: 'instance_of'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception with the failure message',
        scope: 'instance_of'
    end

    describe 'with an instance of the class' do
      let(:value) { StandardError.new }

      include_examples 'should not raise an exception'
    end

    describe 'with an instance of a subclass of the class' do
      let(:value) { RuntimeError.new }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with error_class: value' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of'
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
      let(:message_options) do
        options.merge(parent: StandardError)
      end
      let(:error_message) do
        "#{options.fetch(:as, 'value')} is not an instance of #{expected} " \
          '(StandardError)'
      end

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of_anonymous'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of_anonymous'
      end

      describe 'with an instance of the class' do
        let(:value) { expected.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { Class.new(expected).new }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: false' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of'
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

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of'
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
    let(:expected)    { Spec::ExampleMatcher.new('expected') }
    let(:options)     { { expected: } }
    let(:matching)    { 'expected' }
    let(:nonmatching) { 'actual' }
    let(:error_message) do
      "#{options.fetch(:as, 'value')} does not match the expected value"
    end

    example_class 'Spec::ExampleMatcher', Struct.new(:value) do |klass|
      klass.define_method(:===) { |other| other == value }
    end

    def assert
      assertions.assert_matches(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:assert_matches)
        .with(1).argument
        .and_keywords(:as, :error_class, :expected, :message, :optional)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception with the failure message',
        scope: 'matches'
    end

    describe 'with a non-matching value' do
      let(:value) { nonmatching }

      include_examples 'should raise an exception with the failure message',
        scope: 'matches'
    end

    describe 'with a matching value' do
      let(:value) { matching }

      include_examples 'should not raise an exception'
    end

    describe 'with expected: a Class' do
      let(:error_message) do
        "#{options.fetch(:as, 'value')} is not an instance of StandardError"
      end
      let(:expected) { StandardError }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of'
      end

      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of'
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

    describe 'with expected: an anonymous Class' do
      let(:error_message) do
        "#{options.fetch(:as, 'value')} is not an instance of #{expected} " \
          '(StandardError)'
      end
      let(:message_options) do
        options.merge(parent: StandardError)
      end
      let(:expected) { Class.new(StandardError) }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of_anonymous'
      end

      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of_anonymous'
      end

      describe 'with an instance of the class' do
        let(:value) { expected.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { Class.new(expected).new }

        include_examples 'should not raise an exception'
      end
    end

    describe 'with expected: a Proc' do
      let(:expected) { ->(value) { value >= 0 } }
      let(:error_message) do
        "#{options.fetch(:as, 'value')} does not match the Proc"
      end

      describe 'with nil' do
        let(:value) { nil }

        it { expect { assert }.to raise_error NoMethodError }
      end

      describe 'with a non-matching value' do
        let(:value) { -1 }

        include_examples 'should raise an exception with the failure message',
          scope: 'matches_proc'
      end

      describe 'with a matching value' do
        let(:value) { 1 }

        include_examples 'should not raise an exception'
      end
    end

    describe 'with expected: a Regexp' do
      let(:expected) { /foo/ }
      let(:error_message) do
        "#{options.fetch(:as, 'value')} does not match the pattern " \
          "#{expected.inspect}"
      end
      let(:message_options) do
        options.merge(pattern: expected.inspect)
      end

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'matches_regexp'
      end

      describe 'with a non-matching value' do
        let(:value) { 'bar' }

        include_examples 'should raise an exception with the failure message',
          scope: 'matches_regexp'
      end

      describe 'with a matching value' do
        let(:value) { 'foo' }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with error_class: value' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'matches'
      end

      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception with the failure message',
          scope: 'matches'
      end

      describe 'with a matching value' do
        let(:value) { matching }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: false' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'matches'
      end

      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception with the failure message',
          scope: 'matches'
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

        include_examples 'should raise an exception with the failure message',
          scope: 'matches'
      end

      describe 'with a matching value' do
        let(:value) { matching }

        include_examples 'should not raise an exception'
      end
    end
  end

  describe '#assert_name' do
    let(:error_message) do
      "#{options.fetch(:as, 'value')} is not a String or a Symbol"
    end

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
      let(:value) { nil }
      let(:error_message) do
        "#{options.fetch(:as, 'value')} can't be blank"
      end

      include_examples 'should raise an exception with the failure message',
        scope: 'presence'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception with the failure message',
        scope: 'name'
    end

    describe 'with an empty String' do
      let(:value) { '' }
      let(:error_message) do
        "#{options.fetch(:as, 'value')} can't be blank"
      end

      include_examples 'should raise an exception with the failure message',
        scope: 'presence'
    end

    describe 'with an empty Symbol' do
      let(:value) { :'' }
      let(:error_message) do
        "#{options.fetch(:as, 'value')} can't be blank"
      end

      include_examples 'should raise an exception with the failure message',
        scope: 'presence'
    end

    describe 'with a String' do
      let(:value) { 'string' }

      include_examples 'should not raise an exception'
    end

    describe 'with a Symbol' do
      let(:value) { :symbol }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with error_class: value' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      describe 'with nil' do
        let(:value) { nil }
        let(:error_message) do
          "#{options.fetch(:as, 'value')} can't be blank"
        end

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception with the failure message',
          scope: 'name'
      end

      describe 'with an empty String' do
        let(:value) { '' }
        let(:error_message) do
          "#{options.fetch(:as, 'value')} can't be blank"
        end

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
      end

      describe 'with an empty Symbol' do
        let(:value) { :'' }
        let(:error_message) do
          "#{options.fetch(:as, 'value')} can't be blank"
        end

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
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

    wrap_context 'with optional: false' do # rubocop:disable RSpec/RepeatedExampleGroupBody
      describe 'with nil' do
        let(:value) { nil }
        let(:error_message) do
          "#{options.fetch(:as, 'value')} can't be blank"
        end

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception with the failure message',
          scope: 'name'
      end

      describe 'with an empty String' do
        let(:value) { '' }
        let(:error_message) do
          "#{options.fetch(:as, 'value')} can't be blank"
        end

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
      end

      describe 'with an empty Symbol' do
        let(:value) { :'' }
        let(:error_message) do
          "#{options.fetch(:as, 'value')} can't be blank"
        end

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
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

        include_examples 'should raise an exception with the failure message',
          scope: 'name'
      end

      describe 'with an empty String' do
        let(:value) { '' }
        let(:error_message) do
          "#{options.fetch(:as, 'value')} can't be blank"
        end

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
      end

      describe 'with an empty Symbol' do
        let(:value) { :'' }
        let(:error_message) do
          "#{options.fetch(:as, 'value')} can't be blank"
        end

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
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

  describe '#assert_nil' do
    let(:error_message) do
      "#{options.fetch(:as, 'value')} must be nil"
    end

    def assert
      assertions.assert_nil(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:assert_nil)
        .with(1).argument
        .and_keywords(:as, :error_class, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should not raise an exception'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception with the failure message',
        scope: 'nil'
    end

    wrap_context 'with error_class: value' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should not raise an exception'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception with the failure message',
          scope: 'nil'
      end
    end
  end

  describe '#assert_not_nil' do
    let(:error_message) do
      "#{options.fetch(:as, 'value')} must not be nil"
    end

    def assert
      assertions.assert_not_nil(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:assert_not_nil)
        .with(1).argument
        .and_keywords(:as, :error_class, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception with the failure message',
        scope: 'not_nil'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with error_class: value' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'not_nil'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should not raise an exception'
      end
    end
  end

  describe '#assert_presence' do
    let(:error_message) do
      "#{options.fetch(:as, 'value')} can't be blank"
    end

    def assert
      assertions.assert_presence(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:assert_presence)
        .with(1).argument
        .and_keywords(:as, :error_class, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception with the failure message',
        scope: 'presence'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should not raise an exception'
    end

    describe 'with an empty value' do
      let(:value) { Struct.new(:empty) { def empty? = empty }.new(true) }

      include_examples 'should raise an exception with the failure message',
        scope: 'presence'
    end

    describe 'with a non-empty value' do
      let(:value) { Struct.new(:empty) { def empty? = empty }.new(false) }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with error_class: value' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should not raise an exception'
      end

      describe 'with an empty value' do
        let(:value) { Struct.new(:empty) { def empty? = empty }.new(true) }

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
      end

      describe 'with a non-empty value' do
        let(:value) { Struct.new(:empty) { def empty? = empty }.new(false) }

        include_examples 'should not raise an exception'
      end
    end
  end

  describe '#error_message_for' do
    let(:scope)   { nil }
    let(:options) { {} }

    def error_message
      assertions.error_message_for(scope, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:error_message_for)
        .with(1).argument
        .and_any_keywords
    end

    describe 'with scope: an unknown String' do
      let(:scope)    { 'spec.custom.scope' }
      let(:expected) { 'Error message missing: spec.custom.scope' }

      it { expect(error_message).to be == expected }
    end

    describe 'with scope: an unknown Symbol' do
      let(:scope)    { :'spec.custom.scope' }
      let(:expected) { 'Error message missing: spec.custom.scope' }

      it { expect(error_message).to be == expected }
    end

    describe 'with scope: a valid String' do
      let(:scope)    { 'sleeping_king_studios.tools.assertions.blank' }
      let(:expected) { 'value must be nil or empty' }

      it { expect(error_message).to be == expected }

      describe 'with as: false' do
        let(:options)  { super().merge(as: false) }
        let(:expected) { 'must be nil or empty' }

        it { expect(error_message).to be == expected }
      end

      describe 'with as: value' do
        let(:options)  { super().merge(as: 'item') }
        let(:expected) { 'item must be nil or empty' }

        it { expect(error_message).to be == expected }
      end

      describe 'with options: Hash' do
        let(:scope)    { 'sleeping_king_studios.tools.assertions.instance_of' }
        let(:options)  { super().merge(expected: String) }
        let(:expected) { 'value is not an instance of String' }

        it { expect(error_message).to be == expected }
      end
    end

    describe 'with scope: a valid Symbol' do
      let(:scope)    { :'sleeping_king_studios.tools.assertions.blank' }
      let(:expected) { 'value must be nil or empty' }

      it { expect(error_message).to be == expected }

      describe 'with as: false' do
        let(:options)  { super().merge(as: false) }
        let(:expected) { 'must be nil or empty' }

        it { expect(error_message).to be == expected }
      end

      describe 'with as: value' do
        let(:options)  { super().merge(as: 'item') }
        let(:expected) { 'item must be nil or empty' }

        it { expect(error_message).to be == expected }
      end

      describe 'with options: Hash' do
        let(:scope)    { :'sleeping_king_studios.tools.assertions.instance_of' }
        let(:options)  { super().merge(expected: String) }
        let(:expected) { 'value is not an instance of String' }

        it { expect(error_message).to be == expected }
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

      include_examples 'should raise an exception with the failure message',
        as:    false,
        scope: 'block'
    end

    describe 'with a block that returns a truthy value' do
      let(:block) { -> { :ok } }

      include_examples 'should not raise an exception'
    end
  end

  describe '#validate_blank' do
    let(:error_class)   { ArgumentError }
    let(:error_message) do
      "#{options.fetch(:as, 'value')} must be nil or empty"
    end

    def assert
      assertions.validate_blank(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:validate_blank)
        .with(1).argument
        .and_keywords(:as, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should not raise an exception'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception with the failure message',
        scope: 'blank'
    end

    describe 'with an empty value' do
      let(:value) { Struct.new(:empty) { def empty? = empty }.new(true) }

      include_examples 'should not raise an exception'
    end

    describe 'with a non-empty value' do
      let(:value) { Struct.new(:empty) { def empty? = empty }.new(false) }

      include_examples 'should raise an exception with the failure message',
        scope: 'blank'
    end
  end

  describe '#validate_boolean' do
    let(:error_class)   { ArgumentError }
    let(:error_message) do
      "#{options.fetch(:as, 'value')} must be true or false"
    end

    def assert
      assertions.validate_boolean(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:validate_boolean)
        .with(1).argument
        .and_keywords(:as, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception with the failure message',
        scope: 'boolean'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception with the failure message',
        scope: 'boolean'
    end

    describe 'with false' do
      let(:value) { false }

      include_examples 'should not raise an exception'
    end

    describe 'with true' do
      let(:value) { true }

      include_examples 'should not raise an exception'
    end
  end

  describe '#validate_class' do
    let(:error_class)   { ArgumentError }
    let(:error_message) do
      "#{options.fetch(:as, 'value')} is not a Class"
    end

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

      include_examples 'should raise an exception with the failure message',
        scope: 'class'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception with the failure message',
        scope: 'class'
    end

    describe 'with a Module' do
      let(:value) { Module.new }

      include_examples 'should raise an exception with the failure message',
        scope: 'class'
    end

    describe 'with a Class' do
      let(:value) { Class.new }

      include_examples 'should not raise an exception'
    end
  end

  describe '#validate_group' do
    let(:error_class) { ArgumentError }
    let(:block)       { ->(_) {} }
    let(:options)     { {} }

    def assert
      assertions.validate_group(**options, &block)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:validate_group)
        .with(0).arguments
        .and_keywords(:message)
        .and_a_block
    end

    describe 'without a block' do
      let(:error_message) { 'no block given' }

      it 'should raise an exception' do
        expect { assertions.validate_group }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a block that raises an exception' do
      let(:label) { nil }
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_instance_of(label, as: 'label')
        end
      end
      let(:error_message) { 'missing keyword: :expected' }

      it 'should raise an exception' do
        expect { assertions.validate_group(&block) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a block with no assertions' do
      let(:block) { ->(_) {} }

      include_examples 'should not raise an exception'
    end

    describe 'with a block with a failing assertion' do
      let(:value)         { Object.new.freeze }
      let(:error_message) { 'value is not a String or a Symbol' }
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_name(value)
        end
      end

      include_examples 'should raise an exception'
    end

    describe 'with a block with a passing assertion' do
      let(:value) { 'ok' }
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_name(value)
        end
      end

      include_examples 'should not raise an exception'
    end

    describe 'with a block with many failing assertions' do
      let(:label) { nil }
      let(:value) { Object.new.freeze }
      let(:error_message) do
        'value is not a String or a Symbol, label is not an instance of ' \
          'String, something went wrong'
      end
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_name(value)
          aggregator.assert_instance_of(label, expected: String, as: 'label')
          aggregator.validate(message: 'something went wrong') { false }
        end
      end

      include_examples 'should raise an exception'
    end

    describe 'with a block with many passing assertions' do
      let(:label) { 'self-sealing stem bolts' }
      let(:value) { 'Quantity: 1,000' }
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_name(value)
          aggregator.assert_instance_of(label, expected: String, as: 'label')
          aggregator.validate(message: 'something went wrong') { true }
        end
      end

      include_examples 'should not raise an exception'
    end

    describe 'with a block with nested aggregations' do
      let(:quantity) { nil }
      let(:label)    { nil }
      let(:error_message) do
        "label is not an instance of String, label can't be blank, quantity " \
          'is not an instance of Integer'
      end
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_group do |inner|
            inner.assert_instance_of(label, expected: String, as: 'label')
            inner.assert_presence(label, as: 'label')
          end

          aggregator
            .assert_instance_of(quantity, expected: Integer, as: 'quantity')
        end
      end

      include_examples 'should raise an exception'
    end

    describe 'with a block with nested aggregations and message: value' do
      let(:quantity) { nil }
      let(:label)    { nil }
      let(:error_message) do
        'label is invalid, quantity is not an instance of Integer'
      end
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_group(message: 'label is invalid') do |inner|
            inner.assert_instance_of(label, expected: String, as: 'label')
            inner.assert_presence(label, as: 'label')
          end

          aggregator
            .assert_instance_of(quantity, expected: Integer, as: 'quantity')
        end
      end

      include_examples 'should raise an exception'
    end

    wrap_context 'with message: value' do
      describe 'with a block with no assertions' do
        let(:block) { ->(_) {} }

        include_examples 'should not raise an exception'
      end

      describe 'with a block with a failing assertion' do
        let(:value) { Object.new.freeze }
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_name(value)
          end
        end

        include_examples 'should raise an exception'
      end

      describe 'with a block with a passing assertion' do
        let(:value) { 'ok' }
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_name(value)
          end
        end

        include_examples 'should not raise an exception'
      end

      describe 'with a block with many failing assertions' do
        let(:label) { nil }
        let(:value) { Object.new.freeze }
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_name(value)
            aggregator.assert_instance_of(label, expected: String, as: 'label')
            aggregator.validate(message: 'something went wrong') { false }
          end
        end

        include_examples 'should raise an exception'
      end

      describe 'with a block with many passing assertions' do
        let(:label) { 'self-sealing stem bolts' }
        let(:value) { 'Quantity: 1,000' }
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_name(value)
            aggregator.assert_instance_of(label, expected: String, as: 'label')
            aggregator.validate(message: 'something went wrong') { true }
          end
        end

        include_examples 'should not raise an exception'
      end

      describe 'with a block with nested aggregations' do
        let(:quantity) { nil }
        let(:label)    { nil }
        let(:error_message) do
          "label is not an instance of String, label can't be blank, " \
            'quantity is not an instance of Integer'
        end
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_group do |inner|
              inner.assert_instance_of(label, expected: String, as: 'label')
              inner.assert_presence(label, as: 'label')
            end

            aggregator
              .assert_instance_of(quantity, expected: Integer, as: 'quantity')
          end
        end

        include_examples 'should raise an exception'
      end

      describe 'with a block with nested aggregations and message: value' do
        let(:quantity) { nil }
        let(:label)    { nil }
        let(:error_message) do
          'label is invalid, quantity is not an instance of Integer'
        end
        let(:block) do
          lambda do |aggregator|
            aggregator.assert_group(message: 'label is invalid') do |inner|
              inner.assert_instance_of(label, expected: String, as: 'label')
              inner.assert_presence(label, as: 'label')
            end

            aggregator
              .assert_instance_of(quantity, expected: Integer, as: 'quantity')
          end
        end

        include_examples 'should raise an exception'
      end
    end
  end

  describe '#validate_instance_of' do
    let(:expected)    { StandardError }
    let(:error_class) { ArgumentError }
    let(:options)     { { expected: } }
    let(:error_message) do
      "#{options.fetch(:as, 'value')} is not an instance of #{expected}"
    end

    def assert
      assertions.validate_instance_of(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:validate_instance_of)
        .with(1).argument
        .and_keywords(:as, :expected, :message, :optional)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception with the failure message',
        scope: 'instance_of'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception with the failure message',
        scope: 'instance_of'
    end

    describe 'with an instance of the class' do
      let(:value) { StandardError.new }

      include_examples 'should not raise an exception'
    end

    describe 'with an instance of a subclass of the class' do
      let(:value) { RuntimeError.new }

      include_examples 'should not raise an exception'
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
      let(:message_options) do
        options.merge(parent: StandardError)
      end
      let(:error_message) do
        "#{options.fetch(:as, 'value')} is not an instance of #{expected} " \
          '(StandardError)'
      end

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of_anonymous'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of_anonymous'
      end

      describe 'with an instance of the class' do
        let(:value) { expected.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { Class.new(expected).new }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: false' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of'
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

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of'
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
    let(:options)       { { expected: } }
    let(:error_class)   { ArgumentError }
    let(:error_message) do
      "#{options.fetch(:as, 'value')} does not match the expected value"
    end
    let(:matching)    { 'expected' }
    let(:nonmatching) { 'actual' }

    example_class 'Spec::ExampleMatcher', Struct.new(:value) do |klass|
      klass.define_method(:===) { |other| other == value }
    end

    def assert
      assertions.validate_matches(value, expected:, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:validate_matches)
        .with(1).argument
        .and_keywords(:as, :expected, :message, :optional)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception with the failure message',
        scope: 'matches'
    end

    describe 'with a non-matching value' do
      let(:value) { nonmatching }

      include_examples 'should raise an exception with the failure message',
        scope: 'matches'
    end

    describe 'with a matching value' do
      let(:value) { matching }

      include_examples 'should not raise an exception'
    end

    describe 'with expected: a Class' do
      let(:error_message) do
        "#{options.fetch(:as, 'value')} is not an instance of StandardError"
      end
      let(:expected) { StandardError }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of'
      end

      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of'
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

    describe 'with expected: an anonymous Class' do
      let(:error_message) do
        "#{options.fetch(:as, 'value')} is not an instance of #{expected} " \
          '(StandardError)'
      end
      let(:message_options) do
        options.merge(parent: StandardError)
      end
      let(:expected) { Class.new(StandardError) }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of_anonymous'
      end

      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception with the failure message',
          scope: 'instance_of_anonymous'
      end

      describe 'with an instance of the class' do
        let(:value) { expected.new }

        include_examples 'should not raise an exception'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { Class.new(expected).new }

        include_examples 'should not raise an exception'
      end
    end

    describe 'with expected: a Proc' do
      let(:expected) { ->(value) { value >= 0 } }
      let(:error_message) do
        "#{options.fetch(:as, 'value')} does not match the Proc"
      end

      describe 'with nil' do
        let(:value) { nil }

        it { expect { assert }.to raise_error NoMethodError }
      end

      describe 'with a non-matching value' do
        let(:value) { -1 }

        include_examples 'should raise an exception with the failure message',
          scope: 'matches_proc'
      end

      describe 'with a matching value' do
        let(:value) { 1 }

        include_examples 'should not raise an exception'
      end
    end

    describe 'with expected: a Regexp' do
      let(:expected) { /foo/ }
      let(:error_message) do
        "#{options.fetch(:as, 'value')} does not match the pattern " \
          "#{expected.inspect}"
      end
      let(:message_options) do
        options.merge(pattern: expected.inspect)
      end

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'matches_regexp'
      end

      describe 'with a non-matching value' do
        let(:value) { 'bar' }

        include_examples 'should raise an exception with the failure message',
          scope: 'matches_regexp'
      end

      describe 'with a matching value' do
        let(:value) { 'foo' }

        include_examples 'should not raise an exception'
      end
    end

    wrap_context 'with optional: false' do
      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should raise an exception with the failure message',
          scope: 'matches'
      end

      describe 'with a non-matching value' do
        let(:value) { nonmatching }

        include_examples 'should raise an exception with the failure message',
          scope: 'matches'
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

        include_examples 'should raise an exception with the failure message',
          scope: 'matches'
      end

      describe 'with a matching value' do
        let(:value) { matching }

        include_examples 'should not raise an exception'
      end
    end
  end

  describe '#validate_name' do
    let(:error_class) { ArgumentError }
    let(:error_message) do
      "#{options.fetch(:as, 'value')} is not a String or a Symbol"
    end

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
      let(:value) { nil }
      let(:error_message) do
        "#{options.fetch(:as, 'value')} can't be blank"
      end

      include_examples 'should raise an exception with the failure message',
        scope: 'presence'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception with the failure message',
        scope: 'name'
    end

    describe 'with an empty String' do
      let(:value) { '' }
      let(:error_message) do
        "#{options.fetch(:as, 'value')} can't be blank"
      end

      include_examples 'should raise an exception with the failure message',
        scope: 'presence'
    end

    describe 'with an empty Symbol' do
      let(:value) { :'' }
      let(:error_message) do
        "#{options.fetch(:as, 'value')} can't be blank"
      end

      include_examples 'should raise an exception with the failure message',
        scope: 'presence'
    end

    describe 'with a String' do
      let(:value) { 'string' }

      include_examples 'should not raise an exception'
    end

    describe 'with a Symbol' do
      let(:value) { :symbol }

      include_examples 'should not raise an exception'
    end

    wrap_context 'with optional: false' do
      describe 'with nil' do
        let(:value) { nil }
        let(:error_message) do
          "#{options.fetch(:as, 'value')} can't be blank"
        end

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should raise an exception with the failure message',
          scope: 'name'
      end

      describe 'with an empty String' do
        let(:value) { '' }
        let(:error_message) do
          "#{options.fetch(:as, 'value')} can't be blank"
        end

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
      end

      describe 'with an empty Symbol' do
        let(:value) { :'' }
        let(:error_message) do
          "#{options.fetch(:as, 'value')} can't be blank"
        end

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
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

        include_examples 'should raise an exception with the failure message',
          scope: 'name'
      end

      describe 'with an empty String' do
        let(:value) { '' }
        let(:error_message) do
          "#{options.fetch(:as, 'value')} can't be blank"
        end

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
      end

      describe 'with an empty Symbol' do
        let(:value) { :'' }
        let(:error_message) do
          "#{options.fetch(:as, 'value')} can't be blank"
        end

        include_examples 'should raise an exception with the failure message',
          scope: 'presence'
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

  describe '#validate_nil' do
    let(:error_class) { ArgumentError }
    let(:error_message) do
      "#{options.fetch(:as, 'value')} must be nil"
    end

    def assert
      assertions.validate_nil(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:validate_nil)
        .with(1).argument
        .and_keywords(:as, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should not raise an exception'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should raise an exception with the failure message',
        scope: 'nil'
    end
  end

  describe '#validate_not_nil' do
    let(:error_class) { ArgumentError }
    let(:error_message) do
      "#{options.fetch(:as, 'value')} must not be nil"
    end

    def assert
      assertions.validate_not_nil(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:validate_not_nil)
        .with(1).argument
        .and_keywords(:as, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception with the failure message',
        scope: 'not_nil'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should not raise an exception'
    end
  end

  describe '#validate_presence' do
    let(:error_class) { ArgumentError }
    let(:error_message) do
      "#{options.fetch(:as, 'value')} can't be blank"
    end

    def assert
      assertions.validate_presence(value, **options)
    end

    it 'should define the method' do
      expect(assertions)
        .to respond_to(:validate_presence)
        .with(1).argument
        .and_keywords(:as, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should raise an exception with the failure message',
        scope: 'presence'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should not raise an exception'
    end

    describe 'with an empty value' do
      let(:value) { Struct.new(:empty) { def empty? = empty }.new(true) }

      include_examples 'should raise an exception with the failure message',
        scope: 'presence'
    end

    describe 'with a non-empty value' do
      let(:value) { Struct.new(:empty) { def empty? = empty }.new(false) }

      include_examples 'should not raise an exception'
    end
  end
end
