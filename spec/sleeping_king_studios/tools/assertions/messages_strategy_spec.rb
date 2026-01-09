# frozen_string_literal: true

require 'sleeping_king_studios/tools/assertions/messages_strategy'

RSpec.describe SleepingKingStudios::Tools::Assertions::MessagesStrategy do
  subject(:strategy) { described_class.new }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do
    let(:key)        { 'base_key' }
    let(:options)    { { scope: 'sleeping_king_studios.tools.assertions' } }
    let(:scoped_key) { [options[:scope], key].compact.join('.') }
    let(:missing_template_message) do
      "Message missing: #{scoped_key}"
    end

    define_method :call_strategy do
      strategy.call(key, **options)
    end

    describe 'with a non-matching key' do
      let(:key) { 'magic_smoke_is_escaping' }

      it { expect(call_strategy).to be == missing_template_message }
    end

    describe 'with a matching key' do
      let(:key)      { 'blank' }
      let(:expected) { 'must be nil or empty' }

      it { expect(call_strategy).to be == expected }

      describe 'with as: value' do
        let(:as)       { 'value' }
        let(:options)  { super().merge(as:) }
        let(:expected) { "#{as} #{super()}" }

        it { expect(call_strategy).to be == expected }
      end
    end

    describe 'with a matching key with parameters' do
      let(:key)        { 'instance_of' }
      let(:parameters) { { expected: Array } }
      let(:options)    { super().merge(parameters:) }
      let(:expected)   { 'is not an instance of Array' }

      it { expect(call_strategy).to be == expected }

      describe 'with as: value' do
        let(:as)       { 'value' }
        let(:options)  { super().merge(as:) }
        let(:expected) { "#{as} #{super()}" }

        it { expect(call_strategy).to be == expected }
      end
    end
  end

  describe '#templates' do
    let(:expected_keys) do
      scope = 'sleeping_king_studios.tools.assertions'

      %w[
        blank
        block
        boolean
        class
        class_or_module
        exclusion
        exclusion_range
        inclusion
        inclusion_range
        inherit_from
        instance_of
        instance_of_anonymous
        matches
        matches_proc
        matches_regexp
        name
        nil
        not_nil
        presence
      ]
        .map { |key| "#{scope}.#{key}" }
    end

    it { expect(strategy.templates).to be_a Hash }

    it 'should define the assertions messages', :aggregate_failures do
      expected_keys.each do |key|
        expect(strategy.templates).to have_key key
      end
    end
  end
end
