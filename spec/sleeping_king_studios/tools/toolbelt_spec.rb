# spec/sleeping_king_studios/tools/toolbelt_spec.rb

require 'sleeping_king_studios/tools/toolbelt'

RSpec.describe SleepingKingStudios::Tools::Toolbelt do
  let(:instance) { described_class.new }

  %w(array hash integer object string).each do |name|
    describe "##{name}" do
      let(:namespace) { SleepingKingStudios::Tools }
      let(:tools)     { namespace.const_get("#{name.capitalize}Tools") }

      it { expect(instance.__send__ name).to be tools }
    end # describe
  end # each
end # describe
