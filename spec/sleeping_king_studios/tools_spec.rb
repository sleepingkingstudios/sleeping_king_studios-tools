# frozen_string_literal: true

RSpec.describe SleepingKingStudios::Tools do
  describe '::UNDEFINED' do
    include_examples 'should define constant', :UNDEFINED

    it { expect(described_class::UNDEFINED).to be_a described_class::Undefined }

    it 'should be immutable' do
      expect(
        Object.instance_method(:frozen?).bind(described_class::UNDEFINED).call
      ).to be true
    end
  end

  describe '.gem_path' do
    let(:expected) do
      sep = File::SEPARATOR

      __dir__.sub(/#{sep}spec#{sep}sleeping_king_studios#{sep}?\z/, '')
    end

    include_examples 'should define class reader',
      :gem_path,
      -> { be == expected }
  end

  describe '.initialize' do
    it { expect(described_class).to respond_to(:initialize).with(0).arguments }
  end

  describe '.version' do
    let(:expected) { SleepingKingStudios::Tools::Version.to_gem_version }

    include_examples 'should define class reader',
      :version,
      -> { be == expected }
  end
end
