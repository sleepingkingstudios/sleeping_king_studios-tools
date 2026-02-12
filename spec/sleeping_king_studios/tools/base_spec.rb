# frozen_string_literal: true

require 'sleeping_king_studios/tools/base'

RSpec.describe SleepingKingStudios::Tools::Base do
  subject(:tool) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  describe '.instance' do
    let(:toolbelt) { SleepingKingStudios::Tools::Toolbelt.global }

    before(:example) { allow(toolbelt.core_tools).to receive(:deprecate) }

    it { expect(described_class).to respond_to(:instance).with(0).arguments }

    it { expect(described_class.instance).to be_a described_class }

    it 'should cache the instance' do
      cached = described_class.instance

      expect(described_class.instance).to be cached
    end

    it 'should print a deprecation warning' do # rubocop:disable RSpec/ExampleLength
      described_class.instance

      expect(toolbelt.core_tools)
        .to have_received(:deprecate)
        .with(
          "#{described_class.name}.instance",
          message: 'Use Toolbelt.instance instead.'
        )
    end
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:toolbelt)
    end
  end

  describe '#toolbelt' do
    let(:expected) { SleepingKingStudios::Tools::Toolbelt.global }

    it { expect(tool.toolbelt).to be expected }

    it { expect(tool).to have_aliased_method(:toolbelt).as(:tools) }

    context 'when initialized with toolbelt: value' do
      let(:toolbelt) { SleepingKingStudios::Tools::Toolbelt.new }
      let(:constructor_options) do
        super().merge(toolbelt:)
      end

      it { expect(tool.toolbelt).to be toolbelt }
    end
  end
end
