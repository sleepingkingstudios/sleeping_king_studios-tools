# spec/sleeping_king_studios/tools/string_tools_spec.rb

require 'spec_helper'

require 'sleeping_king_studios/tools/string_tools'

RSpec.describe SleepingKingStudios::Tools::StringTools do
  let(:instance) { Object.new.extend described_class }

  describe '#camelize' do
    it { expect(instance).to respond_to(:camelize).with(1).argument }

    it { expect(described_class).to respond_to(:camelize).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.camelize nil }.to raise_error ArgumentError, /argument must be a string/
      end # it
    end # describe

    describe 'with an empty string' do
      it { expect(described_class.camelize '').to be == '' }
    end # describe

    describe 'with a lowercase string' do
      it { expect(described_class.camelize 'valhalla').to be == 'Valhalla' }
    end # describe

    describe 'with a capitalized string' do
      it { expect(described_class.camelize 'Bifrost').to be == 'Bifrost' }
    end # describe

    describe 'with an uppercase string' do
      it { expect(described_class.camelize 'ASGARD').to be == 'ASGARD' }
    end # describe

    describe 'with a mixed-case string' do
      it { expect(described_class.camelize 'FenrisWolf').to be == 'FenrisWolf' }
    end # describe

    describe 'with an underscore-separated string' do
      it { expect(described_class.camelize 'frost_giant').to be == 'FrostGiant' }
    end # describe

    describe 'with an underscore-separated string with digits' do
      it { expect(described_class.camelize '9_worlds').to be == '9Worlds' }
    end # describe

    describe 'with an underscore-separated string with consecutive capitals' do
      it { expect(described_class.camelize 'ygg_drasil').to be == 'YggDrasil' }
    end # describe

    describe 'with a string with hyphens' do
      it { expect(described_class.camelize 'muspelheimr-and-niflheimr').to be == 'MuspelheimrAndNiflheimr' }
    end # describe
  end # describe

  describe '#define_irregular_word' do
    it { expect(instance).to respond_to(:define_irregular_word).with(2).arguments }

    it { expect(described_class).to respond_to(:define_irregular_word).with(2).arguments }

    it 'should delegate to an inflector' do
      inflector = double('inflector', :define_irregular_word => nil)

      allow(instance).to receive(:plural_inflector).and_return(inflector)

      expect(inflector).to receive(:define_irregular_word).with('goose', 'geese')

      instance.define_irregular_word 'goose', 'geese'
    end # it
  end # describe

  describe '#define_plural_rule' do
    it { expect(instance).to respond_to(:define_plural_rule).with(2).arguments }

    it { expect(described_class).to respond_to(:define_plural_rule).with(2).arguments }

    it 'should delegate to an inflector' do
      inflector = double('inflector', :define_plural_rule => nil)

      allow(instance).to receive(:plural_inflector).and_return(inflector)

      expect(inflector).to receive(:define_plural_rule).with(/lf$/, 'lves')

      instance.define_plural_rule(/lf$/, 'lves')
    end # it
  end # describe

  describe '#define_singular_rule' do
    it { expect(instance).to respond_to(:define_singular_rule).with(2).arguments }

    it { expect(described_class).to respond_to(:define_singular_rule).with(2).arguments }

    it 'should delegate to an inflector' do
      inflector = double('inflector', :define_singular_rule => nil)

      allow(instance).to receive(:plural_inflector).and_return(inflector)

      expect(inflector).to receive(:define_singular_rule).with(/lves$/, 'lf')

      instance.define_singular_rule(/lves$/, 'lf')
    end # it
  end # describe

  describe '#define_uncountable_word' do
    it { expect(instance).to respond_to(:define_uncountable_word).with(1).argument }

    it { expect(described_class).to respond_to(:define_uncountable_word).with(1).argument }

    it 'should delegate to an inflector' do
      inflector = double('inflector', :define_uncountable_word => nil)

      allow(instance).to receive(:plural_inflector).and_return(inflector)

      expect(inflector).to receive(:define_uncountable_word).with('data')

      instance.define_uncountable_word 'data'
    end # it
  end # describe

  describe '#plural?' do
    it { expect(instance).to respond_to(:plural?).with(1).argument }

    it { expect(described_class).to respond_to(:plural?).with(1).argument }

    it { expect(described_class.plural? 'thing').to be == false }

    it { expect(described_class.plural? 'things').to be == true }

    it 'should delegate to an inflector' do
      inflector = double('inflector', :pluralize => nil)

      allow(instance).to receive(:plural_inflector).and_return(inflector)

      expect(inflector).to receive(:pluralize).and_return('words')

      expect(instance.plural? 'word').to be false

      expect(inflector).to receive(:pluralize).and_return('words')

      expect(instance.plural? 'words').to be true
    end # it
  end # describe

  describe '#pluralize' do
    it { expect(instance).to respond_to(:pluralize).with(1).argument }

    it { expect(described_class).to respond_to(:pluralize).with(1).argument }

    it { expect(described_class.pluralize 'thing').to be == 'things' }

    it 'should delegate to an inflector' do
      inflector = double('inflector', :pluralize => nil)

      allow(instance).to receive(:plural_inflector).and_return(inflector)

      expect(inflector).to receive(:pluralize).and_return('words')

      expect(instance.pluralize 'word').to be == 'words'
    end # it

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.pluralize nil }.to raise_error ArgumentError, /argument must be a string/
      end # it
    end # describe

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
    it { expect(instance).to respond_to(:singular?).with(1).argument }

    it { expect(described_class).to respond_to(:singular?).with(1).argument }

    it { expect(described_class.singular? 'thing').to be == true }

    it { expect(described_class.singular? 'things').to be == false }

    it 'should delegate to an inflector' do
      inflector = double('inflector', :singularize => nil)

      allow(instance).to receive(:plural_inflector).and_return(inflector)

      expect(inflector).to receive(:singularize).and_return('word')

      expect(instance.singular? 'word').to be true

      expect(inflector).to receive(:singularize).and_return('word')

      expect(instance.singular? 'words').to be false
    end # it
  end # describe

  describe '#singularize' do
    it { expect(instance).to respond_to(:singularize).with(1).argument }

    it { expect(described_class).to respond_to(:singularize).with(1).argument }

    it { expect(described_class.singularize 'things').to be == 'thing' }

    it 'should delegate to an inflector' do
      inflector = double('inflector', :singularize => nil)

      allow(instance).to receive(:plural_inflector).and_return(inflector)

      expect(inflector).to receive(:singularize).and_return('word')

      expect(instance.singularize 'words').to be == 'word'
    end # it

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.singularize nil }.to raise_error ArgumentError, /argument must be a string/
      end # it
    end # describe
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

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.underscore nil }.to raise_error ArgumentError, /argument must be a string/
      end # it
    end # describe

    describe 'with an empty string' do
      it { expect(described_class.underscore '').to be == '' }
    end # describe

    describe 'with a lowercase string' do
      it { expect(described_class.underscore 'valhalla').to be == 'valhalla' }
    end # describe

    describe 'with a capitalized string' do
      it { expect(described_class.underscore 'Bifrost').to be == 'bifrost' }
    end # describe

    describe 'with an uppercase string' do
      it { expect(described_class.underscore 'ASGARD').to be == 'asgard' }
    end # describe

    describe 'with a mixed-case string' do
      it { expect(described_class.underscore 'FenrisWolf').to be == 'fenris_wolf' }
    end # describe

    describe 'with a mixed-case string with digits' do
      it { expect(described_class.underscore '9Worlds').to be == '9_worlds' }
    end # describe

    describe 'with a mixed-case string with consecutive capitals' do
      it { expect(described_class.underscore 'YGGDrasil').to be == 'ygg_drasil' }
    end # describe

    describe 'with a string with hyphens' do
      it { expect(described_class.underscore 'Muspelheimr-and-Niflheimr').to be == 'muspelheimr_and_niflheimr' }
    end # describe
  end # describe
end # describe
