# frozen_string_literal: true

require 'sleeping_king_studios/tools/assertions/aggregator'

require 'support/deferred/assertions_examples'

RSpec.describe SleepingKingStudios::Tools::Assertions::Aggregator do
  include Spec::Support::Deferred::AssertionsExamples

  subject(:aggregator) { described_class.new }

  shared_context 'when the aggregator has many failures' do
    before(:example) do
      aggregator.assert_boolean(nil)

      aggregator.validate_presence('', as: 'name')

      aggregator.assert(error_class: StandardError) { false }
    end
  end

  deferred_examples 'should fail the assertion' do |**deferred_options|
    let(:message_options) do
      hsh = defined?(super()) ? super() : options
      hsh = hsh.merge(as: false) if deferred_options.fetch(:skip_as, false)
      hsh
    end
    let(:configured_messages) do
      next expected_message.split(', ') if defined?(expected_message)

      scope = "sleeping_king_studios.tools.assertions.#{error_key}"

      [aggregator.error_message_for(scope, **message_options)]
    end

    it 'should append a failure message', :aggregate_failures do
      expect { assert }
        .to change(aggregator, :count)
        .by(configured_messages.size)

      expect(aggregator.each.to_a.last(configured_messages.size))
        .to be == configured_messages
    end

    unless deferred_options.fetch(:skip_as, false)
      describe 'with as: value' do
        let(:options) { super().merge(as: 'custom name') }

        it 'should append a failure message', :aggregate_failures do
          expect { assert }
            .to change(aggregator, :count)
            .by(configured_messages.size)

          expect(aggregator.each.to_a.last(configured_messages.size))
            .to be == configured_messages
        end
      end
    end

    describe 'with message: value' do
      let(:options) { super().merge(message: 'something went wrong') }

      it 'should append a failure message', :aggregate_failures do
        expect { assert }
          .to change(aggregator, :count)
          .by(1)

        expect(aggregator.each.to_a.last).to be == options[:message]
      end
    end

    wrap_context 'when the aggregator has many failures' do
      it 'should append a failure message', :aggregate_failures do
        expect { assert }
          .to change(aggregator, :count)
          .by(configured_messages.size)

        expect(aggregator.each.to_a.last(configured_messages.size))
          .to be == configured_messages
      end
    end
  end

  deferred_examples 'should pass the assertion' do
    it { expect { assert }.not_to change(aggregator, :count) }

    wrap_context 'when the aggregator has many failures' do
      it { expect { assert }.not_to change(aggregator, :count) }
    end
  end

  let(:options) { {} }

  include_deferred 'should define the assertion methods',
    error_class: false

  include_deferred 'should define the assertion methods',
    error_class: false,
    prefix:      :validate

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

  describe '#assert_group' do
    it 'should alias the method' do
      expect(aggregator).to have_aliased_method(:assert_group).as(:aggregate)
    end
  end

  describe '#assert_inherits_from' do
    it 'should alias the method' do
      expect(aggregator)
        .to have_aliased_method(:assert_inherits_from)
        .as(:assert_subclass)
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

  describe '#validate_inherits_from' do
    it 'should alias the method' do
      expect(aggregator)
        .to have_aliased_method(:validate_inherits_from)
        .as(:validate_subclass)
    end
  end
end
