# frozen_string_literal: true

require 'sleeping_king_studios/tools/undefined'

RSpec.describe SleepingKingStudios::Tools::Undefined do
  subject(:undefined) { described_class.new }

  it 'should be immutable' do
    other_module = Module.new

    expect { described_class.include other_module }.to raise_error FrozenError
  end

  describe '#inspect' do
    let(:expected) do
      Object.instance_method(:inspect).bind(undefined).call
    end

    it { expect(undefined.inspect).to be == expected }
  end

  describe '#instance_of?' do
    it { expect(undefined.instance_of?(described_class)).to be true }

    it { expect(undefined.instance_of?(BasicObject)).to be false }

    it { expect(undefined.instance_of?(Object)).to be false }
  end

  describe '#is_a?' do
    it { expect(undefined.is_a?(described_class)).to be true }

    it { expect(undefined.is_a?(BasicObject)).to be true }

    it { expect(undefined.is_a?(Object)).to be false }
  end

  describe '#singleton_class' do
    let(:eigenclass) do
      Object.instance_method(:singleton_class).bind(described_class).call
    end

    it 'should be immutable' do
      other_module = Module.new

      expect { eigenclass.include other_module }.to raise_error FrozenError
    end
  end
end
