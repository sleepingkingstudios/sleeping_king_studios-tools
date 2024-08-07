# frozen_string_literal: true

require 'sleeping_king_studios/tools/assertions'

RSpec.describe SleepingKingStudios::Tools::Assertions::Aggregator do
  subject(:aggregator) { described_class.new }

  shared_context 'when the aggregator has many failures' do
    before(:example) do
      aggregator.assert_boolean(nil)

      aggregator.validate_presence('', as: 'name')

      aggregator.assert(error_class: StandardError) { false }
    end
  end

  shared_examples 'should not append a failure message' do
    it { expect { call_assertion }.not_to change(aggregator, :count) }

    wrap_context 'when the aggregator has many failures' do
      it { expect { call_assertion }.not_to change(aggregator, :count) }
    end
  end

  shared_examples 'should append a failure message' do |**example_options|
    let(:message_options) do
      hsh = defined?(super()) ? super() : options
      hsh = hsh.merge(as: false) unless example_options.fetch(:as, true)
      hsh
    end
    let(:generated_message) do
      scope =
        "sleeping_king_studios.tools.assertions.#{example_options[:scope]}"

      aggregator.error_message_for(scope, **message_options)
    end

    it 'should append a failure message', :aggregate_failures do
      expect { call_assertion }
        .to change(aggregator, :count)
        .by(1)

      expect(aggregator.each.to_a.last).to be == expected_message
    end

    it 'should match the generated error message' do
      call_assertion

      expect(aggregator.each.to_a.last).to be == generated_message
    end

    if example_options.fetch(:as, true)
      describe 'with as: value' do
        let(:options) { super().merge(as: 'custom name') }

        it 'should append a failure message', :aggregate_failures do
          expect { call_assertion }
            .to change(aggregator, :count)
            .by(1)

          expect(aggregator.each.to_a.last).to be == expected_message
        end
      end
    end

    describe 'with message: value' do
      let(:options) { super().merge(message: 'something went wrong') }

      it 'should append a failure message', :aggregate_failures do
        expect { call_assertion }
          .to change(aggregator, :count)
          .by(1)

        expect(aggregator.each.to_a.last).to be == options[:message]
      end
    end

    wrap_context 'when the aggregator has many failures' do
      it 'should append a failure message', :aggregate_failures do
        expect { call_assertion }
          .to change(aggregator, :count)
          .by(1)

        expect(aggregator.each.to_a.last).to be == expected_message
      end
    end
  end

  shared_examples 'should append multiple failure messages' do
    it 'should append the failure messages', :aggregate_failures do
      expect { call_assertion }
        .to change(aggregator, :count)
        .by(expected_messages.count)

      expect(aggregator.each.to_a).to be == expected_messages
    end

    describe 'with message: value' do
      let(:options) { super().merge(message: 'something went wrong') }

      it 'should append a failure message', :aggregate_failures do
        expect { call_assertion }
          .to change(aggregator, :count)
          .by(1)

        expect(aggregator.each.to_a.last).to be == options[:message]
      end
    end

    wrap_context 'when the aggregator has many failures' do
      it 'should append the failure messages', :aggregate_failures do
        expect { call_assertion }
          .to change(aggregator, :count)
          .by(expected_messages.count)

        expect(aggregator.each.to_a[-expected_messages.count...])
          .to be == expected_messages
      end
    end
  end

  describe '#<<' do
    let(:message) { 'something went wrong' }

    it { expect(aggregator).to respond_to(:<<).with(1).argument }

    it 'should append the message', :aggregate_failures do
      expect { aggregator << message }
        .to change(aggregator, :count)
        .by(1)

      expect(aggregator.each.to_a.last).to be == message
    end

    wrap_context 'when the aggregator has many failures' do
      it 'should append the message', :aggregate_failures do
        expect { aggregator << message }
          .to change(aggregator, :count)
          .by(1)

        expect(aggregator.each.to_a.last).to be == message
      end
    end
  end

  describe '#assert' do
    let(:block)   { -> {} }
    let(:options) { {} }

    def call_assertion
      aggregator.assert(**options, &block)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:assert)
        .with(0).arguments
        .and_keywords(:error_class, :message)
        .and_a_block
    end

    describe 'with a block that returns a falsy value' do
      let(:block) { -> {} }
      let(:expected_message) do
        'block returned a falsy value'
      end

      include_examples 'should append a failure message',
        as:    false,
        scope: 'block'
    end

    describe 'with a block that returns a truthy value' do
      let(:block) { -> { :ok } }

      include_examples 'should not append a failure message'
    end
  end

  describe '#assert_blank' do
    let(:value)   { nil }
    let(:options) { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} must be nil or empty"
    end

    def call_assertion
      aggregator.assert_blank(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:assert_blank)
        .with(1).arguments
        .and_keywords(:as, :error_class, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should not append a failure message'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should append a failure message', scope: 'blank'
    end

    describe 'with an empty value' do
      let(:value) { {} }

      include_examples 'should not append a failure message'
    end

    describe 'with a non-empty value' do
      let(:value) { { ok: true } }

      include_examples 'should append a failure message', scope: 'blank'
    end
  end

  describe '#assert_boolean' do
    let(:value)   { nil }
    let(:options) { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} must be true or false"
    end

    def call_assertion
      aggregator.assert_boolean(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:assert_boolean)
        .with(1).arguments
        .and_keywords(:as, :error_class, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should append a failure message', scope: 'boolean'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should append a failure message', scope: 'boolean'
    end

    describe 'with false' do
      let(:value) { false }

      include_examples 'should not append a failure message'
    end

    describe 'with true' do
      let(:value) { true }

      include_examples 'should not append a failure message'
    end
  end

  describe '#assert_class' do
    let(:value)   { nil }
    let(:options) { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} is not a Class"
    end

    def call_assertion
      aggregator.assert_class(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:assert_class)
        .with(1).arguments
        .and_keywords(:as, :error_class, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should append a failure message', scope: 'class'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should append a failure message', scope: 'class'
    end

    describe 'with a Module' do
      let(:value) { Module.new }

      include_examples 'should append a failure message', scope: 'class'
    end

    describe 'with a Class' do
      let(:value) { Class.new }

      include_examples 'should not append a failure message'
    end
  end

  describe '#assert_group' do
    let(:block)   { ->(_) {} }
    let(:options) { {} }

    def call_assertion
      aggregator.assert_group(**options, &block)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:assert_group)
        .with(0).arguments
        .and_keywords(:error_class, :message)
        .and_a_block
    end

    it 'should alias the method' do
      expect(aggregator).to have_aliased_method(:assert_group).as(:aggregate)
    end

    describe 'without a block' do
      let(:error_message) { 'no block given' }

      it 'should raise an exception' do
        expect { aggregator.assert_group }
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
        expect { aggregator.assert_group(&block) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a block with no assertions' do
      let(:block) { ->(_) {} }

      include_examples 'should not append a failure message'
    end

    describe 'with a block with a failing assertion' do
      let(:value) { Object.new.freeze }
      let(:expected_messages) do
        ['value is not a String or a Symbol']
      end
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_name(value)
        end
      end

      include_examples 'should append multiple failure messages'
    end

    describe 'with a block with a passing assertion' do
      let(:value) { 'ok' }
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_name(value)
        end
      end

      include_examples 'should not append a failure message'
    end

    describe 'with a block with many failing assertions' do
      let(:label) { nil }
      let(:value) { Object.new.freeze }
      let(:expected_messages) do
        [
          'value is not a String or a Symbol',
          'label is not an instance of String',
          'something went wrong'
        ]
      end
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_name(value)
          aggregator.assert_instance_of(label, expected: String, as: 'label')
          aggregator.validate(message: 'something went wrong') { false }
        end
      end

      include_examples 'should append multiple failure messages'
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

      include_examples 'should not append a failure message'
    end

    describe 'with a block with nested aggregations' do
      let(:quantity) { nil }
      let(:label)    { nil }
      let(:expected_messages) do
        [
          'label is not an instance of String',
          "label can't be blank",
          'quantity is not an instance of Integer'
        ]
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

      include_examples 'should append multiple failure messages'
    end

    describe 'with a block with nested aggregations and message: value' do
      let(:quantity) { nil }
      let(:label)    { nil }
      let(:expected_messages) do
        [
          'label is invalid',
          'quantity is not an instance of Integer'
        ]
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

      include_examples 'should append multiple failure messages'
    end

    describe 'with message: value' do
      let(:message) { 'something went wrong' }

      describe 'without a block' do
        let(:error_message) { 'no block given' }

        it 'should raise an exception' do
          expect { aggregator.assert_group(message:) }
            .to raise_error ArgumentError, error_message
        end
      end
    end
  end

  describe '#assert_instance_of' do
    let(:value)    { nil }
    let(:expected) { StandardError }
    let(:options)  { { expected: } }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} is not an instance of #{expected}"
    end

    def call_assertion
      aggregator.assert_instance_of(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:assert_instance_of)
        .with(1).arguments
        .and_keywords(:as, :error_class, :expected, :message, :optional)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should append a failure message', scope: 'instance_of'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should append a failure message', scope: 'instance_of'
    end

    describe 'with an instance of the class' do
      let(:value) { StandardError.new }

      include_examples 'should not append a failure message'
    end

    describe 'with an instance of a subclass of the class' do
      let(:value) { RuntimeError.new }

      include_examples 'should not append a failure message'
    end

    describe 'with optional: true' do
      let(:options) { super().merge(optional: true) }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should not append a failure message'
      end
    end
  end

  describe '#assert_matches' do
    let(:value)    { nil }
    let(:expected) { Spec::ExampleMatcher.new('expected') }
    let(:options)  { { expected: } }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} does not match the expected value"
    end

    example_class 'Spec::ExampleMatcher', Struct.new(:value) do |klass|
      klass.define_method(:===) { |other| other == value }
    end

    def call_assertion
      aggregator.assert_matches(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:assert_matches)
        .with(1).arguments
        .and_keywords(:as, :error_class, :expected, :message, :optional)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should append a failure message', scope: 'matches'
    end

    describe 'with a non-matching value' do
      let(:value) { 'actual' }

      include_examples 'should append a failure message', scope: 'matches'
    end

    describe 'with a matching value' do
      let(:value) { 'expected' }

      include_examples 'should not append a failure message'
    end

    describe 'with optional: true' do
      let(:options) { super().merge(optional: true) }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should not append a failure message'
      end
    end
  end

  describe '#assert_name' do
    let(:value)   { nil }
    let(:options) { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} can't be blank"
    end

    def call_assertion
      aggregator.assert_name(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:assert_name)
        .with(1).arguments
        .and_keywords(:as, :error_class, :message, :optional)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should append a failure message', scope: 'presence'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }
      let(:expected_message) do
        "#{options.fetch(:as, 'value')} is not a String or a Symbol"
      end

      include_examples 'should append a failure message', scope: 'name'
    end

    describe 'with an empty String' do
      let(:value) { '' }

      include_examples 'should append a failure message', scope: 'presence'
    end

    describe 'with an empty Symbol' do
      let(:value) { :'' }

      include_examples 'should append a failure message', scope: 'presence'
    end

    describe 'with a non-empty String' do
      let(:value) { 'ok' }

      include_examples 'should not append a failure message'
    end

    describe 'with a non-empty Symbol' do
      let(:value) { :ok }

      include_examples 'should not append a failure message'
    end

    describe 'with optional: true' do
      let(:options) { super().merge(optional: true) }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should not append a failure message'
      end
    end
  end

  describe '#assert_nil' do
    let(:value)   { nil }
    let(:options) { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} must be nil"
    end

    def call_assertion
      aggregator.assert_nil(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:assert_nil)
        .with(1).arguments
        .and_keywords(:as, :error_class, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should not append a failure message'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should append a failure message', scope: 'nil'
    end
  end

  describe '#assert_not_nil' do
    let(:value)   { nil }
    let(:options) { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} must not be nil"
    end

    def call_assertion
      aggregator.assert_not_nil(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:assert_not_nil)
        .with(1).arguments
        .and_keywords(:as, :error_class, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should append a failure message', scope: 'not_nil'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should not append a failure message'
    end
  end

  describe '#assert_presence' do
    let(:value)   { nil }
    let(:options) { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} can't be blank"
    end

    def call_assertion
      aggregator.assert_presence(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:assert_presence)
        .with(1).arguments
        .and_keywords(:as, :error_class, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should append a failure message', scope: 'presence'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should not append a failure message'
    end

    describe 'with an empty value' do
      let(:value) { {} }

      include_examples 'should append a failure message', scope: 'presence'
    end

    describe 'with a non-empty value' do
      let(:value) { { ok: true } }

      include_examples 'should not append a failure message'
    end
  end

  describe '#clear' do
    it { expect(aggregator).to respond_to(:clear).with(0).arguments }

    it { expect { aggregator.clear }.not_to change(aggregator, :count) }

    wrap_context 'when the aggregator has many failures' do
      it { expect { aggregator.clear }.to change(aggregator, :count).to be 0 }
    end
  end

  describe '#count' do
    include_examples 'should define reader', :count, 0

    wrap_context 'when the aggregator has many failures' do
      it { expect(aggregator.count).to be 3 }
    end
  end

  describe '#each' do
    it { expect(aggregator).to respond_to(:each).with(0).arguments }

    it { expect(aggregator.each).to be_a Enumerator }

    it { expect(aggregator.each.to_a).to be == [] }

    it { expect { |block| aggregator.each(&block) }.not_to yield_control }

    wrap_context 'when the aggregator has many failures' do
      let(:expected) do
        [
          'value must be true or false',
          "name can't be blank",
          'block returned a falsy value'
        ]
      end

      it { expect(aggregator.each.to_a).to be == expected }

      it 'should yield the failure messages' do
        expect { |block| aggregator.each(&block) }
          .to yield_successive_args(*expected)
      end
    end
  end

  describe '#empty?' do
    include_examples 'should define predicate', :empty?, true

    wrap_context 'when the aggregator has many failures' do
      it { expect(aggregator.empty?).to be false }
    end
  end

  describe '#failure_message' do
    include_examples 'should define reader', :failure_message, ''

    wrap_context 'when the aggregator has many failures' do
      let(:expected) do
        "value must be true or false, name can't be blank, block returned a " \
          'falsy value'
      end

      it { expect(aggregator.failure_message).to be == expected }
    end
  end

  describe '#size' do
    include_examples 'should define reader', :size, 0

    wrap_context 'when the aggregator has many failures' do
      it { expect(aggregator.size).to be 3 }
    end
  end

  describe '#validate' do
    let(:block)   { -> {} }
    let(:options) { {} }

    def call_assertion
      aggregator.validate(**options, &block)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:validate)
        .with(0).arguments
        .and_keywords(:message)
        .and_a_block
    end

    describe 'with a block that returns a falsy value' do
      let(:block) { -> {} }
      let(:expected_message) do
        'block returned a falsy value'
      end

      include_examples 'should append a failure message',
        as:    false,
        scope: 'block'
    end

    describe 'with a block that returns a truthy value' do
      let(:block) { -> { :ok } }

      include_examples 'should not append a failure message'
    end
  end

  describe '#validate_blank' do
    let(:value)   { nil }
    let(:options) { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} must be nil or empty"
    end

    def call_assertion
      aggregator.validate_blank(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:validate_blank)
        .with(1).arguments
        .and_keywords(:as, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should not append a failure message'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should append a failure message', scope: 'blank'
    end

    describe 'with an empty value' do
      let(:value) { {} }

      include_examples 'should not append a failure message'
    end

    describe 'with a non-empty value' do
      let(:value) { { ok: true } }

      include_examples 'should append a failure message', scope: 'blank'
    end
  end

  describe '#validate_boolean' do
    let(:value)   { nil }
    let(:options) { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} must be true or false"
    end

    def call_assertion
      aggregator.validate_boolean(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:validate_boolean)
        .with(1).arguments
        .and_keywords(:as, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should append a failure message', scope: 'boolean'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should append a failure message', scope: 'boolean'
    end

    describe 'with false' do
      let(:value) { false }

      include_examples 'should not append a failure message'
    end

    describe 'with true' do
      let(:value) { true }

      include_examples 'should not append a failure message'
    end
  end

  describe '#validate_class' do
    let(:value)   { nil }
    let(:options) { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} is not a Class"
    end

    def call_assertion
      aggregator.validate_class(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:validate_class)
        .with(1).arguments
        .and_keywords(:as, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should append a failure message', scope: 'class'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should append a failure message', scope: 'class'
    end

    describe 'with a Module' do
      let(:value) { Module.new }

      include_examples 'should append a failure message', scope: 'class'
    end

    describe 'with a Class' do
      let(:value) { Class.new }

      include_examples 'should not append a failure message'
    end
  end

  describe '#validate_group' do
    let(:block)   { ->(_) {} }
    let(:options) { {} }

    def call_assertion
      aggregator.validate_group(**options, &block)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:validate_group)
        .with(0).arguments
        .and_keywords(:message)
        .and_a_block
    end

    describe 'without a block' do
      let(:error_message) { 'no block given' }

      it 'should raise an exception' do
        expect { aggregator.validate_group }
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
        expect { aggregator.validate_group(&block) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a block with no assertions' do
      let(:block) { ->(_) {} }

      include_examples 'should not append a failure message'
    end

    describe 'with a block with a failing assertion' do
      let(:value) { Object.new.freeze }
      let(:expected_messages) do
        ['value is not a String or a Symbol']
      end
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_name(value)
        end
      end

      include_examples 'should append multiple failure messages'
    end

    describe 'with a block with a passing assertion' do
      let(:value) { 'ok' }
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_name(value)
        end
      end

      include_examples 'should not append a failure message'
    end

    describe 'with a block with many failing assertions' do
      let(:label) { nil }
      let(:value) { Object.new.freeze }
      let(:expected_messages) do
        [
          'value is not a String or a Symbol',
          'label is not an instance of String',
          'something went wrong'
        ]
      end
      let(:block) do
        lambda do |aggregator|
          aggregator.assert_name(value)
          aggregator.assert_instance_of(label, expected: String, as: 'label')
          aggregator.validate(message: 'something went wrong') { false }
        end
      end

      include_examples 'should append multiple failure messages'
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

      include_examples 'should not append a failure message'
    end

    describe 'with a block with nested aggregations' do
      let(:quantity) { nil }
      let(:label)    { nil }
      let(:expected_messages) do
        [
          'label is not an instance of String',
          "label can't be blank",
          'quantity is not an instance of Integer'
        ]
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

      include_examples 'should append multiple failure messages'
    end

    describe 'with a block with nested aggregations and message: value' do
      let(:quantity) { nil }
      let(:label)    { nil }
      let(:expected_messages) do
        [
          'label is invalid',
          'quantity is not an instance of Integer'
        ]
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

      include_examples 'should append multiple failure messages'
    end

    describe 'with message: value' do
      let(:message) { 'something went wrong' }

      describe 'without a block' do
        let(:error_message) { 'no block given' }

        it 'should raise an exception' do
          expect { aggregator.validate_group(message:) }
            .to raise_error ArgumentError, error_message
        end
      end
    end
  end

  describe '#validate_instance_of' do
    let(:value)    { nil }
    let(:expected) { StandardError }
    let(:options)  { { expected: } }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} is not an instance of #{expected}"
    end

    def call_assertion
      aggregator.validate_instance_of(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:validate_instance_of)
        .with(1).arguments
        .and_keywords(:as, :expected, :message, :optional)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should append a failure message', scope: 'instance_of'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should append a failure message', scope: 'instance_of'
    end

    describe 'with an instance of the class' do
      let(:value) { StandardError.new }

      include_examples 'should not append a failure message'
    end

    describe 'with an instance of a subclass of the class' do
      let(:value) { RuntimeError.new }

      include_examples 'should not append a failure message'
    end

    describe 'with expected: nil' do
      it 'should raise an exception' do
        expect { aggregator.assert_instance_of(nil, expected: nil) }
          .to raise_error ArgumentError, 'expected must be a Class'
      end
    end

    describe 'with expected: an Object' do
      it 'should raise an exception' do
        expect do
          aggregator.assert_instance_of(nil, expected: Object.new.freeze)
        end
          .to raise_error ArgumentError, 'expected must be a Class'
      end
    end

    describe 'with expected: an anonymous subclass' do
      let(:expected) { Class.new(StandardError) }
      let(:message_options) do
        options.merge(parent: StandardError)
      end
      let(:expected_message) do
        "#{options.fetch(:as, 'value')} is not an instance of #{expected} " \
          '(StandardError)'
      end

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should append a failure message',
          scope: 'instance_of_anonymous'
      end

      describe 'with an Object' do
        let(:value) { Object.new.freeze }

        include_examples 'should append a failure message',
          scope: 'instance_of_anonymous'
      end

      describe 'with an instance of the class' do
        let(:value) { expected.new }

        include_examples 'should not append a failure message'
      end

      describe 'with an instance of a subclass of the class' do
        let(:value) { Class.new(expected).new }

        include_examples 'should not append a failure message'
      end
    end

    describe 'with optional: true' do
      let(:options) { super().merge(optional: true) }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should not append a failure message'
      end
    end
  end

  describe '#validate_matches' do
    let(:value)    { nil }
    let(:expected) { Spec::ExampleMatcher.new('expected') }
    let(:options)  { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} does not match the expected value"
    end

    example_class 'Spec::ExampleMatcher', Struct.new(:value) do |klass|
      klass.define_method(:===) { |other| other == value }
    end

    def call_assertion
      aggregator.validate_matches(value, expected:, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:validate_matches)
        .with(1).arguments
        .and_keywords(:as, :expected, :message, :optional)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should append a failure message', scope: 'matches'
    end

    describe 'with a non-matching value' do
      let(:value) { 'actual' }

      include_examples 'should append a failure message', scope: 'matches'
    end

    describe 'with a matching value' do
      let(:value) { 'expected' }

      include_examples 'should not append a failure message'
    end

    describe 'with optional: true' do
      let(:options) { super().merge(optional: true) }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should not append a failure message'
      end
    end
  end

  describe '#validate_name' do
    let(:value)   { nil }
    let(:options) { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} can't be blank"
    end

    def call_assertion
      aggregator.validate_name(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:validate_name)
        .with(1).arguments
        .and_keywords(:as, :message, :optional)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should append a failure message', scope: 'presence'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }
      let(:expected_message) do
        "#{options.fetch(:as, 'value')} is not a String or a Symbol"
      end

      include_examples 'should append a failure message', scope: 'name'
    end

    describe 'with an empty String' do
      let(:value) { '' }

      include_examples 'should append a failure message', scope: 'presence'
    end

    describe 'with an empty Symbol' do
      let(:value) { :'' }

      include_examples 'should append a failure message', scope: 'presence'
    end

    describe 'with a non-empty String' do
      let(:value) { 'ok' }

      include_examples 'should not append a failure message'
    end

    describe 'with a non-empty Symbol' do
      let(:value) { :ok }

      include_examples 'should not append a failure message'
    end

    describe 'with optional: true' do
      let(:options) { super().merge(optional: true) }

      describe 'with nil' do
        let(:value) { nil }

        include_examples 'should not append a failure message'
      end
    end
  end

  describe '#validate_nil' do
    let(:value)   { nil }
    let(:options) { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} must be nil"
    end

    def call_assertion
      aggregator.validate_nil(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:validate_nil)
        .with(1).arguments
        .and_keywords(:as, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should not append a failure message'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should append a failure message', scope: 'nil'
    end
  end

  describe '#validate_not_nil' do
    let(:value)   { nil }
    let(:options) { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} must not be nil"
    end

    def call_assertion
      aggregator.validate_not_nil(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:validate_not_nil)
        .with(1).arguments
        .and_keywords(:as, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should append a failure message', scope: 'not_nil'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should not append a failure message'
    end
  end

  describe '#validate_presence' do
    let(:value)   { nil }
    let(:options) { {} }
    let(:expected_message) do
      "#{options.fetch(:as, 'value')} can't be blank"
    end

    def call_assertion
      aggregator.validate_presence(value, **options)
    end

    it 'should define the method' do
      expect(aggregator)
        .to respond_to(:validate_presence)
        .with(1).arguments
        .and_keywords(:as, :message)
    end

    describe 'with nil' do
      let(:value) { nil }

      include_examples 'should append a failure message', scope: 'presence'
    end

    describe 'with an Object' do
      let(:value) { Object.new.freeze }

      include_examples 'should not append a failure message'
    end

    describe 'with an empty value' do
      let(:value) { {} }

      include_examples 'should append a failure message', scope: 'presence'
    end

    describe 'with a non-empty value' do
      let(:value) { { ok: true } }

      include_examples 'should not append a failure message'
    end
  end
end
