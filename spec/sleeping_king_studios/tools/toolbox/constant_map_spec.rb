# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/constant_map'

RSpec.describe SleepingKingStudios::Tools::Toolbox::ConstantMap do
  shared_context 'when many constants are defined' do
    let(:constants) do
      {
        GUEST:     'guest',
        PATRON:    'patron',
        LIBRARIAN: 'librarian'
      }
    end
  end

  subject(:constant_map) { described_class.new(constants) }

  let(:constants) { {} }
  let(:instance)  { constant_map }

  it { expect(described_class).to be < Enumerable }

  describe '::new' do
    it { expect(described_class).to respond_to(:new).with(1).argument }

    wrap_context 'when many constants are defined' do
      it { expect(constant_map::GUEST).to be == constants[:GUEST] }

      it { expect(constant_map::PATRON).to be == constants[:PATRON] }

      it { expect(constant_map::LIBRARIAN).to be == constants[:LIBRARIAN] }

      it { expect(constant_map.guest).to be == constants[:GUEST] }

      it { expect(constant_map.patron).to be == constants[:PATRON] }

      it { expect(constant_map.librarian).to be == constants[:LIBRARIAN] }
    end
  end

  describe '#:constant_name' do
    it { expect(instance).not_to respond_to(:guest) }

    wrap_context 'when many constants are defined' do
      it { expect(instance).not_to respond_to(:intruder) }

      it { expect(instance).to respond_to(:guest).with(0).arguments }

      it { expect(instance.guest).to be == constants[:GUEST] }
    end
  end

  describe '#const_defined?' do
    it { expect(instance).to respond_to(:const_defined?).with(1).argument }

    it { expect(instance.const_defined? :GUEST).to be false }

    wrap_context 'when many constants are defined' do
      it { expect(instance.const_defined? :INTRUDER).to be false }

      it { expect(instance.const_defined? :GUEST).to be true }
    end
  end

  describe '#const_get' do
    it { expect(instance).to respond_to(:const_get).with(1).argument }

    it 'should raise an error' do
      expect { instance.const_get :GUEST }.to raise_error NameError
    end

    context 'when many constants are defined' do
      include_context 'when many constants are defined'

      it 'should raise an error' do
        expect { instance.const_get :INTRUDER }.to raise_error NameError
      end

      it { expect(instance.const_get :GUEST).to be == constants[:GUEST] }
    end
  end

  describe '#constants' do
    it { expect(instance).to have_reader(:constants).with_value(be == []) }

    wrap_context 'when many constants are defined' do
      it { expect(instance.constants).to match_array(constants.keys) }
    end
  end

  describe '#each' do
    it { expect(instance).to respond_to(:each).with(0).arguments }

    it { expect(instance.each).to be_a Enumerator }

    it { expect(instance.each.size).to be 0 }

    describe 'with a block' do
      it 'should not yield any constants' do
        yielded = {}

        instance.each { |key, value| yielded[key] = value }

        expect(yielded).to be == {}
      end
    end

    context 'when many constants are defined' do
      include_context 'when many constants are defined'

      it { expect(instance.each).to be_a Enumerator }

      it { expect(instance.each.size).to be constants.size }

      describe 'with a block' do
        it 'should yield the constant names and values' do
          yielded = {}

          instance.each { |key, value| yielded[key] = value }

          expect(yielded).to be == constants
        end
      end
    end
  end

  describe '#each_key' do
    it { expect(instance).to respond_to(:each_key).with(0).arguments }

    it { expect(instance.each_key).to be_a Enumerator }

    it { expect(instance.each_key.size).to be 0 }

    describe 'with a block' do
      it 'should not yield any values' do
        yielded = []

        instance.each_key { |key| yielded << key }

        expect(yielded).to be == []
      end
    end

    context 'when many constants are defined' do
      include_context 'when many constants are defined'

      it { expect(instance.each_key).to be_a Enumerator }

      it { expect(instance.each_key.size).to be constants.size }

      describe 'with a block' do
        it 'should yield the constant names' do
          yielded = []

          instance.each_key { |key| yielded << key }

          expect(yielded).to be == constants.keys
        end
      end
    end
  end

  describe '#each_pair' do
    it { expect(instance).to respond_to(:each_pair).with(0).arguments }

    it { expect(instance.each_pair).to be_a Enumerator }

    it { expect(instance.each_pair.size).to be 0 }

    describe 'with a block' do
      it 'should not yield any constants' do
        yielded = {}

        instance.each_pair { |key, value| yielded[key] = value }

        expect(yielded).to be == {}
      end
    end

    context 'when many constants are defined' do
      include_context 'when many constants are defined'

      it { expect(instance.each_pair).to be_a Enumerator }

      it { expect(instance.each_pair.size).to be constants.size }

      describe 'with a block' do
        it 'should yield the constant names and values' do
          yielded = {}

          instance.each_pair { |key, value| yielded[key] = value }

          expect(yielded).to be == constants
        end
      end
    end
  end

  describe '#each_value' do
    it { expect(instance).to respond_to(:each_value).with(0).arguments }

    it { expect(instance.each_value).to be_a Enumerator }

    it { expect(instance.each_value.size).to be 0 }

    describe 'with a block' do
      it 'should not yield any values' do
        yielded = []

        instance.each_value { |value| yielded << value }

        expect(yielded).to be == []
      end
    end

    context 'when many constants are defined' do
      include_context 'when many constants are defined'

      it { expect(instance.each_value).to be_a Enumerator }

      it { expect(instance.each_value.size).to be constants.size }

      describe 'with a block' do
        it 'should yield the constant values' do
          yielded = []

          instance.each_value { |value| yielded << value }

          expect(yielded).to be == constants.values
        end
      end
    end
  end

  describe '#freeze' do
    shared_examples 'should freeze the constant map' do
      it { expect(instance.freeze).to be instance }

      it 'should not permit changing a constant' do
        instance.freeze

        expect { instance.const_set :GUEST, 'intruder' }
          .to raise_error RuntimeError
      end

      it 'should not permit removing a constant' do
        instance.freeze

        expect { instance.send :remove_const, :GUEST } # rubocop:disable RSpec/RemoveConst
          .to raise_error RuntimeError
      end
    end

    it { expect(instance).to respond_to(:freeze).with(0).arguments }

    include_examples 'should freeze the constant map'

    wrap_context 'when many constants are defined' do
      include_examples 'should freeze the constant map'

      it 'should freeze the constant values' do
        instance.freeze

        const_value = instance::GUEST

        expect { const_value[0..-1] = 'intruder' }
          .to raise_error RuntimeError
      end
    end
  end

  describe '#keys' do
    it { expect(instance).to have_reader(:keys).with_value([]) }

    context 'when many constants are defined' do
      include_context 'when many constants are defined'

      it { expect(instance.keys).to be == constants.keys }
    end
  end

  describe '#to_h' do
    it { expect(instance).to respond_to(:to_h).with(0).arguments }

    it { expect(instance).to have_aliased_method(:to_h).as(:all) }

    it { expect(instance.to_h).to be == {} }

    wrap_context 'when many constants are defined' do
      it { expect(instance.to_h).to be == constants }
    end
  end

  describe '#values' do
    it { expect(instance).to have_reader(:values).with_value([]) }

    context 'when many constants are defined' do
      include_context 'when many constants are defined'

      it { expect(instance.values).to be == constants.values }
    end
  end
end
