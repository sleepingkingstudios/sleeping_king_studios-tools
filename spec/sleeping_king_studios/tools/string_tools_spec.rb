# frozen_string_literal: true

require 'sleeping_king_studios/tools/string_tools'

RSpec.describe SleepingKingStudios::Tools::StringTools do
  shared_context 'with an inflector double' do
    let(:rules) do
      instance_double(SleepingKingStudios::Tools::Toolbox::Inflector::Rules)
    end
    let(:inflector) do
      instance_double(
        SleepingKingStudios::Tools::Toolbox::Inflector,
        rules:
      )
    end
    let(:constructor_options) { super().merge(inflector:) }
  end

  shared_examples 'should delegate to the inflector' \
  do |method_name, *arguments|
    before(:example) { allow(inflector).to receive(method_name) }

    it 'should delegate to the inflector' do
      string_tools.send(method_name, *arguments)

      expect(inflector).to have_received(method_name).with(*arguments)
    end
  end

  subject(:string_tools) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:inflector, :toolbelt)
    end

    describe 'with inflector: value' do
      let(:inflector) do
        instance_double(SleepingKingStudios::Tools::Toolbox::Inflector)
      end
      let(:string_tools) { described_class.new(inflector:) }

      it { expect(string_tools.inflector).to be inflector }
    end
  end

  describe '#camelize' do
    include_context 'with an inflector double'

    it { expect(string_tools).to respond_to(:camelize).with(1).argument }

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
      expect(string_tools)
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
        expect(string_tools.chain value, *operations).to be == expected
      end
    end

    describe 'with a symbol' do
      it 'should return the string' do
        expect(string_tools.chain value.intern, *operations).to be == expected
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
          expect(string_tools.chain value, *operations).to be == expected
        end
      end

      describe 'with a symbol' do
        it 'should return the string' do
          expect(string_tools.chain value.intern, *operations).to be == expected
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
          expect(string_tools.chain value, *operations).to be == expected
        end
      end

      describe 'with a symbol' do
        it 'should return the string' do
          expect(string_tools.chain value.intern, *operations).to be == expected
        end
      end
    end
  end

  describe '#indent' do
    it { expect(string_tools).to respond_to(:indent).with(1..2).arguments }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.indent nil }
          .to raise_error ArgumentError, /argument must be a string/
      end
    end

    describe 'with an empty string' do
      it { expect(string_tools.indent '').to be == '' }
    end

    describe 'with a single-line string' do
      let(:string)   { 'Greetings, programs!' }
      let(:expected) { "  #{string}" }

      it { expect(string_tools.indent string).to be == expected }

      describe 'with an indent count' do
        let(:expected) { "    #{string}" }

        it { expect(string_tools.indent string, 4).to be == expected }
      end
    end

    describe 'with a single-line string with trailing newline' do
      let(:string)   { "Greetings, programs!\n" }
      let(:expected) { "  #{string}" }

      it { expect(string_tools.indent string).to be == expected }

      describe 'with an indent count' do
        let(:expected) { "    #{string}" }

        it { expect(string_tools.indent string, 4).to be == expected }
      end
    end

    describe 'with a multi-line string' do
      let(:string) do
        "The Fellowship of the Ring\n" \
          "The Two Towers\n" \
          'The Return of the King'
      end
      let(:expected) do
        "  The Fellowship of the Ring\n  " \
          "The Two Towers\n  " \
          'The Return of the King'
      end

      it { expect(string_tools.indent string).to be == expected }

      describe 'with an indent count' do
        let(:expected) do
          "    The Fellowship of the Ring\n    " \
            "The Two Towers\n    " \
            'The Return of the King'
        end

        it { expect(string_tools.indent string, 4).to be == expected }
      end
    end
  end

  describe '#inflector' do
    it { expect(string_tools).to respond_to(:inflector).with(0).arguments }

    it 'should return an inflector' do
      expect(string_tools.inflector)
        .to be_a SleepingKingStudios::Tools::Toolbox::Inflector
    end
  end

  describe '#map_lines' do
    it { expect(string_tools).to respond_to(:map_lines).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.map_lines nil }
          .to raise_error ArgumentError, /argument must be a string/
      end
    end

    describe 'with an empty string' do
      it 'should return an empty string' do
        expect(string_tools.map_lines('') { |line| "- #{line}" }).to be == ''
      end
    end

    describe 'with a single-line string' do
      let(:string)   { 'Greetings, programs!' }
      let(:expected) { "- #{string}" }

      it 'should map each line' do
        expect(string_tools.map_lines(string) { |line| "- #{line}" })
          .to be == expected
      end

      describe 'with a block that yields the index' do
        let(:expected) { "0. #{string}" }

        it 'should map each line' do
          expect(
            string_tools.map_lines(string) do |line, index|
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
        expect(string_tools.map_lines(string) { |line| "- #{line}" })
          .to be == expected
      end

      describe 'with a block that yields the index' do
        let(:expected) { "0. #{string}" }

        it 'should map each line' do
          expect(
            string_tools.map_lines(string) do |line, index|
              "#{index}. #{line}"
            end
          ).to be == expected
        end
      end
    end

    describe 'with a multi-line string' do
      let(:string) do
        "The Fellowship of the Ring\n" \
          "The Two Towers\n" \
          'The Return of the King'
      end
      let(:expected) do
        "- The Fellowship of the Ring\n" \
          "- The Two Towers\n" \
          '- The Return of the King'
      end

      it 'should map each line' do
        expect(string_tools.map_lines(string) { |line| "- #{line}" })
          .to be == expected
      end

      describe 'with a block that yields the index' do
        let(:expected) do
          "0. The Fellowship of the Ring\n" \
            "1. The Two Towers\n" \
            '2. The Return of the King'
        end

        it 'should map each line' do
          expect(
            string_tools.map_lines(string) do |line, index|
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

    it { expect(string_tools).to respond_to(:plural?).with(1).argument }

    it { expect(described_class).to respond_to(:plural?).with(1).argument }

    it 'should delegate to the inflector' do
      string_tools.send(:plural?, 'word')

      expect(inflector).to have_received(:pluralize).with('word')
    end

    describe 'with a singular word' do
      let(:word) { 'word' }

      before(:example) do
        allow(inflector).to receive(:pluralize).and_return('words')
      end

      it { expect(string_tools.plural? word).to be false }
    end

    describe 'with a plural word' do
      let(:word) { 'words' }

      before(:example) do
        allow(inflector).to receive(:pluralize).and_return('words')
      end

      it { expect(string_tools.plural? word).to be true }
    end

    describe 'with a symbol' do
      it 'should delegate to the inflector' do
        string_tools.send(:plural?, :word)

        expect(inflector).to have_received(:pluralize).with('word')
      end

      describe 'with a singular word' do
        let(:word) { :word }

        before(:example) do
          allow(inflector).to receive(:pluralize).and_return('words')
        end

        it { expect(string_tools.plural? word).to be false }
      end

      describe 'with a plural word' do
        let(:word) { :words }

        before(:example) do
          allow(inflector).to receive(:pluralize).and_return('words')
        end

        it { expect(string_tools.plural? word).to be true }
      end
    end
  end

  describe '#pluralize' do
    include_context 'with an inflector double'

    it { expect(string_tools).to respond_to(:pluralize).with(1).argument }

    it { expect(described_class).to respond_to(:pluralize).with(1).argument }

    include_examples 'should delegate to the inflector', :pluralize, 'thing'
  end

  describe '#singular?' do
    include_context 'with an inflector double'

    before(:example) { allow(inflector).to receive(:singularize) }

    it { expect(string_tools).to respond_to(:singular?).with(1).argument }

    it { expect(described_class).to respond_to(:singular?).with(1).argument }

    it 'should delegate to the inflector' do
      string_tools.send(:singular?, 'words')

      expect(inflector).to have_received(:singularize).with('words')
    end

    describe 'with a singular word' do
      let(:word) { 'word' }

      before(:example) do
        allow(inflector).to receive(:singularize).and_return('word')
      end

      it { expect(string_tools.singular? word).to be true }
    end

    describe 'with a plural word' do
      let(:word) { 'words' }

      before(:example) do
        allow(inflector).to receive(:singularize).and_return('word')
      end

      it { expect(string_tools.singular? word).to be false }
    end

    describe 'with a symbol' do
      it 'should delegate to the inflector' do
        string_tools.send(:singular?, :words)

        expect(inflector).to have_received(:singularize).with('words')
      end

      describe 'with a singular word' do
        let(:word) { :word }

        before(:example) do
          allow(inflector).to receive(:singularize).and_return('word')
        end

        it { expect(string_tools.singular? word).to be true }
      end

      describe 'with a plural word' do
        let(:word) { :words }

        before(:example) do
          allow(inflector).to receive(:singularize).and_return('word')
        end

        it { expect(string_tools.singular? word).to be false }
      end
    end
  end

  describe '#singularize' do
    include_context 'with an inflector double'

    it { expect(string_tools).to respond_to(:singularize).with(1).argument }

    it { expect(described_class).to respond_to(:singularize).with(1).argument }

    include_examples 'should delegate to the inflector', :singularize, 'things'
  end

  describe '#string?' do
    it { expect(string_tools).to respond_to(:string?).with(1).argument }

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

  describe '#toolbelt' do
    let(:expected) { SleepingKingStudios::Tools::Toolbelt.global }

    it { expect(string_tools.toolbelt).to be expected }

    it { expect(string_tools).to have_aliased_method(:toolbelt).as(:tools) }

    context 'when initialized with toolbelt: value' do
      let(:toolbelt) { SleepingKingStudios::Tools::Toolbelt.new }
      let(:constructor_options) do
        super().merge(toolbelt:)
      end

      it { expect(string_tools.toolbelt).to be toolbelt }
    end
  end

  describe '#underscore' do
    include_context 'with an inflector double'

    it { expect(string_tools).to respond_to(:underscore).with(1).argument }

    it { expect(described_class).to respond_to(:underscore).with(1).argument }

    include_examples 'should delegate to the inflector',
      :underscore,
      'GreetingsPrograms'
  end
end
