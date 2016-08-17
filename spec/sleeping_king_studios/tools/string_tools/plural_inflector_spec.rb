# spec/sleeping_king_studios/tools/string_tools/plural_inflector_spec.rb

require 'spec_helper'

require 'sleeping_king_studios/tools/string_tools'

RSpec.describe SleepingKingStudios::Tools::StringTools::PluralInflector do
  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#define_irregular_word' do
    it { expect(instance).to respond_to(:define_irregular_word).with(2).arguments }

    it 'should define an irregular word' do
      instance.define_irregular_word('goose', 'geese')

      expect(instance.pluralize 'goose').to be == 'geese'
      expect(instance.pluralize 'moose').to be == 'mooses'
    end # it
  end # describe

  describe '#define_plural_rule' do
    it { expect(instance).to respond_to(:define_plural_rule).with(2).arguments }

    it 'should define a plural rule' do
      instance.define_plural_rule(/lf$/i, 'lves')

      expect(instance.pluralize 'elf').to be == 'elves'
    end # it
  end # describe

  describe '#define_singular_rule' do
    it { expect(instance).to respond_to(:define_singular_rule).with(2).arguments }

    it 'should define a singular rule' do
      instance.define_singular_rule(/lves$/i, 'lf')

      expect(instance.singularize 'elves').to be == 'elf'
    end # it
  end # describe

  describe '#define_uncountable_word' do
    it { expect(instance).to respond_to(:define_uncountable_word).with(1).argument }

    it 'should define an uncountable word' do
      instance.define_uncountable_word('series')

      expect(instance.pluralize 'series').to be == 'series'
    end # it
  end # describe

  describe '#pluralize' do
    it { expect(instance).to respond_to(:pluralize).with(1).argument }

    describe 'with nil' do
      it { expect(instance.pluralize nil).to be == 's' }
    end # describe

    describe 'with an empty string' do
      it { expect(instance.pluralize '').to be == 's' }
    end # describe

    describe 'with a word with basic pluralization' do
      it { expect(instance.pluralize 'word').to be == 'words' }

      it { expect(instance.pluralize 'words').to be == 'words' }
    end # describe

    describe 'with a word ending in "ch"' do
      it { expect(instance.pluralize 'torch').to be == 'torches' }

      it { expect(instance.pluralize 'torches').to be == 'torches' }
    end # describe

    describe 'with a word ending in "sh"' do
      it { expect(instance.pluralize 'fish').to be == 'fishes' }

      it { expect(instance.pluralize 'fishes').to be == 'fishes' }
    end # describe

    describe 'with a word ending in "ss"' do
      it { expect(instance.pluralize 'truss').to be == 'trusses' }

      it { expect(instance.pluralize 'trusses').to be == 'trusses' }
    end # describe

    describe 'with a word ending in "x"' do
      it { expect(instance.pluralize 'box').to be == 'boxes' }

      it { expect(instance.pluralize 'boxes').to be == 'boxes' }
    end # describe

    describe 'with a word ending in "z"' do
      it { expect(instance.pluralize 'buzz').to be == 'buzzes' }

      it { expect(instance.pluralize 'buzzes').to be == 'buzzes' }
    end # describe

    describe 'with a word ending in a consonant followed by "o"' do
      it { expect(instance.pluralize 'antihero').to be == 'antiheroes' }

      it { expect(instance.pluralize 'antiheroes').to be == 'antiheroes' }
    end # describe

    describe 'with a word ending in a consonant followed by "y"' do
      it { expect(instance.pluralize 'winery').to be == 'wineries' }

      it { expect(instance.pluralize 'wineries').to be == 'wineries' }
    end # describe

    describe 'with "child"' do
      it { expect(instance.pluralize 'child').to be == 'children' }

      it { expect(instance.pluralize 'children').to be == 'children' }
    end # describe

    describe 'with "person"' do
      it { expect(instance.pluralize 'person').to be == 'people' }

      it { expect(instance.pluralize 'people').to be == 'people' }
    end # it

    describe 'with "data"' do
      it { expect(instance.pluralize 'data').to be == 'data' }
    end # describe
  end # describe

  describe '#singularize' do
    it { expect(instance).to respond_to(:singularize).with(1).argument }

    describe 'with nil' do
      it { expect(instance.singularize nil).to be == '' }
    end # describe

    describe 'with an empty string' do
      it { expect(instance.singularize '').to be == '' }
    end # describe

    describe 'with a word with basic pluralization' do
      it { expect(instance.singularize 'word').to be == 'word' }

      it { expect(instance.singularize 'words').to be == 'word' }
    end # describe

    describe 'with a word ending in "ches"' do
      it { expect(instance.singularize 'torch').to be == 'torch' }

      it { expect(instance.singularize 'torches').to be == 'torch' }
    end # describe

    describe 'with a word ending in "shes"' do
      it { expect(instance.singularize 'fish').to be == 'fish' }

      it { expect(instance.singularize 'fishes').to be == 'fish' }
    end # describe

    describe 'with a word ending in "sses"' do
      it { expect(instance.singularize 'truss').to be == 'truss' }

      it { expect(instance.singularize 'trusses').to be == 'truss' }
    end # describe

    describe 'with a word ending in "xes"' do
      it { expect(instance.singularize 'box').to be == 'box' }

      it { expect(instance.singularize 'boxes').to be == 'box' }
    end # describe

    describe 'with a word ending in "zes"' do
      it { expect(instance.singularize 'buzz').to be == 'buzz' }

      it { expect(instance.singularize 'buzzes').to be == 'buzz' }
    end # describe

    describe 'with a word ending in a consonant followed by "ies"' do
      it { expect(instance.singularize 'winery').to be == 'winery' }

      it { expect(instance.singularize 'wineries').to be == 'winery' }
    end # describe

    describe 'with a word ending in a consonant followed by "oes"' do
      it { expect(instance.singularize 'antihero').to be == 'antihero' }

      it { expect(instance.singularize 'antiheroes').to be == 'antihero' }
    end # describe

    describe 'with "children"' do
      it { expect(instance.singularize 'child').to be == 'child' }

      it { expect(instance.singularize 'children').to be == 'child' }
    end # describe

    describe 'with "people"' do
      it { expect(instance.singularize 'person').to be == 'person' }

      it { expect(instance.singularize 'people').to be == 'person' }
    end # it

    describe 'with "data"' do
      it { expect(instance.singularize 'data').to be == 'data' }
    end # describe
  end # describe
end # describe
