# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/initializer'

RSpec.describe SleepingKingStudios::Tools::Toolbox::Initializer do
  subject(:initializer) { described_class.new(&block) }

  let(:counter) { Struct.new(:count).new(0) } # rubocop:disable Lint/StructNewOverride
  let(:block)   { -> { counter.count += 1 } }

  describe '.new' do
    describe 'without a block' do
      let(:error_message) { 'no block given' }

      it 'should raise an exception' do
        expect { described_class.new }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#call' do
    it { expect(initializer).to respond_to(:call).with(0).arguments }

    it 'should call the block' do
      expect { initializer.call }.to change(counter, :count).by(1)
    end

    context 'when called multiple times' do
      it 'should call the block once' do
        expect { 3.times { initializer.call } }.to change(counter, :count).by(1)
      end
    end

    context 'when accessed by multiple threads' do
      let(:block) do
        lambda do
          sleep 1

          counter.count += 1
        end
      end
      let(:threads) do
        Array.new(3) { Thread.new { initializer.call } }
      end

      it 'should synchronize the cached values', :aggregate_failures do
        threads.map(&:join)

        expect(counter.count).to be 1
      end
    end
  end
end
