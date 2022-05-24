# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/subclass'

RSpec.describe SleepingKingStudios::Tools::Toolbox::Subclass do
  extend RSpec::SleepingKingStudios::Concerns::ExampleConstants

  let(:described_class) { Spec::ParentClass }

  example_class 'Spec::ParentClass' do |klass|
    klass.extend SleepingKingStudios::Tools::Toolbox::Subclass # rubocop:disable RSpec/DescribedClass

    klass.define_method :initialize do |*traits, **values, &block|
      @block  = block
      @traits = traits
      @values = values
    end

    klass.attr_reader :block

    klass.attr_reader :traits

    klass.attr_reader :values
  end

  describe '.subclass' do
    shared_examples 'should merge the parameters' do
      subject { subclass.new(*traits, **values, &block) }

      let(:block)           { nil }
      let(:traits)          { [] }
      let(:values)          { {} }
      let(:expected_block)  { block || defined_block }
      let(:expected_traits) { defined_traits + traits }
      let(:expected_values) { defined_values.merge(values) }

      describe 'when initialized with no parameters' do
        it { expect(subject.block).to be expected_block }

        it { expect(subject.traits).to be == expected_traits }

        it { expect(subject.values).to be == expected_values }
      end

      describe 'when initialized with arguments' do
        let(:traits) { %w[intelligent charismatic] }

        it { expect(subject.block).to be expected_block }

        it { expect(subject.traits).to be == expected_traits }

        it { expect(subject.values).to be == expected_values }
      end

      describe 'when initialized with keywords' do
        let(:values) { { performance: 10, sorcery: 5 } }

        it { expect(subject.block).to be expected_block }

        it { expect(subject.traits).to be == expected_traits }

        it { expect(subject.values).to be == expected_values }
      end

      describe 'when initialized with a block' do
        let(:block) { -> {} }

        it { expect(subject.block).to be expected_block }

        it { expect(subject.traits).to be == expected_traits }

        it { expect(subject.values).to be == expected_values }
      end

      describe 'when initialized with multiple parameters' do
        let(:block)  { -> {} }
        let(:traits) { %w[intelligent charismatic] }
        let(:values) { { performance: 5, sorcery: 10 } }

        it { expect(subject.block).to be expected_block }

        it { expect(subject.traits).to be == expected_traits }

        it { expect(subject.values).to be == expected_values }
      end
    end

    let(:defined_block)   { nil }
    let(:defined_traits)  { [] }
    let(:defined_values)  { {} }

    it 'should define the class method' do # rubocop:disable RSpec/ExampleLength
      expect(described_class)
        .to respond_to(:subclass)
        .with(0).arguments
        .and_unlimited_arguments
        .and_any_keywords
        .and_a_block
    end

    context 'when extended into an Object' do
      let(:described_class) do
        Object.new.extend SleepingKingStudios::Tools::Toolbox::Subclass # rubocop:disable RSpec/DescribedClass
      end
      let(:error_message) do
        # :nocov:
        if RUBY_VERSION >= '3.0'
          'superclass must be an instance of Class (given an instance of' \
            ' Object)'
        else
          'superclass must be a Class (Object given)'
        end
        # :nocov:
      end

      it 'should raise an exception' do
        expect { described_class.subclass }
          .to raise_error TypeError, error_message
      end
    end

    context 'when extended into a Module' do
      let(:described_class) do
        Module.new.extend SleepingKingStudios::Tools::Toolbox::Subclass # rubocop:disable RSpec/DescribedClass
      end
      let(:error_message) do
        # :nocov:
        if RUBY_VERSION >= '3.0'
          'superclass must be an instance of Class (given an instance of' \
            ' Module)'
        else
          'superclass must be a Class (Module given)'
        end
        # :nocov:
      end

      it 'should raise an exception' do
        expect { described_class.subclass }
          .to raise_error TypeError, error_message
      end
    end

    describe 'with no parameters' do
      let(:subclass) { described_class.subclass }

      it { expect(subclass).to be_a Class }

      it { expect(subclass).to be < described_class }

      wrap_examples 'should merge the parameters'
    end

    describe 'with arguments' do
      let(:defined_traits) { %w[musical] }
      let(:subclass)       { described_class.subclass(*defined_traits) }

      include_examples 'should merge the parameters'
    end

    describe 'with keywords' do
      let(:defined_values) { { persuasion: 10, performance: 5 } }
      let(:subclass)       { described_class.subclass(**defined_values) }

      include_examples 'should merge the parameters'
    end

    describe 'with a block' do
      let(:defined_block) { -> { :ok } }
      let(:subclass)      { described_class.subclass(&defined_block) }

      include_examples 'should merge the parameters'
    end

    describe 'with multiple parameters' do
      let(:defined_block)  { -> { :ok } }
      let(:defined_traits) { %w[musical] }
      let(:defined_values) { { persuasion: 10, performance: 5 } }
      let(:subclass) do
        described_class.subclass(
          *defined_traits,
          **defined_values,
          &defined_block
        )
      end

      include_examples 'should merge the parameters'
    end
  end
end
