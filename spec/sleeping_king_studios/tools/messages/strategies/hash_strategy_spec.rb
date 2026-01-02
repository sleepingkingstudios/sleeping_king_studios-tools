# frozen_string_literal: true

require 'sleeping_king_studios/tools/messages/strategies/hash_strategy'

RSpec.describe SleepingKingStudios::Tools::Messages::Strategies::HashStrategy do
  subject(:strategy) { described_class.new(templates) }

  let(:templates) { {} }
  let(:launch_status) do
    lambda do |parameters: {}, ready: false, **|
      str = +'rocket'
      str << ' ' << parameters[:name] if parameters.key?(:name)
      str << (ready ? ' is' : ' is not')
      str << ' ready to launch'
      str.freeze
    end
  end

  describe '.new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#call' do
    deferred_examples 'should handle an invalid key' do
      context 'when the key does not match a template' do
        let(:key) do
          original = super()
          invalid  = original.to_s.sub(/\w+\z/, 'invalid_key')

          original.is_a?(Symbol) ? invalid.to_sym : invalid
        end

        it { expect(call_strategy).to be == missing_template_message }
      end
    end

    deferred_examples 'should return the matching message' do
      include_deferred 'should handle an invalid key'

      context 'when the key matches a template' do
        it { expect(call_strategy).to be == expected }
      end
    end

    let(:key)        { 'base_key' }
    let(:options)    { {} }
    let(:scoped_key) { [options[:scope], key].compact.join('.') }
    let(:missing_template_message) do
      "Message missing: #{scoped_key}"
    end

    define_method :call_strategy do
      strategy.call(key, **options)
    end

    it 'should define the method' do
      expect(strategy)
        .to respond_to(:call)
        .with(1).argument
        .and_keywords(:parameters, :scope)
        .and_any_keywords
    end

    describe 'with key: a String' do
      include_deferred 'should handle an invalid key'
    end

    describe 'with key: a Symbol' do
      let(:key) { super().to_sym }

      include_deferred 'should handle an invalid key'
    end

    describe 'with key: a scoped value' do
      let(:key) { "errors.messages.#{super()}" }

      include_deferred 'should handle an invalid key'
    end

    describe 'with options: value' do
      let(:options) { super().merge(ready: true) }

      include_deferred 'should handle an invalid key'
    end

    describe 'with parameters: value' do
      let(:parameters) do
        {
          name: 'Hellhound IV',
          fuel: 1_000
        }
      end
      let(:options) { super().merge(parameters:) }

      include_deferred 'should handle an invalid key'
    end

    describe 'with scope: value' do
      let(:options) { super().merge(scope: 'custom.scope') }

      include_deferred 'should handle an invalid key'

      describe 'with key: a scoped value' do
        let(:key) { "errors.messages.#{super()}" }

        include_deferred 'should handle an invalid key'
      end
    end

    context 'when initialized with templates: value' do
      let(:templates) do
        templates = {}
        templates['module_name'] = 'Console Space Program'
        templates['messages.errors.failure'] = 'not going to space'
        templates['messages.rockets.launch_status'] = launch_status
        templates
      end
      let(:key)      { 'module_name' }
      let(:expected) { 'Console Space Program' }

      include_deferred 'should return the matching message'

      describe 'with a scoped key' do
        let(:key)      { 'messages.rockets.launch_status' }
        let(:expected) { 'rocket is not ready to launch' }

        include_deferred 'should return the matching message'

        describe 'with parameters: value' do
          let(:parameters) do
            {
              name: 'Hellhound IV',
              fuel: 1_000
            }
          end
          let(:options)  { super().merge(parameters:) }
          let(:expected) { 'rocket Hellhound IV is not ready to launch' }

          include_deferred 'should return the matching message'

          describe 'with options: value' do # rubocop:disable RSpec/NestedGroups
            let(:options)  { super().merge(ready: true) }
            let(:expected) { 'rocket Hellhound IV is ready to launch' }

            include_deferred 'should return the matching message'
          end
        end

        describe 'with options: value' do
          let(:options)  { super().merge(ready: true) }
          let(:expected) { 'rocket is ready to launch' }

          include_deferred 'should return the matching message'
        end
      end

      describe 'with scope: value' do
        let(:key)      { 'failure' }
        let(:scope)    { 'messages.errors' }
        let(:options)  { super().merge(scope:) }
        let(:expected) { 'not going to space' }

        include_deferred 'should return the matching message'

        describe 'with a scoped key' do
          let(:key) { 'errors.failure' }
          let(:scope) { 'messages' }

          include_deferred 'should return the matching message'
        end
      end
    end
  end

  describe '#templates' do
    include_examples 'should define reader', :templates, -> { be_a Hash }

    context 'when initialized with templates: an empty Hash' do
      let(:templates) { {} }

      it { expect(strategy.templates).to be == {} }

      it { expect(strategy.templates).to be_frozen }
    end

    context 'when initialized with templates: a Hash with String keys' do
      let(:templates) do
        templates = {}
        templates['module_name'] = 'Console Space Program'
        templates['messages.errors.failure'] = 'not going to space'
        templates['messages.rockets.launch_status'] = launch_status
        templates
      end

      it { expect(strategy.templates).to be == templates }

      it { expect(strategy.templates).to be_frozen }
    end

    context 'when initialized with templates: a Hash with Symbol keys' do
      let(:templates) do
        templates = {}
        templates[:module_name] = 'Console Space Program'
        templates[:'messages.errors.failure'] = 'not going to space'
        templates[:'messages.rockets.launch_status'] = launch_status
        templates
      end
      let(:expected) do
        templates.transform_keys(&:to_s)
      end

      it { expect(strategy.templates).to be == expected }

      it { expect(strategy.templates).to be_frozen }
    end

    context 'when initialized with templates: a Hash with nested String keys' do
      let(:templates) do
        templates = {
          'messages'    => {
            'errors'  => {
              'failure' => 'not going to space'
            },
            'rockets' => {
              'launch_status' => launch_status
            }
          },
          'module_name' => 'Console Space Program'
        }
        templates
      end
      let(:expected) do
        templates = {}
        templates['module_name'] = 'Console Space Program'
        templates['messages.errors.failure'] = 'not going to space'
        templates['messages.rockets.launch_status'] = launch_status
        templates
      end

      it { expect(strategy.templates).to be == expected }

      it { expect(strategy.templates).to be_frozen }
    end

    context 'when initialized with templates: a Hash with nested Symbol keys' do
      let(:templates) do
        templates = {
          messages:    {
            errors:  {
              failure: 'not going to space'
            },
            rockets: {
              launch_status: launch_status
            }
          },
          module_name: 'Console Space Program'
        }
        templates
      end
      let(:expected) do
        templates = {}
        templates['module_name'] = 'Console Space Program'
        templates['messages.errors.failure'] = 'not going to space'
        templates['messages.rockets.launch_status'] = launch_status
        templates
      end

      it { expect(strategy.templates).to be == expected }

      it { expect(strategy.templates).to be_frozen }
    end
  end
end
