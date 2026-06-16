# frozen_string_literal: true

require 'yaml'

require 'sleeping_king_studios/tools/messages/strategies/file_strategy'

RSpec.describe SleepingKingStudios::Tools::Messages::Strategies::FileStrategy do
  subject(:strategy) { described_class.new(file_name, **constructor_options) }

  let(:file_name)           { 'spec/support/fixtures/empty.yml' }
  let(:constructor_options) { {} }

  describe '::FileError' do
    include_examples 'should define constant',
      :FileError,
      -> { be_a(Class).and(be < StandardError) }
  end

  describe '.new' do
    let(:invalid_value_message) do
      'value is not a String or a Proc'
    end

    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:flatten_templates, :validate_values)
    end

    describe 'with file_name: nil' do
      let(:error_message) { "file name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.new(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with file_name: an Object' do
      let(:error_message) { 'file name is not an instance of String' }

      it 'should raise an exception' do
        expect { described_class.new(Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with file_name: an empty Pathname' do
      let(:error_message) { "file name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.new(Pathname.new('')) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with file_name: an empty String' do
      let(:error_message) { "file name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.new('') }
          .to raise_error ArgumentError, error_message
      end
    end

    context 'when the file does not exist' do
      let(:file_name) { 'spec/support/fixtures/missing.yml' }
      let(:error_message) do
        "templates file does not exist at #{file_name}"
      end

      it 'should raise an exception' do
        expect { described_class.new(file_name) }
          .to raise_error described_class::FileError, error_message
      end
    end

    context 'when reading the file raises an exception' do
      let(:file_name) { 'spec/support/fixtures/unreadable.yml' }
      let(:error_message) do
        "unable to read templates file at #{file_name} - #{exception.message}"
      end
      let(:exception) { RuntimeError.new('something went wrong') }

      before(:example) do
        allow(File).to receive(:file?).with(file_name).and_return(true)
        allow(File).to receive(:read).with(file_name).and_raise(exception)
      end

      it 'should raise an exception' do
        expect { described_class.new(file_name) }
          .to raise_error described_class::FileError, error_message
      end
    end

    context 'when the file does not have an extname' do
      let(:file_name) { 'spec/support/fixtures/mystery' }
      let(:error_message) do
        'unable to read templates file - unrecognized extension ""'
      end

      it 'should raise an exception' do
        expect { described_class.new(file_name) }
          .to raise_error described_class::FileError, error_message
      end
    end

    context 'when the file has an unsupported extname' do
      let(:file_name) { 'spec/support/fixtures/trustworthy.zip' }
      let(:error_message) do
        'unable to read templates file - unrecognized extension ".zip"'
      end

      it 'should raise an exception' do
        expect { described_class.new(file_name) }
          .to raise_error described_class::FileError, error_message
      end
    end

    context 'when the file is an unparseable JSON file' do
      let(:file_name) { 'spec/support/fixtures/unparseable.json' }
      let(:json_error) do
        JSON.parse(File.read(file_name))
      rescue JSON::ParserError => exception
        exception
      end
      let(:error_message) do
        "unable to parse templates file - #{json_error.message}"
      end

      it 'should raise an exception' do
        expect { described_class.new(file_name) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    context 'when the file is an unparseable YAML file' do
      let(:file_name) { 'spec/support/fixtures/unparseable.yml' }
      let(:yaml_error) do
        raw_data = File.read(file_name)

        YAML.safe_load(raw_data)
      rescue Psych::SyntaxError => exception
        exception
      end
      let(:error_message) do
        "unable to parse templates file - #{yaml_error.message}"
      end

      it 'should raise an exception' do
        expect { described_class.new(file_name) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    context 'when the file is a JSON file with invalid contents' do
      let(:file_name) { 'spec/support/fixtures/invalid.json' }
      let(:error_message) do
        'invalid value in templates.messages.errors - ' \
          "#{invalid_value_message}, got [\"not going to space\", nil]"
      end

      it 'should raise an exception' do
        expect { described_class.new(file_name) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    context 'when the file is a YAML file with invalid contents' do
      let(:file_name) { 'spec/support/fixtures/invalid.yml' }
      let(:error_message) do
        'invalid value in templates.messages.errors - ' \
          "#{invalid_value_message}, got [\"not going to space\", nil]"
      end

      it 'should raise an exception' do
        expect { described_class.new(file_name) }
          .to raise_error described_class::ParseError, error_message
      end
    end

    describe 'with validate_values: false' do
      context 'when the file is a JSON file with invalid contents' do
        let(:file_name) { 'spec/support/fixtures/invalid.json' }

        it 'should initialize the strategy' do
          strategy = described_class.new(file_name, validate_values: false)

          expect(strategy.get('messages.errors'))
            .to be == ['not going to space', nil]
        end
      end

      context 'when the file is a JSON file with valid contents' do
        let(:file_name) { 'spec/support/fixtures/messages.json' }

        it 'should initialize the strategy' do
          strategy = described_class.new(file_name, validate_values: false)

          expect(strategy.get('module_name')).to be == 'Console Space Program'
        end
      end

      context 'when the file is a YAML file with invalid contents' do
        let(:file_name) { 'spec/support/fixtures/invalid.yml' }

        it 'should initialize the strategy' do
          strategy = described_class.new(file_name, validate_values: false)

          expect(strategy.get('messages.errors'))
            .to be == ['not going to space', nil]
        end
      end

      context 'when the file is a YAML file with valid contents' do
        let(:file_name) { 'spec/support/fixtures/messages.yaml' }

        it 'should initialize the strategy' do
          strategy = described_class.new(file_name, validate_values: false)

          expect(strategy.get('module_name')).to be == 'Console Space Program'
        end
      end
    end

    describe 'with validate_values: a Proc' do
      let(:invalid_value_message) do
        'value must be true or false'
      end
      let(:validate_values) do
        lambda do |value|
          next if value == true || value == false # rubocop:disable Style/MultipleComparison

          invalid_value_message
        end
      end

      context 'when the file is a JSON file with boolean contents' do
        let(:file_name) { 'spec/support/fixtures/booleans.json' }

        it 'should initialize the strategy' do
          strategy = described_class.new(file_name, validate_values:)

          expect(strategy.get('config.disabled')).to be false
        end
      end

      context 'when the file is a JSON file with invalid contents' do
        let(:file_name) { 'spec/support/fixtures/messages.json' }
        let(:error_message) do
          'invalid value in templates.messages.errors.failure - ' \
            "#{invalid_value_message}, got \"not going to space\""
        end

        it 'should raise an exception' do
          expect { described_class.new(file_name, validate_values:) }
            .to raise_error described_class::ParseError, error_message
        end
      end

      context 'when the file is a YAML file with boolean contents' do
        let(:file_name) { 'spec/support/fixtures/booleans.yml' }

        it 'should initialize the strategy' do
          strategy = described_class.new(file_name, validate_values:)

          expect(strategy.get('config.disabled')).to be false
        end
      end

      context 'when the file is a YAML file with invalid contents' do
        let(:file_name) { 'spec/support/fixtures/messages.yml' }
        let(:error_message) do
          'invalid value in templates.messages.errors.failure - ' \
            "#{invalid_value_message}, got \"not going to space\""
        end

        it 'should raise an exception' do
          expect { described_class.new(file_name, validate_values:) }
            .to raise_error described_class::ParseError, error_message
        end
      end
    end
  end

  describe '#call' do
    deferred_examples 'should handle a non-matching key' do
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
      include_deferred 'should handle a non-matching key'

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
      include_deferred 'should handle a non-matching key'
    end

    describe 'with key: a Symbol' do
      let(:key) { super().to_sym }

      include_deferred 'should handle a non-matching key'
    end

    describe 'with key: a scoped value' do
      let(:key) { "errors.messages.#{super()}" }

      include_deferred 'should handle a non-matching key'
    end

    describe 'with options: value' do
      let(:options) { super().merge(ready: true) }

      include_deferred 'should handle a non-matching key'
    end

    describe 'with parameters: value' do
      let(:parameters) do
        {
          name: 'Hellhound IV',
          fuel: 1_000
        }
      end
      let(:options) { super().merge(parameters:) }

      include_deferred 'should handle a non-matching key'
    end

    describe 'with scope: value' do
      let(:options) { super().merge(scope: 'custom.scope') }

      include_deferred 'should handle a non-matching key'

      describe 'with key: a scoped value' do
        let(:key) { "errors.messages.#{super()}" }

        include_deferred 'should handle a non-matching key'
      end
    end

    context 'when initialized with templates: value' do
      let(:file_name) { 'spec/support/fixtures/messages.yml' }
      let(:key)       { 'module_name' }
      let(:expected)  { 'Console Space Program' }

      include_deferred 'should return the matching message'

      describe 'with a key pointing to a scope' do
        let(:key) { 'messages' }

        include_deferred 'should handle a non-matching key'
      end

      describe 'with a scoped key' do
        let(:key) { 'messages.rockets.launch_status' }

        describe 'with parameters: value' do
          let(:parameters) do
            {
              name: 'Hellhound IV',
              fuel: 1_000
            }
          end
          let(:options)  { super().merge(parameters:) }
          let(:expected) { 'rocket Hellhound IV is ready to launch' }

          include_deferred 'should return the matching message'

          describe 'with options: value' do # rubocop:disable RSpec/NestedGroups
            let(:options)  { super().merge(ready: true) }
            let(:expected) { 'rocket Hellhound IV is ready to launch' }

            include_deferred 'should return the matching message'
          end
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

      context 'when initialized with flatten_templates: false' do
        let(:constructor_options) { super().merge(flatten_templates: false) }

        include_deferred 'should return the matching message'

        describe 'with a key pointing to a scope' do
          let(:key) { 'messages' }
          let(:error_message) do
            "invalid template #{strategy.templates[scoped_key].inspect}"
          end

          it 'should raise an exception' do
            expect { call_strategy }.to raise_error ArgumentError, error_message
          end
        end
      end
    end
  end

  describe '#fetch' do
    deferred_examples 'should handle a non-matching key' do
      context 'when the key does not match a template' do
        let(:key) do
          original = super()
          invalid  = original.to_s.sub(/\w+\z/, 'invalid_key')

          original.is_a?(Symbol) ? invalid.to_sym : invalid
        end
        let(:error_message) do
          "template not found: #{scoped_key.inspect}"
        end

        it 'should raise an exception' do
          expect { call_strategy }.to raise_error(KeyError, error_message)
        end

        describe 'with default: Proc' do
          let(:block) do
            lambda do |key, locale: 'en', **|
              "default message for key #{key} in locale #{locale}"
            end
          end
          let(:options) { super().merge(locale: 'es') }
          let(:expected) do
            "default message for key #{scoped_key} in locale es"
          end

          it { expect(call_strategy).to be == expected }
        end

        describe 'with default: value' do
          let(:default)   { 'default message' }
          let(:arguments) { [*super(), default] }

          it { expect(call_strategy).to be == 'default message' }
        end
      end
    end

    deferred_examples 'should return the matching template' do
      include_deferred 'should handle a non-matching key'

      context 'when the key matches a template' do
        let(:expected) { templates[scoped_key] }

        it { expect(call_strategy).to be == expected }
      end
    end

    let(:key)        { 'base_key' }
    let(:arguments)  { [] }
    let(:options)    { {} }
    let(:block)      { nil }
    let(:scoped_key) { [options[:scope], key].compact.join('.') }

    define_method :call_strategy do
      strategy.fetch(key, *arguments, **options, &block)
    end

    it 'should define the method' do
      expect(strategy)
        .to respond_to(:call)
        .with(1).argument
        .and_keywords(:scope)
        .and_any_keywords
    end

    describe 'with key: a String' do
      include_deferred 'should handle a non-matching key'
    end

    describe 'with key: a Symbol' do
      let(:key) { super().to_sym }

      include_deferred 'should handle a non-matching key'
    end

    describe 'with key: a scoped value' do
      let(:key) { "errors.messages.#{super()}" }

      include_deferred 'should handle a non-matching key'
    end

    describe 'with options: value' do
      let(:options) { super().merge(ready: true) }

      include_deferred 'should handle a non-matching key'
    end

    describe 'with scope: value' do
      let(:options) { super().merge(scope: 'custom.scope') }

      include_deferred 'should handle a non-matching key'

      describe 'with key: a scoped value' do
        let(:key) { "errors.messages.#{super()}" }

        include_deferred 'should handle a non-matching key'
      end
    end

    context 'when initialized with templates: value' do
      let(:file_name) { 'spec/support/fixtures/messages.yml' }
      let(:templates) { strategy.templates }

      let(:key) { 'module_name' }

      include_deferred 'should return the matching template'

      describe 'with a key pointing to a scope' do
        let(:key) { 'messages' }

        include_deferred 'should handle a non-matching key'
      end

      describe 'with a scoped key' do
        let(:key) { 'messages.rockets.launch_status' }

        include_deferred 'should return the matching template'

        describe 'with options: value' do
          let(:options) { super().merge(ready: true) }

          include_deferred 'should return the matching template'
        end
      end

      describe 'with scope: value' do
        let(:key)     { 'failure' }
        let(:scope)   { 'messages.errors' }
        let(:options) { super().merge(scope:) }

        include_deferred 'should return the matching template'

        describe 'with a scoped key' do
          let(:key)   { 'errors.failure' }
          let(:scope) { 'messages' }

          include_deferred 'should return the matching template'
        end
      end

      context 'when initialized with flatten_templates: false' do
        let(:constructor_options) { super().merge(flatten_templates: false) }
        let(:expected)            { templates.dig(*scoped_key.split('.')) }

        include_deferred 'should return the matching template'

        describe 'with a key pointing to a scope' do
          let(:key) { 'messages' }

          include_deferred 'should return the matching template'
        end
      end
    end
  end

  describe '#file_name' do
    include_examples 'should define reader', :file_name, -> { file_name }
  end

  describe '#get' do
    deferred_examples 'should handle a non-matching key' do
      context 'when the key does not match a template' do
        let(:key) do
          original = super()
          invalid  = original.to_s.sub(/\w+\z/, 'invalid_key')

          original.is_a?(Symbol) ? invalid.to_sym : invalid
        end

        it { expect(call_strategy).to be nil }
      end
    end

    deferred_examples 'should return the matching template' do
      include_deferred 'should handle a non-matching key'

      context 'when the key matches a template' do
        let(:expected) { templates[scoped_key] }

        it { expect(call_strategy).to be == expected }
      end
    end

    let(:key)        { 'base_key' }
    let(:arguments)  { [] }
    let(:options)    { {} }
    let(:block)      { nil }
    let(:scoped_key) { [options[:scope], key].compact.join('.') }

    define_method :call_strategy do
      strategy.get(key, *arguments, **options, &block)
    end

    it 'should define the method' do
      expect(strategy)
        .to respond_to(:call)
        .with(1).argument
        .and_keywords(:scope)
        .and_any_keywords
    end

    describe 'with key: a String' do
      include_deferred 'should handle a non-matching key'
    end

    describe 'with key: a Symbol' do
      let(:key) { super().to_sym }

      include_deferred 'should handle a non-matching key'
    end

    describe 'with key: a scoped value' do
      let(:key) { "errors.messages.#{super()}" }

      include_deferred 'should handle a non-matching key'
    end

    describe 'with options: value' do
      let(:options) { super().merge(ready: true) }

      include_deferred 'should handle a non-matching key'
    end

    describe 'with scope: value' do
      let(:options) { super().merge(scope: 'custom.scope') }

      include_deferred 'should handle a non-matching key'

      describe 'with key: a scoped value' do
        let(:key) { "errors.messages.#{super()}" }

        include_deferred 'should handle a non-matching key'
      end
    end

    context 'when initialized with templates: value' do
      let(:file_name) { 'spec/support/fixtures/messages.yml' }
      let(:templates) { strategy.templates }

      let(:key) { 'module_name' }

      include_deferred 'should return the matching template'

      describe 'with a key pointing to a scope' do
        let(:key) { 'messages' }

        include_deferred 'should handle a non-matching key'
      end

      describe 'with a scoped key' do
        let(:key) { 'messages.rockets.launch_status' }

        include_deferred 'should return the matching template'

        describe 'with options: value' do
          let(:options) { super().merge(ready: true) }

          include_deferred 'should return the matching template'
        end
      end

      describe 'with scope: value' do
        let(:key)     { 'failure' }
        let(:scope)   { 'messages.errors' }
        let(:options) { super().merge(scope:) }

        include_deferred 'should return the matching template'

        describe 'with a scoped key' do
          let(:key)   { 'errors.failure' }
          let(:scope) { 'messages' }

          include_deferred 'should return the matching template'
        end
      end

      context 'when initialized with flatten_templates: false' do
        let(:constructor_options) { super().merge(flatten_templates: false) }
        let(:expected)            { templates.dig(*scoped_key.split('.')) }

        include_deferred 'should return the matching template'

        describe 'with a key pointing to a scope' do
          let(:key) { 'messages' }

          include_deferred 'should return the matching template'
        end
      end
    end
  end

  describe '#templates' do
    let(:expected) do
      templates = {}
      templates['module_name'] = 'Console Space Program'
      templates['messages.errors.failure'] = 'not going to space'
      templates['messages.rockets.launch_status'] =
        'rocket %<name>s is ready to launch'
      templates
    end

    context 'when initialized with file_name: a Pathname' do
      let(:file_name) { Pathname.new('spec/support/fixtures/messages.yml') }

      it { expect(strategy.templates).to be == expected }

      context 'when initialized with flatten_templates: false' do
        let(:constructor_options) { super().merge(flatten_templates: false) }
        let(:expected) do
          {
            'module_name' => 'Console Space Program',
            'messages'    => {
              'errors'  => {
                'failure' => 'not going to space'
              },
              'rockets' => {
                'launch_status' => 'rocket %<name>s is ready to launch'
              }
            }
          }
        end

        it { expect(strategy.templates).to be == expected }
      end
    end

    context 'when the file is an empty JSON file' do
      let(:file_name) { 'spec/support/fixtures/empty.json' }
      let(:expected)  { {} }

      it { expect(strategy.templates).to be == expected }
    end

    context 'when the file is a non-empty JSON file' do
      let(:file_name) { 'spec/support/fixtures/messages.json' }

      it { expect(strategy.templates).to be == expected }

      context 'when initialized with flatten_templates: false' do
        let(:constructor_options) { super().merge(flatten_templates: false) }
        let(:expected) do
          {
            'module_name' => 'Console Space Program',
            'messages'    => {
              'errors'  => {
                'failure' => 'not going to space'
              },
              'rockets' => {
                'launch_status' => 'rocket %<name>s is ready to launch'
              }
            }
          }
        end

        it { expect(strategy.templates).to be == expected }
      end
    end

    context 'when the file is an empty YAML file' do
      let(:file_name) { 'spec/support/fixtures/empty.yml' }
      let(:expected)  { {} }

      it { expect(strategy.templates).to be == expected }
    end

    context 'when the file is a non-empty YAML file' do
      let(:file_name) { 'spec/support/fixtures/messages.yml' }

      include_examples 'should define reader', :templates, -> { expected }

      context 'when initialized with flatten_templates: false' do
        let(:constructor_options) { super().merge(flatten_templates: false) }
        let(:expected) do
          {
            'module_name' => 'Console Space Program',
            'messages'    => {
              'errors'  => {
                'failure' => 'not going to space'
              },
              'rockets' => {
                'launch_status' => 'rocket %<name>s is ready to launch'
              }
            }
          }
        end

        it { expect(strategy.templates).to be == expected }
      end
    end

    context 'when the file is a YAML file with a .yaml suffix' do
      let(:file_name) { 'spec/support/fixtures/messages.yaml' }

      it { expect(strategy.templates).to be == expected }

      context 'when initialized with flatten_templates: false' do
        let(:constructor_options) { super().merge(flatten_templates: false) }
        let(:expected) do
          {
            'module_name' => 'Console Space Program',
            'messages'    => {
              'errors'  => {
                'failure' => 'not going to space'
              },
              'rockets' => {
                'launch_status' => 'rocket %<name>s is ready to launch'
              }
            }
          }
        end

        it { expect(strategy.templates).to be == expected }
      end
    end
  end
end
