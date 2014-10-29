# spec/sleeping_king_studios/tools/integer_tools_spec.rb

require 'sleeping_king_studios/tools/integer_tools'

RSpec.describe SleepingKingStudios::Tools::IntegerTools do
  let(:instance) { Object.new.extend described_class }

  describe '#count_digits' do
    it { expect(instance).to respond_to(:count_digits).with(1).argument }

    it { expect(described_class).to respond_to(:count_digits).with(1).argument }

    describe 'with a positive integer with 1 digit' do
      it { expect(instance.count_digits 3).to be == 1 }
    end # describe

    describe 'with a positive integer with 2 digits' do
      it { expect(instance.count_digits 14).to be == 2 }
    end # describe

    describe 'with a positive integer with 5 digits' do
      it { expect(instance.count_digits 15926).to be == 5 }
    end # describe

    describe 'with a negative integer with 1 digit' do
      it { expect(instance.count_digits -3).to be == 1 }
    end # describe

    describe 'with a negative integer with 2 digits' do
      it { expect(instance.count_digits -14).to be == 2 }
    end # describe

    describe 'with a negative integer with 5 digits' do
      it { expect(instance.count_digits -15926).to be == 5 }
    end # describe

    describe 'with base => 2' do
      describe 'with a 1-bit number' do
        it { expect(instance.count_digits 1, :base => 2).to be == 1 }
      end # describe

      describe 'with an 8-bit number' do
        it { expect(instance.count_digits 189, :base => 2).to be == 8 }
      end # describe
    end # describe

    describe 'with base => 16' do
      describe 'with a hexadecimal number with 1 digit' do
        it { expect(instance.count_digits 13, :base => 16).to be == 1 }
      end # describe

      describe 'with a hexadecimal number with 6 digits' do
        it { expect(instance.count_digits 16724838, :base => 16).to be == 6 }
      end # describe
    end # describe
  end # describe

  describe '#digits' do
    it { expect(instance).to respond_to(:digits).with(1).argument }

    it { expect(described_class).to respond_to(:digits).with(1).argument }

    describe 'with a positive integer with 1 digit' do
      it { expect(instance.digits 3).to be == %w(3) }
    end # describe

    describe 'with a positive integer with 2 digits' do
      it { expect(instance.digits 14).to be == %w(1 4) }
    end # describe

    describe 'with a positive integer with 5 digits' do
      it { expect(instance.digits 15926).to be == %w(1 5 9 2 6) }
    end # describe

    describe 'with a negative integer with 1 digit' do
      it { expect(instance.digits -3).to be == %w(- 3) }
    end # describe

    describe 'with a negative integer with 2 digits' do
      it { expect(instance.digits -14).to be == %w(- 1 4) }
    end # describe

    describe 'with a negative integer with 5 digits' do
      it { expect(instance.digits -15926).to be == %w(- 1 5 9 2 6) }
    end # describe

    describe 'with base => 2' do
      describe 'with a 1-bit number' do
        it { expect(instance.digits 1, :base => 2).to be == %w(1) }
      end # describe

      describe 'with an 8-bit number' do
        it { expect(instance.digits 189, :base => 2).to be == %w(1 0 1 1 1 1 0 1) }
      end # describe
    end # describe

    describe 'with base => 16' do
      describe 'with a hexadecimal number with 1 digit' do
        it { expect(instance.digits 13, :base => 16).to be == %w(d) }
      end # describe

      describe 'with a hexadecimal number with 6 digits' do
        it { expect(instance.digits 16724838, :base => 16).to be == %w(f f 3 3 6 6) }
      end # describe
    end # describe
  end # describe
end # describe
