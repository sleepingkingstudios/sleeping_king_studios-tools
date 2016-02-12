# spec/sleeping_king_studios/tools/hash_tools_spec.rb

require 'sleeping_king_studios/tools/hash_tools'

RSpec.describe SleepingKingStudios::Tools::HashTools do
  include Spec::Examples::HashExamples

  let(:instance) { Object.new.extend described_class }

  describe '#deep_dup' do
    it { expect(instance).to respond_to(:deep_dup).with(1).argument }

    it { expect(described_class).to respond_to(:deep_dup).with(1).argument }

    include_examples 'should create a deep copy of a hash'
  end # describe
end # describe
