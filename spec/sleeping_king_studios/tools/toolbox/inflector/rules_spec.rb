# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/inflector/rules'

RSpec.describe SleepingKingStudios::Tools::Toolbox::Inflector::Rules do
  subject(:rules) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  describe '.new' do
    describe 'with irregular_words: Hash' do
      let(:irregular_words) { { 'goose' => 'geese' } }
      let(:reversed)        { { 'geese' => 'goose' } }
      let(:constructor_options) do
        super().merge(irregular_words: irregular_words)
      end

      it { expect(rules.irregular_words).to be == irregular_words }

      it { expect(rules.irregular_words_reversed).to be == reversed }
    end

    describe 'with plural_rules: Array' do
      let(:plural_rules) do
        [
          [/s$/, 's'],
          [/$/, 's']
        ]
      end
      let(:constructor_options) do
        super().merge(plural_rules: plural_rules)
      end

      it { expect(rules.plural_rules).to be == plural_rules }
    end

    describe 'with singular_rules: Array' do
      let(:singular_rules) do
        [
          [/s$/, '']
        ]
      end
      let(:constructor_options) do
        super().merge(singular_rules: singular_rules)
      end

      it { expect(rules.singular_rules).to be == singular_rules }
    end

    describe 'with uncountable_words: Array' do
      let(:uncountable_words) { %w[metadata] }
      let(:constructor_options) do
        super().merge(uncountable_words: uncountable_words)
      end

      it { expect(rules.uncountable_words).to be_a Set }

      it { expect(rules.uncountable_words.to_a).to be == uncountable_words }
    end
  end

  describe '#define_irregular_word' do
    let(:singular) { 'ox' }
    let(:plural)   { 'oxen' }
    let(:expected) do
      described_class.new.irregular_words.merge(singular => plural)
    end
    let(:reversed) do
      described_class.new.irregular_words_reversed.merge(plural => singular)
    end

    it { expect(rules).to respond_to(:define_irregular_word).with(2).arguments }

    it { expect(rules.define_irregular_word singular, plural).to be rules }

    it 'should add the words to #irregular_words' do
      expect { rules.define_irregular_word(singular, plural) }
        .to change(rules, :irregular_words)
        .to be == expected
    end

    it 'should add the words to #irregular_words_reversed' do
      expect { rules.define_irregular_word(singular, plural) }
        .to change(rules, :irregular_words_reversed)
        .to be == reversed
    end

    describe 'with plural: nil' do
      it 'should raise an error' do
        expect { rules.define_irregular_word(singular, nil) }
          .to raise_error ArgumentError, "word can't be blank"
      end
    end

    describe 'with plural: an Object' do
      it 'should raise an error' do
        expect { rules.define_irregular_word(singular, Object.new.freeze) }
          .to raise_error ArgumentError, 'word must be a String'
      end
    end

    describe 'with plural: an empty string' do
      it 'should raise an error' do
        expect { rules.define_irregular_word(singular, '') }
          .to raise_error ArgumentError, "word can't be blank"
      end
    end

    describe 'with singular: nil' do
      it 'should raise an error' do
        expect { rules.define_irregular_word(nil, plural) }
          .to raise_error ArgumentError, "word can't be blank"
      end
    end

    describe 'with singular: an Object' do
      it 'should raise an error' do
        expect { rules.define_irregular_word(Object.new.freeze, plural) }
          .to raise_error ArgumentError, 'word must be a String'
      end
    end

    describe 'with singular: an empty string' do
      it 'should raise an error' do
        expect { rules.define_irregular_word('', plural) }
          .to raise_error ArgumentError, "word can't be blank"
      end
    end
  end

  describe '#define_plural_rule' do
    let(:pattern) { /ox$/ }
    let(:replace) { 'oxen' }
    let(:expected) do
      described_class.new.plural_rules.unshift([pattern, replace])
    end

    it { expect(rules).to respond_to(:define_plural_rule).with(2).arguments }

    it { expect(rules.define_plural_rule pattern, replace).to be rules }

    it 'should prepend the rule to #plural_rules' do
      expect { rules.define_plural_rule(pattern, replace) }
        .to change(rules, :plural_rules)
        .to be == expected
    end

    describe 'with pattern: nil' do
      it 'should raise an error' do
        expect { rules.define_plural_rule(nil, replace) }
          .to raise_error ArgumentError, "pattern can't be blank"
      end
    end

    describe 'with pattern: an Object' do
      it 'should raise an error' do
        expect { rules.define_plural_rule(Object.new.freeze, replace) }
          .to raise_error ArgumentError, 'pattern must be a Regexp'
      end
    end

    describe 'with replace: nil' do
      it 'should raise an error' do
        expect { rules.define_plural_rule(pattern, nil) }
          .to raise_error ArgumentError, "replace can't be blank"
      end
    end

    describe 'with replace: an Object' do
      it 'should raise an error' do
        expect { rules.define_plural_rule(pattern, Object.new.freeze) }
          .to raise_error ArgumentError, 'replace must be a String'
      end
    end

    describe 'with replace: an empty string' do
      it 'should raise an error' do
        expect { rules.define_plural_rule(pattern, '') }
          .to raise_error ArgumentError, "replace can't be blank"
      end
    end
  end

  describe '#define_singular_rule' do
    let(:pattern) { /oxen$/ }
    let(:replace) { 'ox' }
    let(:expected) do
      described_class.new.singular_rules.unshift([pattern, replace])
    end

    it { expect(rules).to respond_to(:define_singular_rule).with(2).arguments }

    it { expect(rules.define_singular_rule pattern, replace).to be rules }

    it 'should prepend the rule to #singular_rules' do
      expect { rules.define_singular_rule(pattern, replace) }
        .to change(rules, :singular_rules)
        .to be == expected
    end

    describe 'with pattern: nil' do
      it 'should raise an error' do
        expect { rules.define_singular_rule(nil, replace) }
          .to raise_error ArgumentError, "pattern can't be blank"
      end
    end

    describe 'with pattern: an Object' do
      it 'should raise an error' do
        expect { rules.define_singular_rule(Object.new.freeze, replace) }
          .to raise_error ArgumentError, 'pattern must be a Regexp'
      end
    end

    describe 'with replace: nil' do
      it 'should raise an error' do
        expect { rules.define_singular_rule(pattern, nil) }
          .to raise_error ArgumentError, "replace can't be blank"
      end
    end

    describe 'with replace: an Object' do
      it 'should raise an error' do
        expect { rules.define_singular_rule(pattern, Object.new.freeze) }
          .to raise_error ArgumentError, 'replace must be a String'
      end
    end

    describe 'with replace: an empty string' do
      it 'should raise an error' do
        expect { rules.define_singular_rule(pattern, '') }
          .to raise_error ArgumentError, "replace can't be blank"
      end
    end
  end

  describe '#define_uncountable_word' do
    let(:word) { 'metadata' }
    let(:expected) do
      described_class.new.uncountable_words + [word]
    end

    it 'should define the method' do
      expect(rules).to respond_to(:define_uncountable_word).with(1).argument
    end

    it { expect(rules.define_uncountable_word word).to be rules }

    it 'should add the word to #uncountable_words' do
      expect { rules.define_uncountable_word(word) }
        .to change(rules, :uncountable_words)
        .to be == expected
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { rules.define_uncountable_word(nil) }
          .to raise_error ArgumentError, "word can't be blank"
      end
    end

    describe 'with an Object' do
      it 'should raise an error' do
        expect { rules.define_uncountable_word(Object.new.freeze) }
          .to raise_error ArgumentError, 'word must be a String'
      end
    end

    describe 'with an empty string' do
      it 'should raise an error' do
        expect { rules.define_uncountable_word('') }
          .to raise_error ArgumentError, "word can't be blank"
      end
    end
  end

  describe '#inspect' do
    let(:expected) do
      '#<SleepingKingStudios::Tools::Toolbox::Inflector::Rules:' \
      "#{rules.object_id}>"
    end

    it { expect(rules.inspect).to be == expected }
  end

  describe '#irregular_words' do
    let(:expected) do
      {
        'child'  => 'children',
        'person' => 'people'
      }
    end

    it { expect(rules).to respond_to(:irregular_words).with(0).arguments }

    it { expect(rules.irregular_words).to be == expected }
  end

  describe '#irregular_words_reversed' do
    let(:expected) do
      {
        'children' => 'child',
        'people'   => 'person'
      }
    end

    it 'should define the reader' do
      expect(rules).to respond_to(:irregular_words_reversed).with(0).arguments
    end

    it { expect(rules.irregular_words_reversed).to be == expected }
  end

  describe '#plural_rules' do
    let(:expected) do
      [
        [/([^aeiouy])y$/i, '\1ies'],
        [/([^aeiouy]o)$/i, '\1es'],
        [/(ss|[xz]|[cs]h)$/i, '\1es'],
        [/s$/i, 's'],
        [/$/, 's']
      ]
    end

    it { expect(rules).to respond_to(:plural_rules).with(0).arguments }

    it { expect(rules.plural_rules).to be == expected }
  end

  describe '#singular_rules' do
    let(:expected) do
      [
        [/([^aeiouy])ies$/i, '\1y'],
        [/([^aeiouy]o)es$/, '\1'],
        [/(ss|[sxz]|[cs]h)es$/, '\1'],
        [/ss$/i, 'ss'],
        [/s$/i, '']
      ]
    end

    it { expect(rules).to respond_to(:singular_rules).with(0).arguments }

    it { expect(rules.singular_rules).to be == expected }
  end

  describe '#uncountable_words' do
    let(:expected) { %w[data] }

    it { expect(rules).to respond_to(:uncountable_words).with(0).arguments }

    it { expect(rules.uncountable_words).to be_a Set }

    it { expect(rules.uncountable_words.to_a).to be == expected }
  end
end
