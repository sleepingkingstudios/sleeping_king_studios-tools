# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/inflector'

RSpec.describe SleepingKingStudios::Tools::Toolbox::Inflector do
  subject(:inflector) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  describe '.new' do
    describe 'with custom rules' do
      let(:rules) { described_class::Rules.new }
      let(:constructor_options) do
        super().merge(rules:)
      end

      it { expect(inflector.rules).to be rules }
    end
  end

  describe '#camelize' do
    shared_examples 'should camelize' do |word, camelized|
      it { expect(inflector.camelize word).to be == camelized }

      it { expect(inflector.camelize word, true).to be == camelized }

      it 'should convert the word to lowerCamelCase' do
        expect(inflector.camelize word, false)
          .to be == downcase_first(camelized)
      end
    end

    def downcase_first(str)
      str[0].downcase + str[1..]
    end

    it { expect(inflector).to respond_to(:camelize).with(1..2).arguments }

    describe 'with nil' do
      it { expect(inflector.camelize nil).to be == '' }
    end

    describe 'with an empty string' do
      it { expect(inflector.camelize '').to be == '' }
    end

    describe 'with a lowercase string' do
      include_examples 'should camelize', 'string', 'String'
    end

    describe 'with a capitalized string' do
      include_examples 'should camelize', 'Symbol', 'Symbol'
    end

    describe 'with an uppercase string' do
      include_examples 'should camelize', 'CONSTANT', 'CONSTANT'
    end

    describe 'with a mixed-case string' do
      include_examples 'should camelize', 'BasicObject', 'BasicObject'
    end

    describe 'with a mixed-case string with underscores' do
      include_examples 'should camelize', 'be_a_BasicObject', 'BeABasicObject'
    end

    describe 'with an underscore-separated string' do
      include_examples 'should camelize', 'date_time', 'DateTime'
    end

    describe 'with an underscore-separated string with digits' do
      include_examples 'should camelize', 'version_3_point_3', 'Version3Point3'
    end

    describe 'with a mixed-case string with digits' do
      include_examples 'should camelize', 'Version3Point3', 'Version3Point3'
    end

    describe 'with a mixed-case string with consecutive capitals' do
      include_examples 'should camelize', 'TCPConnection', 'TCPConnection'
    end

    describe 'with a string with hyphens' do
      include_examples 'should camelize',
        'custom-test-case',
        'CustomTestCase'
    end

    describe 'with a string with consecutive underscores' do
      include_examples 'should camelize',
        '__python_private__',
        'PythonPrivate'
    end

    describe 'with an empty symbol' do
      it { expect(inflector.camelize :'').to be == '' }
    end

    describe 'with a lowercase symbol' do
      include_examples 'should camelize', :integer, 'Integer'
    end
  end

  describe '#pluralize' do
    shared_examples 'should pluralize' do |singular, plural|
      it { expect(inflector.pluralize singular).to be == plural }

      it { expect(inflector.pluralize plural).to be == plural }
    end

    it { expect(inflector).to respond_to(:pluralize).with(1).argument }

    describe 'with nil' do
      it { expect(inflector.pluralize nil).to be == '' }
    end

    describe 'with an empty string' do
      it { expect(inflector.pluralize '').to be == '' }
    end

    describe 'with a word with basic pluralization' do
      include_examples 'should pluralize', 'word', 'words'
    end

    describe 'with a word ending in "ch"' do
      include_examples 'should pluralize', 'torch', 'torches'
    end

    describe 'with a word ending in "sh"' do
      include_examples 'should pluralize', 'fish', 'fishes'
    end

    describe 'with a word ending in "ss"' do
      include_examples 'should pluralize', 'truss', 'trusses'
    end

    describe 'with a word ending in "x"' do
      include_examples 'should pluralize', 'box', 'boxes'
    end

    describe 'with a word ending in "z"' do
      include_examples 'should pluralize', 'buzz', 'buzzes'
    end

    describe 'with a word ending in a consonant followed by "o"' do
      include_examples 'should pluralize', 'halo', 'haloes'
    end

    describe 'with a word ending in a consonant followed by "y"' do
      include_examples 'should pluralize', 'winery', 'wineries'
    end

    describe 'with "child"' do
      include_examples 'should pluralize', 'child', 'children'
    end

    describe 'with "person"' do
      include_examples 'should pluralize', 'person', 'people'
    end

    describe 'with "data"' do
      it { expect(inflector.pluralize 'data').to be == 'data' }
    end
  end

  describe '#rules' do
    it { expect(inflector).to respond_to(:rules).with(0).arguments }

    it { expect(inflector.rules).to be_a described_class::Rules }
  end

  describe '#singularize' do
    shared_examples 'should singularize' do |plural, singular|
      it { expect(inflector.singularize plural).to be == singular }

      it { expect(inflector.singularize singular).to be == singular }
    end

    it { expect(inflector).to respond_to(:singularize).with(1).argument }

    describe 'with nil' do
      it { expect(inflector.singularize nil).to be == '' }
    end

    describe 'with an empty string' do
      it { expect(inflector.singularize '').to be == '' }
    end

    describe 'with a word with basic pluralization' do
      include_examples 'should singularize', 'words', 'word'
    end

    describe 'with a word ending in "ches"' do
      include_examples 'should singularize', 'torches', 'torch'
    end

    describe 'with a word ending in "shes"' do
      include_examples 'should singularize', 'fishes', 'fish'
    end

    describe 'with a word ending in "sses"' do
      include_examples 'should singularize', 'trusses', 'truss'
    end

    describe 'with a word ending in "xes"' do
      include_examples 'should singularize', 'boxes', 'box'
    end

    describe 'with a word ending in "zes"' do
      include_examples 'should singularize', 'buzzes', 'buzz'
    end

    describe 'with a word ending in a consonant followed by "ies"' do
      include_examples 'should singularize', 'wineries', 'winery'
    end

    describe 'with a word ending in a consonant followed by "oes"' do
      include_examples 'should singularize', 'haloes', 'halo'
    end

    describe 'with "children"' do
      include_examples 'should singularize', 'children', 'child'
    end

    describe 'with "people"' do
      include_examples 'should singularize', 'people', 'person'
    end

    describe 'with "data"' do
      it { expect(inflector.singularize 'data').to be == 'data' }
    end
  end

  describe '#underscore' do
    shared_examples 'should underscore' do |word, underscored|
      it { expect(inflector.underscore word).to be == underscored }
    end

    it { expect(inflector).to respond_to(:underscore).with(1).argument }

    describe 'with nil' do
      it { expect(inflector.underscore nil).to be == '' }
    end

    describe 'with an empty string' do
      it { expect(inflector.underscore '').to be == '' }
    end

    describe 'with a lowercase string' do
      include_examples 'should underscore', 'string', 'string'
    end

    describe 'with a capitalized string' do
      include_examples 'should underscore', 'Symbol', 'symbol'
    end

    describe 'with an uppercase string' do
      include_examples 'should underscore', 'CONSTANT', 'constant'
    end

    describe 'with a mixed-case string' do
      include_examples 'should underscore', 'BasicObject', 'basic_object'
    end

    describe 'with a mixed-case string with underscores' do
      include_examples 'should underscore',
        'be_a_BasicObject',
        'be_a_basic_object'
    end

    describe 'with an underscore-separated string' do
      include_examples 'should underscore', 'date_time', 'date_time'
    end

    describe 'with an underscore-separated string with digits' do
      include_examples 'should underscore',
        'version_3_point_3',
        'version_3_point_3'
    end

    describe 'with a mixed-case string with digits' do
      include_examples 'should underscore',
        'Version3Point3',
        'version_3_point_3'
    end

    describe 'with a mixed-case string with consecutive capitals' do
      include_examples 'should underscore', 'TCPConnection', 'tcp_connection'
    end

    describe 'with a string with hyphens' do
      include_examples 'should underscore',
        'custom-test-case',
        'custom_test_case'
    end

    describe 'with a string with consecutive underscores' do
      include_examples 'should underscore',
        '__python_private__',
        'python_private'
    end

    describe 'with an empty symbol' do
      it { expect(inflector.underscore :'').to be == '' }
    end

    describe 'with a capitalized symbol' do
      it { expect(inflector.underscore :Integer).to be == 'integer' }
    end
  end
end
