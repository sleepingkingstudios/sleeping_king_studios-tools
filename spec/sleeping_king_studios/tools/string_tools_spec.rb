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
end # describe
