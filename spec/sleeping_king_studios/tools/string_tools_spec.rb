# spec/sleeping_king_studios/tools/string_tools_spec.rb

require 'spec_helper'

require 'sleeping_king_studios/tools/string_tools'

RSpec.describe SleepingKingStudios::Tools::StringTools do
  let(:instance) { Object.new.extend described_class }

  describe '#pluralize' do
    let(:single) { 'cow' }
    let(:plural) { 'kine' }

    it { expect(instance).to respond_to(:pluralize).with(3).arguments }

    it { expect(described_class).to respond_to(:pluralize).with(3).arguments }

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
