# spec/sleeping_king_studios/tools/toolbox/constant_map_spec.rb

require 'sleeping_king_studios/tools/toolbox/constant_map'

RSpec.describe SleepingKingStudios::Tools::Toolbox::ConstantMap do
  shared_context 'when many constants are defined' do
    let(:constants) do
      {
        :GUEST     => 'guest',
        :PATRON    => 'patron',
        :LIBRARIAN => 'librarian'
      } # end hash
    end # let
  end # shared_context

  let(:constants) { {} }
  let(:instance)  { described_class.new constants }

  describe '::new' do
    it { expect(described_class).to respond_to(:new).with(1).argument }

    wrap_context 'when many constants are defined' do
      it 'should define the constants' do
        instance = described_class.new(constants)

        expect(instance::GUEST).to     be == constants[:GUEST]
        expect(instance::PATRON).to    be == constants[:PATRON]
        expect(instance::LIBRARIAN).to be == constants[:LIBRARIAN]
      end # it
    end # wrap_context
  end # describe

  describe '#all' do
    it { expect(instance).to respond_to(:all).with(0).arguments }

    it { expect(instance.all).to be == {} }

    wrap_context 'when many constants are defined' do
      it { expect(instance.all).to be == constants }
    end # wrap_context
  end # describe

  describe '#const_defined?' do
    it { expect(instance).to respond_to(:const_defined?).with(1).argument }

    it { expect(instance.const_defined? :GUEST).to be false }

    wrap_context 'when many constants are defined' do
      it { expect(instance.const_defined? :INTRUDER).to be false }

      it { expect(instance.const_defined? :GUEST).to be true }
    end # wrap_context
  end # describe

  describe '#const_get' do
    it { expect(instance).to respond_to(:const_get).with(1).argument }

    it 'should raise an error' do
      expect { instance.const_get :GUEST }.to raise_error NameError
    end # it

    wrap_context 'when many constants are defined' do
      it 'should raise an error' do
        expect { instance.const_get :INTRUDER }.to raise_error NameError
      end # it

      it { expect(instance.const_get :GUEST).to be == constants[:GUEST] }
    end # wrap_context
  end # describe

  describe '#constants' do
    it { expect(instance).to have_reader(:constants).with_value(be == []) }

    wrap_context 'when many constants are defined' do
      it { expect(instance.constants).to be == constants.keys }
    end # wrap_context
  end # describe

  describe '#each' do
    it { expect(instance).to respond_to(:each).with(0).arguments.and_a_block }

    it 'should not yield any constants' do
      yielded = {}

      instance.each { |key, value| yielded[key] = value }

      expect(yielded).to be == {}
    end # it

    wrap_context 'when many constants are defined' do
      it 'should yield the constant names and values' do
        yielded = {}

        instance.each { |key, value| yielded[key] = value }

        expect(yielded).to be == constants
      end # it
    end # wrap_context
  end # describe

  describe '#freeze' do
    shared_examples 'should freeze the constant map' do
      it 'should freeze the constant map' do
        expect(instance.freeze).to be instance

        expect { instance.send :remove_const, :GUEST }.
          to raise_error RuntimeError

        expect { instance.const_set :GUEST, 'intruder' }.
          to raise_error RuntimeError
      end # it
    end # method shared_examples

    it { expect(instance).to respond_to(:freeze).with(0).arguments }

    include_examples 'should freeze the constant map'

    wrap_context 'when many constants are defined' do
      include_examples 'should freeze the constant map'

      it 'should freeze the constant values' do
        instance.freeze

        const_value = instance::GUEST

        expect { const_value[0..-1] = 'intruder' }.
          to raise_error RuntimeError
      end # it
    end # method wrap_context
  end # describe

  describe '#method_missing' do
    it { expect { instance.guest }.to raise_error NoMethodError }

    wrap_context 'when many constants are defined' do
      it { expect { instance.intruder }.to raise_error NoMethodError }

      it { expect(instance.guest).to be == constants[:GUEST] }

      it 'should define the method' do
        instance.guest

        expect(instance.method(:guest)).to be_a Method
      end # it
    end # wrap_context
  end # describe

  describe '#respond_to_missing?' do
    it { expect(instance.respond_to? :guest).to be false }

    wrap_context 'when many constants are defined' do
      it { expect(instance.respond_to? :intruder).to be false }

      it { expect(instance.respond_to? :guest).to be true }
    end # wrap_context
  end # describe
end # describe
