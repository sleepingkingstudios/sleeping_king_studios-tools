# frozen_string_literal: true

require 'sleeping_king_studios/tools/messages'

RSpec.describe SleepingKingStudios::Tools::Messages do
  subject(:messages) { described_class.new(**constructor_options) }

  let(:registry) { SleepingKingStudios::Tools::Messages::Registry.new }
  let(:constructor_options) do
    { registry: }
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:registry, :toolbelt)
    end
  end

  describe '#message' do
    let(:key)        { 'base_key' }
    let(:options)    { {} }
    let(:scoped_key) { [options[:scope], key].compact.join('.') }
    let(:missing_template_message) do
      "Message missing: #{scoped_key}"
    end

    define_method :generate_message do
      messages.message(key, **options)
    end

    it 'should define the method' do
      expect(messages)
        .to respond_to(:message)
        .with(1).argument
        .and_keywords(:parameters, :scope)
        .and_any_keywords
    end

    describe 'with key: nil' do
      let(:key) { nil }
      let(:error_message) do
        "key can't be blank"
      end

      it 'should raise an exception' do
        expect { generate_message }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with key: an Object' do
      let(:key) { Object.new.freeze }
      let(:error_message) do
        'key is not a String or a Symbol'
      end

      it 'should raise an exception' do
        expect { generate_message }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with key: an empty String' do
      let(:key) { '' }
      let(:error_message) do
        "key can't be blank"
      end

      it 'should raise an exception' do
        expect { generate_message }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with key: an empty Symbol' do
      let(:key) { :'' }
      let(:error_message) do
        "key can't be blank"
      end

      it 'should raise an exception' do
        expect { generate_message }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with key: a String that does not match a strategy' do
      let(:key) { 'cosmos' }

      it { expect(generate_message).to be == missing_template_message }
    end

    describe 'with key: a Symbol that does not match a strategy' do
      let(:key) { :cosmos }

      it { expect(generate_message).to be == missing_template_message }
    end

    context 'when the registry defines many strategies' do
      let(:space_strategy) do
        SleepingKingStudios::Tools::Messages::Strategies::HashStrategy.new(
          {
            space: {
              module_name: 'Console Space Program',
              rockets:     {
                ready_to_launch: lambda do |parameters: {}, ready: false, **|
                  str = +'rocket'
                  str << ' ' << parameters[:name] if parameters.key?(:name)
                  str << (ready ? ' is' : ' is not')
                  str << ' ready to launch'
                  str.freeze
                end
              }
            }
          }
        )
      end
      let(:time_strategy) do
        SleepingKingStudios::Tools::Messages::Strategies::HashStrategy.new(
          {
            'time.machines.investors.wells' => 'H.G. Wells'
          }
        )
      end

      before(:example) do
        registry.add(scope: 'space', strategy: space_strategy)
        registry.add(scope: 'time',  strategy: time_strategy)
      end

      describe 'with key: a String that does not match a strategy' do
        let(:key) { 'cosmos' }

        it { expect(generate_message).to be == missing_template_message }
      end

      describe 'with key: a Symbol that does not match a strategy' do
        let(:key) { :cosmos }

        it { expect(generate_message).to be == missing_template_message }
      end

      describe 'with key: a String that does not match a template' do
        let(:key) { 'space.errors.not_going_to_space' }

        it { expect(generate_message).to be == missing_template_message }
      end

      describe 'with key: a Symbol that does not match a template' do
        let(:key) { :'space.errors.not_going_to_space' }

        it { expect(generate_message).to be == missing_template_message }
      end

      describe 'with key: a String that matches a template' do
        let(:key)      { 'space.rockets.ready_to_launch' }
        let(:expected) { 'rocket is not ready to launch' }

        it { expect(generate_message).to be == expected }

        describe 'with options: value' do
          let(:options)  { super().merge(ready: true) }
          let(:expected) { 'rocket is ready to launch' }

          it { expect(generate_message).to be == expected }
        end

        describe 'with parameters: value' do
          let(:parameters) { { name: 'Hellhound IV' } }
          let(:options)    { super().merge(parameters:) }
          let(:expected)   { 'rocket Hellhound IV is not ready to launch' }

          it { expect(generate_message).to be == expected }
        end

        describe 'with scope: value' do
          let(:key)     { 'ready_to_launch' }
          let(:scope)   { 'space.rockets' }
          let(:options) { super().merge(scope:) }

          it { expect(generate_message).to be == expected }
        end
      end

      describe 'with key: a Symbol that matches a template' do
        let(:key)      { :'space.rockets.ready_to_launch' }
        let(:expected) { 'rocket is not ready to launch' }

        it { expect(generate_message).to be == expected }

        describe 'with options: value' do
          let(:options)  { super().merge(ready: true) }
          let(:expected) { 'rocket is ready to launch' }

          it { expect(generate_message).to be == expected }
        end

        describe 'with parameters: value' do
          let(:parameters) { { name: 'Hellhound IV' } }
          let(:options)    { super().merge(parameters:) }
          let(:expected)   { 'rocket Hellhound IV is not ready to launch' }

          it { expect(generate_message).to be == expected }
        end

        describe 'with scope: value' do
          let(:key)     { :ready_to_launch }
          let(:scope)   { :'space.rockets' }
          let(:options) { super().merge(scope:) }

          it { expect(generate_message).to be == expected }
        end
      end
    end
  end

  describe '#registry' do
    include_examples 'should define reader', :registry, -> { registry }

    context 'when initialized with registry: nil' do
      let(:registry) { nil }
      let(:expected) { described_class::Registry.global }

      it { expect(messages.registry).to be expected }
    end
  end

  describe '#toolbelt' do
    let(:expected) { SleepingKingStudios::Tools::Toolbelt.global }

    it { expect(messages.toolbelt).to be expected }

    it { expect(messages).to have_aliased_method(:toolbelt).as(:tools) }

    context 'when initialized with toolbelt: value' do
      let(:toolbelt) { SleepingKingStudios::Tools::Toolbelt.new }
      let(:constructor_options) do
        super().merge(toolbelt:)
      end

      it { expect(messages.toolbelt).to be toolbelt }
    end
  end
end
