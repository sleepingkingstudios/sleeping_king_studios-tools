# spec/sleeping_king_studios/tools/toolbelt_spec.rb

require 'sleeping_king_studios/tools/toolbelt'

RSpec.describe SleepingKingStudios::Tools::Toolbelt do
  let(:instance) { described_class.new }

  describe '::instance' do
    it { expect(described_class).to have_reader(:instance) }

    it 'should return an instance' do
      klass = Kernel.instance_method(:class).bind(described_class.instance).call

      expect(klass).to be described_class
    end # it

    it 'should cache the instance' do
      previous = described_class.instance

      expect(described_class.instance.equal?(previous)).to be true
    end # it
  end # describe

  %w(array core hash integer object string).each do |name|
    describe "##{name}" do
      let(:namespace) { SleepingKingStudios::Tools }
      let(:tools)     { namespace.const_get("#{name.capitalize}Tools") }

      it { expect(instance.__send__ name).to be tools }
    end # describe
  end # each
end # describe
