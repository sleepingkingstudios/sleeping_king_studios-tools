# frozen_string_literal: true

require 'sleeping_king_studios/tools/messages/strategy'

RSpec.describe SleepingKingStudios::Tools::Messages::Strategy do
  subject(:strategy) { described_class.new }

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

    describe 'with key: nil' do
      let(:key) { nil }
      let(:error_message) do
        "key can't be blank"
      end

      it 'should raise an exception' do
        expect { call_strategy }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with key: an Object' do
      let(:key) { Object.new.freeze }
      let(:error_message) do
        'key is not a String or a Symbol'
      end

      it 'should raise an exception' do
        expect { call_strategy }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with key: an empty String' do
      let(:key) { '' }
      let(:error_message) do
        "key can't be blank"
      end

      it 'should raise an exception' do
        expect { call_strategy }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with key: an empty Symbol' do
      let(:key) { :'' }
      let(:error_message) do
        "key can't be blank"
      end

      it 'should raise an exception' do
        expect { call_strategy }
          .to raise_error ArgumentError, error_message
      end
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

    context 'with a strategy subclass' do
      subject(:strategy) { Spec::Strategy.new(strategy_templates) }

      let(:strategy_templates) do
        templates = {}
        templates['module_name'] = 'Console Space Program'
        templates['messages.launch_sites.unlocked'] =
          'launch site is now open for launch'
        templates['messages.rockets.launch_status'] =
          lambda do |parameters: {}, ready: false, **|
            str = +'rocket'
            str << ' ' << parameters[:name] if parameters.key?(:name)
            str << (ready ? ' is' : ' is not')
            str << ' ready to launch'
            str.freeze
          end

        templates
      end
      let(:key)      { 'module_name' }
      let(:expected) { 'Console Space Program' }

      example_class 'Spec::Strategy', described_class do |klass|
        klass.define_method :initialize do |templates|
          @templates = templates
        end

        klass.attr_reader :templates

        klass.define_method :template_for do |scoped_key, **|
          templates[scoped_key.to_s]
        end
      end

      include_deferred 'should return the matching message'

      context 'when the template requires parameters' do
        let(:strategy_templates) do
          super().merge(
            'messages.rockets.fuel_status' => '%<name> is fully fueled'
          )
        end
        let(:key) { 'messages.rockets.fuel_status' }
        let(:expected) do
          "Message missing parameters: #{scoped_key} key<name> not found"
        end

        it { expect(call_strategy).to be == expected }
      end

      describe 'with key: a scoped value' do
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
        let(:key)      { 'unlocked' }
        let(:scope)    { 'messages.launch_sites' }
        let(:options)  { super().merge(scope:) }
        let(:expected) { 'launch site is now open for launch' }

        include_deferred 'should return the matching message'

        describe 'with a scoped key' do
          let(:key) { 'launch_sites.unlocked' }
          let(:scope) { 'messages' }

          include_deferred 'should return the matching message'
        end
      end
    end
  end

  describe '#generate' do
    let(:scoped_key) { 'path.to.template' }
    let(:value)      { 'template string' }
    let(:parameters) { {} }
    let(:options)    { {} }

    define_method :generate_string do
      strategy.send(:generate, template, parameters:, scoped_key:, **options)
    end

    it 'should define the method' do
      expect(strategy)
        .to respond_to(:generate, true)
        .with(1).argument
        .and_keywords(:parameters, :scoped_key)
        .and_any_keywords
    end

    describe 'with template: nil' do
      let(:error_message) do
        "template can't be blank"
      end

      it 'should raise an exception' do
        expect { strategy.send(:generate, nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with template: an Object' do
      let(:template) { Object.new.freeze }
      let(:error_message) do
        "invalid template #{template.inspect}"
      end

      it 'should raise an exception' do
        expect { strategy.send(:generate, template) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with template: a Proc' do
      let(:template) do
        lambda do |parameters: {}, ready: false, **|
          str = +'rocket'
          str << ' ' << parameters[:name] if parameters.key?(:name)
          str << (ready ? ' is' : ' is not')
          str << ' ready to launch'
          str.freeze
        end
      end
      let(:expected) { 'rocket is not ready to launch' }

      it { expect(generate_string).to be == expected }

      describe 'with parameters' do
        let(:parameters) do
          {
            name: 'Hellhound IV',
            fuel: 1_000
          }
        end
        let(:expected) { 'rocket Hellhound IV is not ready to launch' }

        it { expect(generate_string).to be == expected }

        describe 'with options' do
          let(:options)  { { ready: true } }
          let(:expected) { 'rocket Hellhound IV is ready to launch' }

          it { expect(generate_string).to be == expected }
        end
      end

      describe 'with options' do
        let(:options)  { { ready: true } }
        let(:expected) { 'rocket is ready to launch' }

        it { expect(generate_string).to be == expected }
      end
    end

    describe 'with template: a String' do
      let(:template) { 'rocket is ready to launch' }

      it { expect(generate_string).to be == template }

      describe 'with parameters' do
        let(:parameters) do
          {
            name: 'Hellhound IV',
            fuel: 1_000
          }
        end

        it { expect(generate_string).to be == template }
      end

      describe 'with options' do
        let(:options) { { ready: true } }

        it { expect(generate_string).to be == template }
      end
    end

    describe 'with template: a format String' do
      let(:template) { 'rocket %<name>s is ready to launch' }

      describe 'with non-matching parameters' do
        let(:missing_parameters_message) do
          "Message missing parameters: #{scoped_key} key<name> not found"
        end

        it { expect(generate_string).to be == missing_parameters_message }
      end

      describe 'with matching parameters' do
        let(:parameters) do
          {
            name: 'Hellhound IV',
            fuel: 1_000
          }
        end
        let(:expected) do
          'rocket Hellhound IV is ready to launch'
        end

        it { expect(generate_string).to be == expected }

        describe 'with options' do
          let(:options) { { ready: true } }

          it { expect(generate_string).to be == expected }
        end
      end
    end
  end

  describe '#template_for' do
    let(:scoped_key) { 'path.to.key' }

    it 'should define the method' do
      expect(strategy)
        .to respond_to(:template_for, true)
        .with(1).argument
        .and_any_keywords
    end

    describe 'with nil' do
      it { expect(strategy.send(:template_for, nil)).to be nil }
    end

    describe 'with an Object' do
      it { expect(strategy.send(:template_for, Object.new.freeze)).to be nil }
    end

    describe 'with an empty String' do
      it { expect(strategy.send(:template_for, '')).to be nil }
    end

    describe 'with an empty Symbol' do
      it { expect(strategy.send(:template_for, :'')).to be nil }
    end

    describe 'with a non-empty String' do
      it { expect(strategy.send(:template_for, 'scoped.key')).to be nil }
    end

    describe 'with a non-empty Symbol' do
      it { expect(strategy.send(:template_for, :'scoped.key')).to be nil }
    end
  end
end
