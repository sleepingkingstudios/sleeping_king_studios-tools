# frozen_string_literal: true

require 'sleeping_king_studios/tools/base'

RSpec.describe SleepingKingStudios::Tools::Base do
  describe '.instance' do
    it { expect(described_class).to respond_to(:instance).with(0).arguments }

    it { expect(described_class.instance).to be_a described_class }

    it 'should cache the instance' do
      cached = described_class.instance

      expect(described_class.instance).to be cached
    end
  end
end
