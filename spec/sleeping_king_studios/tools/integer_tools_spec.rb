# spec/sleeping_king_studios/tools/integer_tools_spec.rb

require 'spec_helper'

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

  describe '#integer?' do
    it { expect(instance).to respond_to(:integer?).with(1).argument }

    it { expect(described_class).to respond_to(:integer?).with(1).argument }

    describe 'with nil' do
      it { expect(described_class.integer? nil).to be false }
    end # describe

    describe 'with an object' do
      it { expect(described_class.integer? Object.new).to be false }
    end # describe

    describe 'with a string' do
      it { expect(described_class.integer? 'greetings,programs').to be false }
    end # describe

    describe 'with an integer' do
      it { expect(described_class.integer? 42).to be true }
    end # describe

    describe 'with a large integer' do
      it { expect(described_class.integer? 2 ** 72).to be true }
    end # describe

    describe 'with an empty array' do
      it { expect(described_class.integer? []).to be false }
    end # describe

    describe 'with a non-empty array' do
      it { expect(described_class.integer? %w(ichi ni san)).to be false }
    end # describe

    describe 'with an empty hash' do
      it { expect(described_class.integer?({})).to be false }
    end # describe

    describe 'with a non-empty hash' do
      it { expect(described_class.integer?({ :greetings => 'programs' })).to be false }
    end # describe
  end # describe

  describe '#pluralize' do
    let(:single) { 'cow' }

    it { expect(instance).to respond_to(:pluralize).with(2..3).arguments }

    it { expect(described_class).to respond_to(:pluralize).with(2..3).arguments }

    describe 'with a count and a singular term' do
      let(:plural) { 'cows' }

      describe 'with zero items' do
        it { expect(described_class.pluralize 0, single).to be == plural }
      end # describe

      describe 'with one item' do
        it { expect(described_class.pluralize 1, single).to be == single }
      end # describe

      describe 'with many items' do
        it { expect(described_class.pluralize 3, single).to be == plural }
      end # describe
    end # describe

    describe 'with a count and a singular and plural term' do
      let(:plural) { 'kine' }

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

  describe '#romanize' do
    it { expect(instance).to respond_to(:romanize).with(1).argument }

    it { expect(described_class).to respond_to(:romanize).with(1).argument }

    describe 'with an integer <= 0' do
      it 'raises an error' do
        expect { instance.romanize(0) }.to raise_error RangeError, /within range 1 to 4999/
      end # it
    end # describe

    describe 'with an integer <= 5000' do
      it 'raises an error' do
        expect { instance.romanize(5000) }.to raise_error RangeError, /within range 1 to 4999/
      end # it
    end # describe

    expected_values = {
      1 => 'I',
      2 => 'II',
      3 => 'III',
      4 => 'IV',
      5 => 'V',
      6 => 'VI',
      7 => 'VII',
      8 => 'VIII',
      9 => 'IX',
      10 => 'X',
      11 => 'XI',
      12 => 'XII',
      13 => 'XIII',
      14 => 'XIV',
      15 => 'XV',
      16 => 'XVI',
      17 => 'XVII',
      18 => 'XVIII',
      19 => 'XIX',
      20 => 'XX',
      30 => 'XXX',
      40 => 'XL',
      49 => 'XLIX',
      50 => 'L',
      60 => 'LX',
      70 => 'LXX',
      80 => 'LXXX',
      90 => 'XC',
      99 => 'XCIX',
      100 => 'C',
      200 => 'CC',
      300 => 'CCC',
      400 => 'CD',
      499 => 'CDXCIX',
      500 => 'D',
      600 => 'DC',
      700 => 'DCC',
      800 => 'DCCC',
      900 => 'CM',
      999 => 'CMXCIX',
      1000 => 'M',
      2000 => 'MM',
      3000 => 'MMM',
      4000 => 'MMMM',
      4999 => 'MMMMCMXCIX'
    } # end hash

    expected_values.each do |integer, romanization|
      it "converts #{integer} to '#{romanization}'" do
        expect(instance.romanize integer).to be == romanization
      end # it
    end # each

    describe 'with :additive => true' do
      expected_values = {
        1 => 'I',
        2 => 'II',
        3 => 'III',
        4 => 'IIII',
        5 => 'V',
        6 => 'VI',
        7 => 'VII',
        8 => 'VIII',
        9 => 'VIIII',
        10 => 'X',
        14 => 'XIIII',
        19 => 'XVIIII',
        40 => 'XXXX',
        50 => 'L',
        49 => 'XXXXVIIII',
        90 => 'LXXXX',
        99 => 'LXXXXVIIII',
        100 => 'C',
        400 => 'CCCC',
        499 => 'CCCCLXXXXVIIII',
        500 => 'D',
        900 => 'DCCCC',
        999 => 'DCCCCLXXXXVIIII',
        1000 => 'M',
        4000 => 'MMMM',
        4999 => 'MMMMDCCCCLXXXXVIIII'
      } # end expected values

      expected_values.each do |integer, romanization|
        it "converts #{integer} to '#{romanization}'" do
          expect(instance.romanize integer, :additive => true).to be == romanization
        end # it
      end # each
    end # describe
  end # describe
end # describe
