# spec/sleeping_king_studios/tools/string_tools_spec.rb

require 'spec_helper'

require 'sleeping_king_studios/tools/string_tools'

RSpec.describe SleepingKingStudios::Tools::StringTools do
  shared_examples 'should delegate to the inflector' \
  do |method_name, *arguments|
    before(:example) { allow(inflector).to receive(method_name) }

    it 'should delegate to the inflector' do
      instance.send(method_name, *arguments)

      expect(inflector).to have_received(method_name).with(*arguments)
    end
  end

  let(:instance) { Object.new.extend described_class }
  let(:inflector) do
    instance_double(SleepingKingStudios::Tools::Toolbox::Inflector)
  end

  before(:example) do
    allow(SleepingKingStudios::Tools::CoreTools).to receive(:deprecate)

    allow(instance).to receive(:inflector).and_return(inflector)
  end

  describe '#camelize' do
    it { expect(instance).to respond_to(:camelize).with(1).argument }

    it { expect(described_class).to respond_to(:camelize).with(1).argument }

    include_examples 'should delegate to the inflector',
      :camelize,
      'greetings_programs'
  end # describe

  describe '#chain' do
    let(:operations) { [] }
    let(:value)      { 'ArchivedPeriodical' }
    let(:expected)   { 'ArchivedPeriodical' }

    it 'should define the method' do
      expect(instance).
        to respond_to(:chain).
        with(1).argument.
        and_unlimited_arguments
    end # it

    it 'should define the class method' do
      expect(described_class).
        to respond_to(:chain).
        with(1).argument.
        and_unlimited_arguments
    end # it

    describe 'with a string' do
      it 'should return the string' do
        expect(instance.chain value, *operations).to be == expected
      end # it
    end # describe

    describe 'with a symbol' do
      it 'should return the string' do
        expect(instance.chain value.intern, *operations).to be == expected
      end # it
    end # describe

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
        end # it
      end # describe

      describe 'with a symbol' do
        it 'should return the string' do
          expect(instance.chain value.intern, *operations).to be == expected
        end # it
      end # describe
    end # describe

    describe 'with many operations' do
      let(:operations) { [:underscore, :pluralize] }
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
        end # it
      end # describe

      describe 'with a symbol' do
        it 'should return the string' do
          expect(instance.chain value.intern, *operations).to be == expected
        end # it
      end # describe
    end # describe
  end # describe

  describe '#define_irregular_word' do
    let(:rules) do
      instance_double(SleepingKingStudios::Tools::Toolbox::Inflector::Rules)
    end

    before(:example) do
      allow(inflector).to receive(:rules).and_return(rules)

      allow(rules).to receive(:define_irregular_word)
    end

    it { expect(instance).to respond_to(:define_irregular_word).with(2).arguments }

    it { expect(described_class).to respond_to(:define_irregular_word).with(2).arguments }

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
  end # describe

  describe '#define_plural_rule' do
    let(:rules) do
      instance_double(SleepingKingStudios::Tools::Toolbox::Inflector::Rules)
    end

    before(:example) do
      allow(inflector).to receive(:rules).and_return(rules)

      allow(rules).to receive(:define_plural_rule)
    end

    it { expect(instance).to respond_to(:define_plural_rule).with(2).arguments }

    it { expect(described_class).to respond_to(:define_plural_rule).with(2).arguments }

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
  end # describe

  describe '#define_singular_rule' do
    let(:rules) do
      instance_double(SleepingKingStudios::Tools::Toolbox::Inflector::Rules)
    end

    before(:example) do
      allow(inflector).to receive(:rules).and_return(rules)

      allow(rules).to receive(:define_singular_rule)
    end

    it { expect(instance).to respond_to(:define_singular_rule).with(2).arguments }

    it { expect(described_class).to respond_to(:define_singular_rule).with(2).arguments }

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
  end # describe

  describe '#define_uncountable_word' do
    let(:rules) do
      instance_double(SleepingKingStudios::Tools::Toolbox::Inflector::Rules)
    end

    before(:example) do
      allow(inflector).to receive(:rules).and_return(rules)

      allow(rules).to receive(:define_uncountable_word)
    end

    it { expect(instance).to respond_to(:define_uncountable_word).with(1).argument }

    it { expect(described_class).to respond_to(:define_uncountable_word).with(1).argument }

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
  end # describe

  describe '#indent' do
    it { expect(instance).to respond_to(:indent).with(1..2).arguments }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.indent nil }.to raise_error ArgumentError, /argument must be a string/
      end # it
    end # describe

    describe 'with an empty string' do
      it { expect(instance.indent '').to be == '' }
    end # describe

    describe 'with a single-line string' do
      let(:string)   { 'Greetings, programs!' }
      let(:expected) { "  #{string}" }

      it { expect(instance.indent string).to be == expected }

      describe 'with an indent count' do
        let(:expected) { "    #{string}" }

        it { expect(instance.indent string, 4).to be == expected }
      end # describe
    end # describe

    describe 'with a single-line string with trailing newline' do
      let(:string)   { "Greetings, programs!\n" }
      let(:expected) { "  #{string}" }

      it { expect(instance.indent string).to be == expected }

      describe 'with an indent count' do
        let(:expected) { "    #{string}" }

        it { expect(instance.indent string, 4).to be == expected }
      end # describe
    end # describe

    describe 'with a multi-line string' do
      let(:string) do
        "The Fellowship of the Ring\n"\
        "The Two Towers\n"\
        'The Return of the King'
      end # let
      let(:expected) do
        "  The Fellowship of the Ring\n"\
        "  The Two Towers\n"\
        '  The Return of the King'
      end # let

      it { expect(instance.indent string).to be == expected }

      describe 'with an indent count' do
        let(:expected) do
          "    The Fellowship of the Ring\n"\
          "    The Two Towers\n"\
          '    The Return of the King'
        end # let

        it { expect(instance.indent string, 4).to be == expected }
      end # describe
    end # describe
  end # describe

  describe '#map_lines' do
    it { expect(instance).to respond_to(:map_lines).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.map_lines nil }.to raise_error ArgumentError, /argument must be a string/
      end # it
    end # describe

    describe 'with an empty string' do
      it { expect(instance.map_lines('') { |line| "- #{line}" }).to be == '' }
    end # describe

    describe 'with a single-line string' do
      let(:string)   { 'Greetings, programs!' }
      let(:expected) { "- #{string}" }

      it 'should map each line' do
        expect(instance.map_lines(string) { |line| "- #{line}" }).
          to be == expected
      end # it

      describe 'with a block that yields the index' do
        let(:expected) { "0. #{string}" }

        it 'should map each line' do
          expect(instance.map_lines(string) do |line, index|
            "#{index}. #{line}"
          end). # map_lines
            to be == expected
        end # it
      end # describe
    end # describe

    describe 'with a single-line string with trailing newline' do
      let(:string)   { "Greetings, programs!\n" }
      let(:expected) { "- #{string}" }

      it 'should map each line' do
        expect(instance.map_lines(string) { |line| "- #{line}" }).
          to be == expected
      end # it

      describe 'with a block that yields the index' do
        let(:expected) { "0. #{string}" }

        it 'should map each line' do
          expect(instance.map_lines(string) do |line, index|
            "#{index}. #{line}"
          end). # map_lines
            to be == expected
        end # it
      end # describe
    end # describe

    describe 'with a multi-line string' do
      let(:string) do
        "The Fellowship of the Ring\n"\
        "The Two Towers\n"\
        'The Return of the King'
      end # let
      let(:expected) do
        "- The Fellowship of the Ring\n"\
        "- The Two Towers\n"\
        '- The Return of the King'
      end # let

      it 'should map each line' do
        expect(instance.map_lines(string) { |line| "- #{line}" }).
          to be == expected
      end # it

      describe 'with a block that yields the index' do
        let(:expected) do
          "0. The Fellowship of the Ring\n"\
          "1. The Two Towers\n"\
          '2. The Return of the King'
        end # let

        it 'should map each line' do
          expect(instance.map_lines(string) do |line, index|
            "#{index}. #{line}"
          end). # map_lines
            to be == expected
        end # it
      end # describe
    end # describe
  end # describe

  describe '#plural?' do
    before(:example) { allow(inflector).to receive(:pluralize) }

    it { expect(instance).to respond_to(:plural?).with(1).argument }

    it { expect(described_class).to respond_to(:plural?).with(1).argument }

    it { expect(described_class.plural? 'thing').to be == false }

    it { expect(described_class.plural? 'things').to be == true }

    it 'should delegate to the inflector' do
      instance.send(:plural?, 'word')

      expect(inflector).to have_received(:pluralize).with('word')
    end

    describe 'with a symbol' do
      it { expect(described_class.plural? :thing).to be == false }

      it { expect(described_class.plural? :things).to be == true }
    end # describe
  end # describe

  describe '#pluralize' do
    it { expect(instance).to respond_to(:pluralize).with(1).argument }

    it { expect(described_class).to respond_to(:pluralize).with(1).argument }

    it { expect(described_class.pluralize 'thing').to be == 'things' }

    include_examples 'should delegate to the inflector', :pluralize, 'thing'

    describe 'with an integer and two objects' do
      let(:single) { 'cow' }
      let(:plural) { 'kine' }

      it { expect(instance).to respond_to(:pluralize).with(3).arguments }

      it { expect(described_class).to respond_to(:pluralize).with(3).arguments }

      it 'should print a deprecation warning' do
        tools = ::SleepingKingStudios::Tools::CoreTools

        expect(tools).to receive(:deprecate) do |object, message:|
          expect(object).to be == 'StringTools#pluralize with 3 arguments'

          expect(message).to include 'Use IntegerTools#pluralize'
        end # receive

        described_class.pluralize 0, single, plural
      end # it

      describe 'with zero items' do
        it { expect(described_class.pluralize 0, single, plural).to be == plural }
      end # describe

      describe 'with one item' do
        it { expect(described_class.pluralize 1, single, plural).to be == single }
      end # describe

      describe 'with many items' do
        it { expect(described_class.pluralize 3, single, plural).to be == plural }
      end # describe
    end # describe
  end # describe

  describe '#singular?' do
    before(:example) { allow(inflector).to receive(:singularize) }

    it { expect(instance).to respond_to(:singular?).with(1).argument }

    it { expect(described_class).to respond_to(:singular?).with(1).argument }

    it { expect(described_class.singular? 'thing').to be == true }

    it { expect(described_class.singular? 'things').to be == false }

    it 'should delegate to the inflector' do
      instance.send(:singular?, 'words')

      expect(inflector).to have_received(:singularize).with('words')
    end

    describe 'with a symbol' do
      it { expect(described_class.singular? :thing).to be == true }

      it { expect(described_class.singular? :things).to be == false }
    end # describe
  end # describe

  describe '#singularize' do
    it { expect(instance).to respond_to(:singularize).with(1).argument }

    it { expect(described_class).to respond_to(:singularize).with(1).argument }

    it { expect(described_class.singularize 'things').to be == 'thing' }

    include_examples 'should delegate to the inflector', :singularize, 'things'
  end # describe

  describe '#string?' do
    it { expect(instance).to respond_to(:string?).with(1).argument }

    it { expect(described_class).to respond_to(:string?).with(1).argument }

    describe 'with nil' do
      it { expect(described_class.string? nil).to be false }
    end # describe

    describe 'with an object' do
      it { expect(described_class.string? Object.new).to be false }
    end # describe

    describe 'with a string' do
      it { expect(described_class.string? 'greetings,programs').to be true }
    end # describe

    describe 'with a symbol' do
      it { expect(described_class.string? :greetings_starfighter).to be false }
    end # describe

    describe 'with an integer' do
      it { expect(described_class.string? 42).to be false }
    end # describe

    describe 'with an empty array' do
      it { expect(described_class.string? []).to be false }
    end # describe

    describe 'with a non-empty array' do
      it { expect(described_class.string? %w(ichi ni san)).to be false }
    end # describe

    describe 'with an empty hash' do
      it { expect(described_class.string?({})).to be false }
    end # describe

    describe 'with a non-empty hash' do
      it { expect(described_class.string?({ :greetings => 'programs' })).to be false }
    end # describe
  end # describe

  describe '#underscore' do
    it { expect(instance).to respond_to(:underscore).with(1).argument }

    it { expect(described_class).to respond_to(:underscore).with(1).argument }

    include_examples 'should delegate to the inflector',
      :underscore,
      'GreetingsPrograms'
  end # describe
end # describe
