# frozen_string_literal: true

require 'spec_helper'

require 'sleeping_king_studios/tools/string_tools'

RSpec.describe SleepingKingStudios::Tools::StringTools do
  shared_context 'with an inflector double' do
    let(:rules) do
      instance_double(SleepingKingStudios::Tools::Toolbox::Inflector::Rules)
    end
    let(:inflector) do
      instance_double(
        SleepingKingStudios::Tools::Toolbox::Inflector,
        rules: rules
      )
    end
    let(:instance) { described_class.new(inflector: inflector) }
  end

  shared_examples 'should delegate to the inflector' \
  do |method_name, *arguments|
    before(:example) { allow(inflector).to receive(method_name) }

    it 'should delegate to the inflector' do
      instance.send(method_name, *arguments)

      expect(inflector).to have_received(method_name).with(*arguments)
    end
  end

  let(:instance) { described_class.instance }

  before(:example) do
    allow(SleepingKingStudios::Tools::CoreTools).to receive(:deprecate)
  end

  describe '.new' do
    describe 'with inflector: value' do
      let(:inflector) do
        instance_double(SleepingKingStudios::Tools::Toolbox::Inflector)
      end
      let(:instance) { described_class.new(inflector: inflector) }

      it { expect(instance.inflector).to be inflector }
    end
  end

  describe '#camelize' do
    include_context 'with an inflector double'

    it { expect(instance).to respond_to(:camelize).with(1).argument }

    it { expect(described_class).to respond_to(:camelize).with(1).argument }

    include_examples 'should delegate to the inflector',
      :camelize,
      'greetings_programs'
  end

  describe '#chain' do
    include_context 'with an inflector double'

    let(:operations) { [] }
    let(:value)      { 'ArchivedPeriodical' }
    let(:expected)   { 'ArchivedPeriodical' }

    it 'should define the method' do
      expect(instance)
        .to respond_to(:chain)
        .with(1).argument
        .and_unlimited_arguments
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:chain)
        .with(1).argument
        .and_unlimited_arguments
    end

    describe 'with a string' do
      it 'should return the string' do
        expect(instance.chain value, *operations).to be == expected
      end
    end

    describe 'with a symbol' do
      it 'should return the string' do
        expect(instance.chain value.intern, *operations).to be == expected
      end
    end

    describe 'with one operation' do
      let(:operations) { [:underscore] }
      let(:expected)   { 'archived_periodical' }

      before(:example) do
        allow(inflector)
          .to receive(:underscore)
          .with('ArchivedPeriodical')
          .and_return('archived_periodical')
      end

      describe 'with a string' do
        it 'should return the string' do
          expect(instance.chain value, *operations).to be == expected
        end
      end

      describe 'with a symbol' do
        it 'should return the string' do
          expect(instance.chain value.intern, *operations).to be == expected
        end
      end
    end

    describe 'with many operations' do
      let(:operations) { %i[underscore pluralize] }
      let(:expected)   { 'archived_periodicals' }

      before(:example) do
        allow(inflector)
          .to receive(:underscore)
          .with('ArchivedPeriodical')
          .and_return('archived_periodical')

        allow(inflector)
          .to receive(:pluralize)
          .with('archived_periodical')
          .and_return('archived_periodicals')
      end

      describe 'with a string' do
        it 'should return the string' do
          expect(instance.chain value, *operations).to be == expected
        end
      end

      describe 'with a symbol' do
        it 'should return the string' do
          expect(instance.chain value.intern, *operations).to be == expected
        end
      end
    end
  end

  describe '#define_irregular_word' do
    include_context 'with an inflector double'

    let(:rules) do
      instance_double(SleepingKingStudios::Tools::Toolbox::Inflector::Rules)
    end

    before(:example) do
      allow(rules).to receive(:define_irregular_word)
    end

    it 'should define the method' do
      expect(instance).to respond_to(:define_irregular_word).with(2).arguments
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:define_irregular_word)
        .with(2).arguments
    end

    it 'should delegate to the inflector rules' do
      instance.define_irregular_word('goose', 'geese')

      expect(inflector.rules)
        .to have_received(:define_irregular_word)
        .with('goose', 'geese')
    end

    it 'should be deprecated' do
      instance.define_irregular_word('goose', 'geese')

      expect(SleepingKingStudios::Tools::CoreTools).to have_received(:deprecate)
    end
  end

  describe '#define_plural_rule' do
    include_context 'with an inflector double'

    before(:example) do
      allow(rules).to receive(:define_plural_rule)
    end

    it { expect(instance).to respond_to(:define_plural_rule).with(2).arguments }

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:define_plural_rule)
        .with(2).arguments
    end

    it 'should delegate to the inflector rules' do
      instance.define_plural_rule(/lf$/, 'lves')

      expect(inflector.rules)
        .to have_received(:define_plural_rule)
        .with(/lf$/, 'lves')
    end

    it 'should be deprecated' do
      instance.define_plural_rule(/lf$/, 'lves')

      expect(SleepingKingStudios::Tools::CoreTools).to have_received(:deprecate)
    end
  end

  describe '#define_singular_rule' do
    include_context 'with an inflector double'

    before(:example) do
      allow(rules).to receive(:define_singular_rule)
    end

    it 'should define the method' do
      expect(instance).to respond_to(:define_singular_rule).with(2).arguments
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:define_singular_rule)
        .with(2).arguments
    end

    it 'should delegate to the inflector rules' do
      instance.define_singular_rule(/lves$/, 'lf')

      expect(inflector.rules)
        .to have_received(:define_singular_rule)
        .with(/lves$/, 'lf')
    end

    it 'should be deprecated' do
      instance.define_singular_rule(/lves$/, 'lf')

      expect(SleepingKingStudios::Tools::CoreTools).to have_received(:deprecate)
    end
  end

  describe '#define_uncountable_word' do
    include_context 'with an inflector double'

    before(:example) do
      allow(rules).to receive(:define_uncountable_word)
    end

    it 'should define the method' do
      expect(instance).to respond_to(:define_uncountable_word).with(1).argument
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:define_uncountable_word)
        .with(1).argument
    end

    it 'should delegate to the inflector rules' do
      instance.define_uncountable_word('metadata')

      expect(inflector.rules)
        .to have_received(:define_uncountable_word)
        .with('metadata')
    end

    it 'should be deprecated' do
      instance.define_uncountable_word('metadata')

      expect(SleepingKingStudios::Tools::CoreTools).to have_received(:deprecate)
    end
  end

  describe '#indent' do
    it { expect(instance).to respond_to(:indent).with(1..2).arguments }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.indent nil }
          .to raise_error ArgumentError, /argument must be a string/
      end
    end

    describe 'with an empty string' do
      it { expect(instance.indent '').to be == '' }
    end

    describe 'with a single-line string' do
      let(:string)   { 'Greetings, programs!' }
      let(:expected) { "  #{string}" }

      it { expect(instance.indent string).to be == expected }

      describe 'with an indent count' do
        let(:expected) { "    #{string}" }

        it { expect(instance.indent string, 4).to be == expected }
      end
    end

    describe 'with a single-line string with trailing newline' do
      let(:string)   { "Greetings, programs!\n" }
      let(:expected) { "  #{string}" }

      it { expect(instance.indent string).to be == expected }

      describe 'with an indent count' do
        let(:expected) { "    #{string}" }

        it { expect(instance.indent string, 4).to be == expected }
      end
    end

    describe 'with a multi-line string' do
      let(:string) do
        "The Fellowship of the Ring\n"\
        "The Two Towers\n"\
        'The Return of the King'
      end
      let(:expected) do
        "  The Fellowship of the Ring\n"\
        "  The Two Towers\n"\
        '  The Return of the King'
      end

      it { expect(instance.indent string).to be == expected }

      describe 'with an indent count' do
        let(:expected) do
          "    The Fellowship of the Ring\n"\
          "    The Two Towers\n"\
          '    The Return of the King'
        end

        it { expect(instance.indent string, 4).to be == expected }
      end
    end
  end

  describe '#inflector' do
    it { expect(instance).to respond_to(:inflector).with(0).arguments }

    it 'should return an inflector' do
      expect(instance.inflector)
        .to be_a SleepingKingStudios::Tools::Toolbox::Inflector
    end
  end

  describe '#map_lines' do
    it { expect(instance).to respond_to(:map_lines).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.map_lines nil }
          .to raise_error ArgumentError, /argument must be a string/
      end
    end

    describe 'with an empty string' do
      it { expect(instance.map_lines('') { |line| "- #{line}" }).to be == '' }
    end

    describe 'with a single-line string' do
      let(:string)   { 'Greetings, programs!' }
      let(:expected) { "- #{string}" }

      it 'should map each line' do
        expect(instance.map_lines(string) { |line| "- #{line}" })
          .to be == expected
      end

      describe 'with a block that yields the index' do
        let(:expected) { "0. #{string}" }

        it 'should map each line' do
          expect(
            instance.map_lines(string) do |line, index|
              "#{index}. #{line}"
            end
          ).to be == expected
        end
      end
    end

    describe 'with a single-line string with trailing newline' do
      let(:string)   { "Greetings, programs!\n" }
      let(:expected) { "- #{string}" }

      it 'should map each line' do
        expect(instance.map_lines(string) { |line| "- #{line}" })
          .to be == expected
      end

      describe 'with a block that yields the index' do
        let(:expected) { "0. #{string}" }

        it 'should map each line' do
          expect(
            instance.map_lines(string) do |line, index|
              "#{index}. #{line}"
            end
          ).to be == expected
        end
      end
    end

    describe 'with a multi-line string' do
      let(:string) do
        "The Fellowship of the Ring\n"\
        "The Two Towers\n"\
        'The Return of the King'
      end
      let(:expected) do
        "- The Fellowship of the Ring\n"\
        "- The Two Towers\n"\
        '- The Return of the King'
      end

      it 'should map each line' do
        expect(instance.map_lines(string) { |line| "- #{line}" })
          .to be == expected
      end

      describe 'with a block that yields the index' do
        let(:expected) do
          "0. The Fellowship of the Ring\n"\
          "1. The Two Towers\n"\
          '2. The Return of the King'
        end

        it 'should map each line' do
          expect(
            instance.map_lines(string) do |line, index|
              "#{index}. #{line}"
            end
          ).to be == expected
        end
      end
    end
  end

  describe '#plural?' do
    include_context 'with an inflector double'

    before(:example) { allow(inflector).to receive(:pluralize) }

    it { expect(instance).to respond_to(:plural?).with(1).argument }

    it { expect(described_class).to respond_to(:plural?).with(1).argument }

    it 'should delegate to the inflector' do
      instance.send(:plural?, 'word')

      expect(inflector).to have_received(:pluralize).with('word')
    end

    describe 'with a singular word' do
      let(:word) { 'word' }

      before(:example) do
        allow(inflector).to receive(:pluralize).and_return('words')
      end

      it { expect(instance.plural? word).to be false }
    end

    describe 'with a plural word' do
      let(:word) { 'words' }

      before(:example) do
        allow(inflector).to receive(:pluralize).and_return('words')
      end

      it { expect(instance.plural? word).to be true }
    end

    describe 'with a symbol' do
      it 'should delegate to the inflector' do
        instance.send(:plural?, :word)

        expect(inflector).to have_received(:pluralize).with('word')
      end

      describe 'with a singular word' do
        let(:word) { :word }

        before(:example) do
          allow(inflector).to receive(:pluralize).and_return('words')
        end

        it { expect(instance.plural? word).to be false }
      end

      describe 'with a plural word' do
        let(:word) { :words }

        before(:example) do
          allow(inflector).to receive(:pluralize).and_return('words')
        end

        it { expect(instance.plural? word).to be true }
      end
    end
  end

  describe '#pluralize' do
    include_context 'with an inflector double'

    it { expect(instance).to respond_to(:pluralize).with(1).argument }

    it { expect(described_class).to respond_to(:pluralize).with(1).argument }

    include_examples 'should delegate to the inflector', :pluralize, 'thing'

    describe 'with an integer and two objects' do
      let(:single) { 'cow' }
      let(:plural) { 'kine' }

      it { expect(instance).to respond_to(:pluralize).with(3).arguments }

      it { expect(described_class).to respond_to(:pluralize).with(3).arguments }

      it 'should print a deprecation warning' do # rubocop:disable RSpec/ExampleLength
        described_class.pluralize 0, single, plural

        expect(SleepingKingStudios::Tools::CoreTools)
          .to have_received(:deprecate)
          .with(
            'StringTools#pluralize with 3 arguments',
            message: 'Use IntegerTools#pluralize instead.'
          )
      end

      describe 'with zero items' do
        it 'should return the plural term' do
          expect(described_class.pluralize 0, single, plural).to be == plural
        end
      end

      describe 'with one item' do
        it 'should return the singular term' do
          expect(described_class.pluralize 1, single, plural).to be == single
        end
      end

      describe 'with many items' do
        it 'should return the plural term' do
          expect(described_class.pluralize 3, single, plural).to be == plural
        end
      end
    end
  end

  describe '#singular?' do
    include_context 'with an inflector double'

    before(:example) { allow(inflector).to receive(:singularize) }

    it { expect(instance).to respond_to(:singular?).with(1).argument }

    it { expect(described_class).to respond_to(:singular?).with(1).argument }

    it 'should delegate to the inflector' do
      instance.send(:singular?, 'words')

      expect(inflector).to have_received(:singularize).with('words')
    end

    describe 'with a singular word' do
      let(:word) { 'word' }

      before(:example) do
        allow(inflector).to receive(:singularize).and_return('word')
      end

      it { expect(instance.singular? word).to be true }
    end

    describe 'with a plural word' do
      let(:word) { 'words' }

      before(:example) do
        allow(inflector).to receive(:singularize).and_return('word')
      end

      it { expect(instance.singular? word).to be false }
    end

    describe 'with a symbol' do
      it 'should delegate to the inflector' do
        instance.send(:singular?, :words)

        expect(inflector).to have_received(:singularize).with('words')
      end

      describe 'with a singular word' do
        let(:word) { :word }

        before(:example) do
          allow(inflector).to receive(:singularize).and_return('word')
        end

        it { expect(instance.singular? word).to be true }
      end

      describe 'with a plural word' do
        let(:word) { :words }

        before(:example) do
          allow(inflector).to receive(:singularize).and_return('word')
        end

        it { expect(instance.singular? word).to be false }
      end
    end
  end

  describe '#singularize' do
    include_context 'with an inflector double'

    it { expect(instance).to respond_to(:singularize).with(1).argument }

    it { expect(described_class).to respond_to(:singularize).with(1).argument }

    include_examples 'should delegate to the inflector', :singularize, 'things'
  end

  describe '#string?' do
    it { expect(instance).to respond_to(:string?).with(1).argument }

    it { expect(described_class).to respond_to(:string?).with(1).argument }

    describe 'with nil' do
      it { expect(described_class.string? nil).to be false }
    end

    describe 'with an object' do
      it { expect(described_class.string? Object.new).to be false }
    end

    describe 'with a string' do
      it { expect(described_class.string? 'greetings,programs').to be true }
    end

    describe 'with a symbol' do
      it { expect(described_class.string? :greetings_starfighter).to be false }
    end

    describe 'with an integer' do
      it { expect(described_class.string? 42).to be false }
    end

    describe 'with an empty array' do
      it { expect(described_class.string? []).to be false }
    end

    describe 'with a non-empty array' do
      it { expect(described_class.string? %w[ichi ni san]).to be false }
    end

    describe 'with an empty hash' do
      it { expect(described_class.string?({})).to be false }
    end

    describe 'with a non-empty hash' do
      let(:object) { { greetings: 'programs' } }

      it { expect(described_class.string?(object)).to be false }
    end
  end

  describe '#underscore' do
    include_context 'with an inflector double'

    it { expect(instance).to respond_to(:underscore).with(1).argument }

    it { expect(described_class).to respond_to(:underscore).with(1).argument }

    include_examples 'should delegate to the inflector',
      :underscore,
      'GreetingsPrograms'
  end
end
