# frozen_string_literal: true

require 'sleeping_king_studios/tools/assertions/parameters_expectation'

RSpec.describe SleepingKingStudios::Tools::Assertions::ParametersExpectation do
  subject(:expectation) { described_class.new(assertions:, **options) }

  deferred_examples 'should validate the parameters' do
    let(:failures) { [] }

    describe 'with a method with no parameters' do
      let(:actual) { -> {} }

      include_deferred 'should match the parameters'
    end

    describe 'with a method with required arguments' do
      let(:actual) { ->(tag) {} }
      let(:failures) do
        assertions.error_message_for(
          'parameters.too_many_required_arguments',
          expected: 0,
          actual:   1
        )
      end

      include_deferred 'should not match the parameters'
    end

    pending
  end

  let(:assertions) do
    SleepingKingStudios::Tools::Assertions.new
  end
  let(:options) { {} }

  describe '.members' do
    let(:expected) do
      %i[
        assertions
        block
        optional_arguments
        optional_keywords
        required_arguments
        required_keywords
        variadic_arguments
        variadic_keywords
      ]
    end

    it { expect(described_class.members).to eq(expected) }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:assertions, :arguments, :keywords)
    end
  end

  describe '#assertions' do
    include_examples 'should define reader', :assertions, -> { assertions }
  end

  describe '#block' do
    include_examples 'should define reader', :block, false

    it { expect(expectation).to have_aliased_method(:block).as(:block?) }

    context 'when initialized with block: false' do
      let(:options) { super().merge(block: false) }

      it { expect(expectation.block).to be false }
    end

    context 'when initialized with block: true' do
      let(:options) { super().merge(block: true) }

      it { expect(expectation.block).to be true }
    end
  end

  describe '#call' do
    deferred_examples 'should not match the parameters' do
      describe 'should raise an AssertionError' do
        let(:error_message) do
          assertions.error_message_for(
            "#{error_prefix}.too_many_required_arguments",
            as: false,
            actual:   1,
            expected: 0
          )
        end

        specify do
          expect { expectation.call(actual) }.to raise_error(
            SleepingKingStudios::Tools::Assertions::AssertionError,
            error_message
          )
        end
      end
    end

    deferred_examples 'should match the parameters' do
      it 'should not raise an exception' do
        expect { expectation.call(actual) }.not_to raise_error
      end
    end

    let(:error_prefix) { 'sleeping_king_studios.tools.assertions.parameters' }

    it { expect(expectation).to respond_to(:call).with(1).argument }

    include_deferred 'should validate the parameters'
  end

  describe '#matches?' do
    deferred_examples 'should not match the parameters' do
      it { expect(expectation.matches?(actual)).to be false }
    end

    deferred_examples 'should match the parameters' do
      it { expect(expectation.matches?(actual)).to be true }
    end

    it { expect(expectation).to respond_to(:matches?).with(1).argument }

    it { expect(expectation).to have_aliased_method(:matches?).as(:match?) }

    include_deferred 'should validate the parameters'
  end

  describe '#optional_arguments' do
    include_examples 'should define reader', :optional_arguments, 0

    context 'when initialized with arguments: an Integer' do
      let(:options) { super().merge(arguments: 5) }

      it { expect(expectation.optional_arguments).to be 0 }

      context 'and optional_arguments: value' do
        let(:options) { super().merge(optional_arguments: 1) }

        it { expect(expectation.optional_arguments).to be 1 }
      end
    end

    context 'when initialized with arguments: a Range' do
      let(:options) { super().merge(arguments: 3..5) }

      it { expect(expectation.optional_arguments).to be 2 }

      context 'and optional_arguments: value' do
        let(:options) { super().merge(optional_arguments: 1) }

        it { expect(expectation.optional_arguments).to be 1 }
      end
    end

    context 'when initialized with optional_arguments: value' do
      let(:options) { super().merge(optional_arguments: 2) }

      it { expect(expectation.optional_arguments).to be 2 }
    end
  end

  describe '#optional_keywords' do
    include_examples 'should define reader', :optional_keywords, false

    context 'when initialized with keywords: an Array of Strings' do
      let(:options) { super().merge(keywords: %w[margin padding]) }

      it { expect(expectation.optional_keywords).to eq(%i[margin padding]) }

      context 'and with optional_keywords: value' do
        let(:options) { super().merge(optional_keywords: %w[shape color]) }

        it { expect(expectation.optional_keywords).to eq(%i[shape color]) }
      end
    end

    context 'when initialized with keywords: an Array of Symbols' do
      let(:options) { super().merge(keywords: %i[margin padding]) }

      it { expect(expectation.optional_keywords).to eq(%i[margin padding]) }

      context 'and with optional_keywords: value' do
        let(:options) { super().merge(optional_keywords: %i[shape color]) }

        it { expect(expectation.optional_keywords).to eq(%i[shape color]) }
      end
    end

    context 'when initialized with optional_keywords: an Array of Strings' do
      let(:options) { super().merge(optional_keywords: %w[shape color]) }

      it { expect(expectation.optional_keywords).to eq(%i[shape color]) }
    end

    context 'when initialized with optional_keywords: an Array of Symbols' do
      let(:options) { super().merge(optional_keywords: %i[shape color]) }

      it { expect(expectation.optional_keywords).to eq(%i[shape color]) }
    end
  end

  describe '#required_arguments' do
    include_examples 'should define reader', :required_arguments, 0

    context 'when initialized with arguments: an Integer' do
      let(:options) { super().merge(arguments: 5) }

      it { expect(expectation.required_arguments).to be 5 }

      context 'and required_arguments: value' do
        let(:options) { super().merge(required_arguments: 1) }

        it { expect(expectation.required_arguments).to be 1 }
      end
    end

    context 'when initialized with arguments: a Range' do
      let(:options) { super().merge(arguments: 3..5) }

      it { expect(expectation.required_arguments).to be 3 }

      context 'and required_arguments: value' do
        let(:options) { super().merge(required_arguments: 1) }

        it { expect(expectation.required_arguments).to be 1 }
      end
    end

    context 'when initialized with required_arguments: value' do
      let(:options) { super().merge(required_arguments: 2) }

      it { expect(expectation.required_arguments).to be 2 }
    end
  end

  describe '#required_keywords' do
    include_examples 'should define reader', :required_keywords, false

    context 'when initialized with keywords: value' do
      let(:options) { super().merge(keywords: %w[margin padding]) }

      it { expect(expectation.required_keywords).to be false }

      context 'and with required_keywords: value' do
        let(:options) { super().merge(required_keywords: %w[shape color]) }

        it { expect(expectation.required_keywords).to eq(%i[shape color]) }
      end
    end

    context 'when initialized with required_keywords: an Array of Strings' do
      let(:options) { super().merge(required_keywords: %w[shape color]) }

      it { expect(expectation.required_keywords).to eq(%i[shape color]) }
    end

    context 'when initialized with required_keywords: an Array of Symbols' do
      let(:options) { super().merge(required_keywords: %i[shape color]) }

      it { expect(expectation.required_keywords).to eq(%i[shape color]) }
    end
  end

  describe '#variadic_arguments' do
    include_examples 'should define reader', :variadic_arguments, false

    it 'should alias the method' do
      expect(expectation)
        .to have_aliased_method(:variadic_arguments)
        .as(:variadic_arguments?)
    end

    context 'when initialized with variadic_arguments: false' do
      let(:options) { super().merge(variadic_arguments: false) }

      it { expect(expectation.variadic_arguments).to be false }
    end

    context 'when initialized with variadic_arguments: true' do
      let(:options) { super().merge(variadic_arguments: true) }

      it { expect(expectation.variadic_arguments).to be true }
    end
  end

  describe '#variadic_keywords' do
    include_examples 'should define reader', :variadic_keywords, false

    it 'should alias the method' do
      expect(expectation)
        .to have_aliased_method(:variadic_keywords)
        .as(:variadic_keywords?)
    end

    context 'when initialized with variadic_keywords: false' do
      let(:options) { super().merge(variadic_keywords: false) }

      it { expect(expectation.variadic_keywords).to be false }
    end

    context 'when initialized with variadic_keywords: true' do
      let(:options) { super().merge(variadic_keywords: true) }

      it { expect(expectation.variadic_keywords).to be true }
    end
  end
end
