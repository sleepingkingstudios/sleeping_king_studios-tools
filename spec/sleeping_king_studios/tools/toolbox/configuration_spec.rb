# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/configuration'

RSpec.describe SleepingKingStudios::Tools::Toolbox::Configuration do
  extend RSpec::SleepingKingStudios::Concerns::ExampleConstants

  shared_context 'when a namespace is defined' do
    let(:data) do
      {
        armor: {
          materials: %w[leather iron steel mithril adamantium orichalcum]
        }
      }
    end

    before(:example) do
      Spec::Configuration.namespace :armor do |armor|
        armor.option :materials
      end
    end
  end

  shared_context 'when an option is defined' do
    let(:options) { {} }
    let(:data) do
      { rations: '1/day' }
    end

    before(:example) do
      Spec::Configuration.option(:rations, **options)
    end
  end

  shared_context 'when many configuration options are defined' do
    let(:data) do
      {
        weapons: {
          swords: {
            default_attack: :slash,
            upgrade_parts:  %w[hilt tang pommel]
          }
        },
        armor:   {
          materials: %w[leather iron steel mithril adamantium orichalcum]
        },
        rations: '1/day'
      }
    end

    before(:example) do
      Spec::Configuration.option :rations

      Spec::Configuration.namespace :armor do |armor|
        armor.option :materials
      end

      Spec::Configuration.namespace :weapons do |weapons|
        weapons.option :allow_polearms

        weapons.namespace :swords do |swords|
          swords.option :default_attack

          swords.option :upgrade_parts
        end
      end
    end
  end

  shared_context 'when the data source is nil' do
    let(:instance) { described_class.new }
  end

  shared_context 'when the data source is an object' do
    let(:instance) { described_class.new(build_configuration(hash), &block) }

    def build_configuration(hsh)
      obj = Struct.new(*hsh.keys).new

      hsh.each do |key, value|
        val = value.is_a?(Hash) ? build_configuration(value) : value

        obj.send :"#{key}=", val
      end

      obj
    end
  end

  subject(:configuration) { described_class.new(initial_state) }

  let(:described_class) { Spec::Configuration }
  let(:initial_state)   { nil }
  let(:instance)        { configuration }

  # rubocop:disable RSpec/DescribedClass
  example_class 'Spec::Configuration',
    SleepingKingStudios::Tools::Toolbox::Configuration
  # rubocop:enable RSpec/DescribedClass

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  describe '::namespace' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:namespace)
        .with(1).argument
        .and_a_block
    end

    # rubocop:disable RSpec/DescribedClass
    it 'should return the namespace' do
      expect(described_class.namespace :psionics)
        .to be_a(Class)
        .and(be < SleepingKingStudios::Tools::Toolbox::Configuration)
    end
    # rubocop:enable RSpec/DescribedClass

    # rubocop:disable RSpec/DescribedClass
    context 'when called on the abstract class' do
      let(:error_message) do
        "can't define namespace or option on abstract class"
      end

      it 'should raise an error' do
        expect do
          SleepingKingStudios::Tools::Toolbox::Configuration.namespace :psionics
        end
          .to raise_error RuntimeError, error_message
      end
    end
    # rubocop:enable RSpec/DescribedClass
  end

  describe '::option' do
    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:option)
        .with(1).argument
        .and_keywords(:allow_nil, :default, :enum)
    end

    it 'should return the option name' do
      expect(described_class.option :cheat_mode).to be :cheat_mode
    end

    # rubocop:disable RSpec/DescribedClass
    context 'when called on the abstract class' do
      let(:error_message) do
        "can't define namespace or option on abstract class"
      end

      it 'should raise an error' do
        expect do
          SleepingKingStudios::Tools::Toolbox::Configuration.option :cheat_mode
        end
          .to raise_error RuntimeError, error_message
      end
    end
    # rubocop:enable RSpec/DescribedClass
  end

  describe '#:namespace' do
    it { expect(configuration).not_to respond_to(:armor) }

    context 'when a namespace is defined' do
      include_context 'when a namespace is defined'

      let(:namespace) { configuration.armor }

      it { expect(configuration).to respond_to(:armor).with(0).arguments }

      # rubocop:disable RSpec/DescribedClass
      it 'should be a configuration object' do
        expect(namespace)
          .to be_a SleepingKingStudios::Tools::Toolbox::Configuration
      end
      # rubocop:enable RSpec/DescribedClass

      describe 'with a block' do
        it 'should yield the namespace' do
          yielded = nil

          configuration.armor do |value|
            yielded = value
          end

          expect(yielded).to be namespace
        end
      end
    end

    context 'when many configuration options are defined' do
      include_context 'when many configuration options are defined'

      let(:namespace) { configuration.weapons }

      it { expect(configuration).to respond_to(:weapons).with(0).arguments }

      # rubocop:disable RSpec/DescribedClass
      it 'should be a configuration object' do
        expect(namespace)
          .to be_a SleepingKingStudios::Tools::Toolbox::Configuration
      end
      # rubocop:enable RSpec/DescribedClass

      describe 'with a block' do
        it 'should yield the namespace' do
          yielded = nil

          configuration.weapons do |value|
            yielded = value
          end

          expect(yielded).to be namespace
        end
      end

      context 'when the namespace is nested' do
        let(:namespace) { configuration.weapons.swords }

        it { expect(configuration).to respond_to(:weapons).with(0).arguments }

        # rubocop:disable RSpec/DescribedClass
        it 'should be a configuration object' do
          expect(namespace)
            .to be_a SleepingKingStudios::Tools::Toolbox::Configuration
        end
        # rubocop:enable RSpec/DescribedClass

        describe 'with a block' do
          it 'should yield the namespace' do
            yielded = nil

            configuration.weapons.swords do |value|
              yielded = value
            end

            expect(yielded).to be namespace
          end
        end
      end
    end
  end

  describe '#:option' do
    it { expect(configuration).not_to respond_to(:rations) }

    context 'when an option is defined' do
      include_context 'when an option is defined'

      it { expect(configuration).to have_reader(:rations).with_value(nil) }

      context 'when the data includes a value for the option' do
        let(:initial_state) { data }

        it { expect(configuration.rations).to be == data.dig(:rations) }
      end

      context 'with default: method call' do
        let(:options) { super().merge(default: -> { feeding_schedule }) }

        before(:example) do
          Spec::Configuration.send(:define_method, :feeding_schedule) do
            'Fortnightly'
          end
        end

        it 'should return the default value' do
          expect(configuration)
            .to have_reader(:rations)
            .with_value('Fortnightly')
        end

        context 'when the data includes a value for the option' do
          let(:initial_state) { data }

          it { expect(configuration.rations).to be == data.dig(:rations) }
        end
      end

      context 'with default: proc' do
        let(:options) { super().merge(default: -> { 'Monthly' }) }

        it 'should return the default value' do
          expect(configuration)
            .to have_reader(:rations)
            .with_value('Monthly')
        end

        context 'when the data includes a value for the option' do
          let(:initial_state) { data }

          it { expect(configuration.rations).to be == data.dig(:rations) }
        end
      end

      context 'with default: value' do
        let(:options) { super().merge(default: 'Occasionally') }

        it 'should return the default value' do
          expect(configuration)
            .to have_reader(:rations)
            .with_value('Occasionally')
        end

        context 'when the data includes a value for the option' do
          let(:initial_state) { data }

          it { expect(configuration.rations).to be == data.dig(:rations) }
        end
      end
    end

    context 'when an option is defined in a namespace' do
      include_context 'when a namespace is defined'

      it 'should define the option' do
        expect(configuration.armor).to have_reader(:materials).with_value(nil)
      end

      context 'when the data includes a value for the option' do
        let(:initial_state) { data }

        it 'should return the value' do
          expect(configuration.armor.materials)
            .to be == data.dig(:armor, :materials)
        end
      end
    end

    context 'when an option is defined in a nested namespace' do
      include_context 'when many configuration options are defined'

      it 'should define the option' do
        expect(configuration.weapons.swords)
          .to have_reader(:upgrade_parts)
          .with_value(nil)
      end

      context 'when the data includes a value for the option' do
        let(:initial_state) { data }

        it 'should return the value' do
          expect(configuration.weapons.swords.upgrade_parts)
            .to be == data.dig(:weapons, :swords, :upgrade_parts)
        end
      end
    end
  end

  describe '#:option=' do
    it { expect(configuration).not_to respond_to(:rations=) }

    context 'when an option is defined' do
      include_context 'when an option is defined'

      it { expect(configuration).to respond_to(:rations=).with(1).argument }

      describe 'with nil' do
        it 'should not change the value' do
          expect { configuration.rations = nil }
            .not_to change(configuration, :rations)
        end
      end

      describe 'with a value' do
        it 'should set the value' do
          expect { configuration.rations = 'Rarely' }
            .to change(configuration, :rations)
            .to be == 'Rarely'
        end
      end

      context 'when the data includes a value for the option' do
        let(:initial_state) { data }

        describe 'with nil' do
          it 'should clear the value' do
            expect { configuration.rations = nil }
              .to change(configuration, :rations)
              .to be nil
          end
        end

        describe 'with the old value' do
          it 'should not change the value' do
            expect { configuration.rations = data[:rations] }
              .not_to change(configuration, :rations)
          end
        end

        describe 'with a new value' do
          it 'should set the value' do
            expect { configuration.rations = 'Rarely' }
              .to change(configuration, :rations)
              .to be == 'Rarely'
          end
        end
      end

      context 'with enum: value' do
        let(:initial_state) do
          { rations: 'Daily' }
        end
        let(:options) { super().merge(enum: %w[Daily Weekly Monthly]) }

        describe 'with nil' do
          let(:error_message) do
            'expected option to be "Daily", "Weekly", or "Monthly", but was nil'
          end

          it 'should raise an error' do
            expect { configuration.rations = nil }
              .to raise_error error_message
          end
        end

        describe 'with an invalid value' do
          let(:error_message) do
            'expected option to be "Daily", "Weekly", or "Monthly", but was' \
            ' "Fortnightly"'
          end

          it 'should raise an error' do
            expect { configuration.rations = 'Fortnightly' }
              .to raise_error error_message
          end
        end

        describe 'with a valid value' do
          it 'should set the value' do
            expect { configuration.rations = 'Weekly' }
              .to change(configuration, :rations)
              .to be == 'Weekly'
          end
        end
      end
    end
  end

  describe '#[]' do
    it { expect(configuration).to respond_to(:[]).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { configuration[nil] }
          .to raise_error TypeError, 'nil is not a symbol nor a string'
      end
    end

    describe 'with an invalid string' do
      it { expect(configuration['psionics']).to be nil }
    end

    describe 'with an invalid symbol' do
      it { expect(configuration[:psionics]).to be nil }
    end

    context 'when an option is defined' do
      include_context 'when an option is defined'

      describe 'with nil' do
        it 'should raise an error' do
          expect { configuration[nil] }
            .to raise_error TypeError, 'nil is not a symbol nor a string'
        end
      end

      describe 'with an invalid string' do
        it { expect(configuration['psionics']).to be nil }
      end

      describe 'with an invalid symbol' do
        it { expect(configuration[:psionics]).to be nil }
      end

      describe 'with a valid string' do
        it { expect(configuration['rations']).to be nil }
      end

      context 'when the data includes a value for the option' do
        let(:initial_state) { data }

        describe 'with a valid symbol' do
          it { expect(configuration[:rations]).to be == data[:rations] }
        end

        describe 'with a valid string' do
          it { expect(configuration['rations']).to be == data[:rations] }
        end
      end

      context 'with default: method call' do
        let(:options) { super().merge(default: -> { feeding_schedule }) }

        before(:example) do
          Spec::Configuration.send(:define_method, :feeding_schedule) do
            'Fortnightly'
          end
        end

        describe 'with a valid symbol' do
          it { expect(configuration[:rations]).to be == 'Fortnightly' }
        end

        describe 'with a valid string' do
          it { expect(configuration['rations']).to be == 'Fortnightly' }
        end

        # rubocop:disable RSpec/NestedGroups
        context 'when the data includes a value for the option' do
          let(:initial_state) { data }

          describe 'with a valid symbol' do
            it { expect(configuration[:rations]).to be == data[:rations] }
          end

          describe 'with a valid string' do
            it { expect(configuration['rations']).to be == data[:rations] }
          end
        end
        # rubocop:enable RSpec/NestedGroups
      end

      context 'with default: proc' do
        let(:options) { super().merge(default: -> { 'Monthly' }) }

        describe 'with a valid symbol' do
          it { expect(configuration[:rations]).to be == 'Monthly' }
        end

        describe 'with a valid string' do
          it { expect(configuration['rations']).to be == 'Monthly' }
        end

        # rubocop:disable RSpec/NestedGroups
        context 'when the data includes a value for the option' do
          let(:initial_state) { data }

          describe 'with a valid symbol' do
            it { expect(configuration[:rations]).to be == data[:rations] }
          end

          describe 'with a valid string' do
            it { expect(configuration['rations']).to be == data[:rations] }
          end
        end
        # rubocop:enable RSpec/NestedGroups
      end

      context 'with default: value' do
        let(:options) { super().merge(default: 'Occasionally') }

        describe 'with a valid symbol' do
          it { expect(configuration[:rations]).to be == 'Occasionally' }
        end

        describe 'with a valid string' do
          it { expect(configuration['rations']).to be == 'Occasionally' }
        end

        # rubocop:disable RSpec/NestedGroups
        context 'when the data includes a value for the option' do
          let(:initial_state) { data }

          describe 'with a valid symbol' do
            it { expect(configuration[:rations]).to be == data[:rations] }
          end

          describe 'with a valid string' do
            it { expect(configuration['rations']).to be == data[:rations] }
          end
        end
        # rubocop:enable RSpec/NestedGroups
      end
    end
  end

  describe '#[]=' do
    it { expect(instance).to respond_to(:[]=).with(2).arguments }

    describe 'with nil' do
      it 'should raise an error' do
        expect { configuration[nil] = 'value' }
          .to raise_error TypeError, 'nil is not a symbol nor a string'
      end
    end

    describe 'with an invalid string' do
      it { expect { configuration['psionics'] = true }.not_to raise_error }
    end

    describe 'with an invalid symbol' do
      it { expect { configuration[:psionics] = true }.not_to raise_error }
    end

    context 'when an option is defined' do
      include_context 'when an option is defined'

      describe 'with nil' do
        it 'should raise an error' do
          expect { configuration[nil] = 'value' }
            .to raise_error TypeError, 'nil is not a symbol nor a string'
        end
      end

      describe 'with an invalid string' do
        it { expect { configuration['psionics'] = true }.not_to raise_error }
      end

      describe 'with an invalid symbol' do
        it { expect { configuration[:psionics] = true }.not_to raise_error }
      end

      describe 'with a valid string and nil value' do
        it 'should not change the value' do
          expect { configuration['rations'] = nil }
            .not_to change(configuration, :rations)
        end
      end

      describe 'with a valid string and new value' do
        it 'should not set the value' do
          expect { configuration['rations'] = 'Fortnightly' }
            .to change(configuration, :rations)
            .to be == 'Fortnightly'
        end
      end

      describe 'with a valid symbol and nil value' do
        it 'should not change the value' do
          expect { configuration[:rations] = nil }
            .not_to change(configuration, :rations)
        end
      end

      describe 'with a valid symbol and new value' do
        it 'should not set the value' do
          expect { configuration[:rations] = 'Fortnightly' }
            .to change(configuration, :rations)
            .to be == 'Fortnightly'
        end
      end

      context 'when the data includes a value for the option' do
        let(:initial_state) { data }

        describe 'with a valid string and nil value' do
          it 'should clear the value' do
            expect { configuration['rations'] = nil }
              .to change(configuration, :rations)
              .to be nil
          end
        end

        describe 'with a valid string and the old value' do
          it 'should not change the value' do
            expect { configuration['rations'] = data[:rations] }
              .not_to change(configuration, :rations)
          end
        end

        describe 'with a valid string and a new value' do
          it 'should clear the value' do
            expect { configuration['rations'] = 'Fortnightly' }
              .to change(configuration, :rations)
              .to be 'Fortnightly'
          end
        end

        describe 'with a valid symbol and nil value' do
          it 'should clear the value' do
            expect { configuration[:rations] = nil }
              .to change(configuration, :rations)
              .to be nil
          end
        end

        describe 'with a valid symbol and the old value' do
          it 'should not change the value' do
            expect { configuration[:rations] = data[:rations] }
              .not_to change(configuration, :rations)
          end
        end

        describe 'with a valid symbol and a new value' do
          it 'should clear the value' do
            expect { configuration[:rations] = 'Fortnightly' }
              .to change(configuration, :rations)
              .to be 'Fortnightly'
          end
        end
      end

      context 'with enum: value' do
        let(:initial_state) do
          { rations: 'Daily' }
        end
        let(:options) { super().merge(enum: %w[Daily Weekly Monthly]) }

        describe 'with a valid string and nil value' do
          let(:error_message) do
            'expected option to be "Daily", "Weekly", or "Monthly", but was nil'
          end

          it 'should raise an error' do
            expect { configuration['rations'] = nil }
              .to raise_error error_message
          end
        end

        describe 'with a valid string and invalid value' do
          let(:error_message) do
            'expected option to be "Daily", "Weekly", or "Monthly", but was' \
            ' "Fortnightly"'
          end

          it 'should raise an error' do
            expect { configuration['rations'] = 'Fortnightly' }
              .to raise_error error_message
          end
        end

        describe 'with a valid string and a valid value' do
          it 'should clear the value' do
            expect { configuration['rations'] = 'Monthly' }
              .to change(configuration, :rations)
              .to be 'Monthly'
          end
        end

        describe 'with a valid symbol and nil value' do
          let(:error_message) do
            'expected option to be "Daily", "Weekly", or "Monthly", but was nil'
          end

          it 'should raise an error' do
            expect { configuration[:rations] = nil }
              .to raise_error error_message
          end
        end

        describe 'with a valid symbol and invalid value' do
          let(:error_message) do
            'expected option to be "Daily", "Weekly", or "Monthly", but was' \
            ' "Fortnightly"'
          end

          it 'should raise an error' do
            expect { configuration[:rations] = 'Fortnightly' }
              .to raise_error error_message
          end
        end

        describe 'with a valid symbol and a valid value' do
          it 'should clear the value' do
            expect { configuration[:rations] = 'Monthly' }
              .to change(configuration, :rations)
              .to be 'Monthly'
          end
        end
      end
    end
  end

  describe '#dig' do
    it { expect(instance).to respond_to(:dig).with_unlimited_arguments }

    describe 'with an invalid string' do
      it { expect(instance.dig 'psionics').to be nil }
    end

    describe 'with an invalid symbol' do
      it { expect(instance.dig :psionics).to be nil }
    end

    describe 'with an invalid sequence of strings' do
      it 'should return nil' do
        expect(instance.dig('spells', 'evocation', 'magic_missile')).to be nil
      end
    end

    describe 'with an invalid sequence of symbols' do
      it 'should return nil' do
        expect(instance.dig(:spells, :evocation, :magic_missile)).to be nil
      end
    end

    context 'when an option is defined' do
      include_context 'when an option is defined'

      describe 'with an invalid string' do
        it { expect(instance.dig 'psionics').to be nil }
      end

      describe 'with an invalid symbol' do
        it { expect(instance.dig :psionics).to be nil }
      end

      describe 'with a valid string' do
        it { expect(instance.dig 'rations').to be nil }
      end

      describe 'with a valid symbol' do
        it { expect(instance.dig :rations).to be nil }
      end

      describe 'with an invalid sequence of strings' do
        it 'should return nil' do
          expect(instance.dig('spells', 'evocation', 'magic_missile')).to be nil
        end
      end

      describe 'with an invalid sequence of symbols' do
        it 'should return nil' do
          expect(instance.dig(:spells, :evocation, :magic_missile)).to be nil
        end
      end

      context 'when the data includes a value for the option' do
        let(:initial_state) { data }

        describe 'with a valid string' do
          it { expect(instance.dig 'rations').to be == data[:rations] }
        end

        describe 'with a valid symbol' do
          it { expect(instance.dig :rations).to be == data[:rations] }
        end
      end
    end

    context 'when a namespace is defined' do
      include_context 'when a namespace is defined'

      describe 'with an invalid string' do
        it { expect(instance.dig 'psionics').to be nil }
      end

      describe 'with an invalid symbol' do
        it { expect(instance.dig :psionics).to be nil }
      end

      describe 'with a valid scoped string' do
        it { expect(instance.dig 'armor', 'materials').to be nil }
      end

      describe 'with a valid scoped symbol' do
        it { expect(instance.dig :armor, :materials).to be nil }
      end

      context 'when the data includes a value for the option' do
        let(:initial_state) { data }

        describe 'with a valid scoped string' do
          it 'should find the value' do
            expect(instance.dig 'armor', 'materials')
              .to be == data[:armor][:materials]
          end
        end

        describe 'with a valid scoped symbol' do
          it 'should find the value' do
            expect(instance.dig :armor, :materials)
              .to be == data[:armor][:materials]
          end
        end
      end
    end

    context 'when many configuration options are defined' do
      include_context 'when many configuration options are defined'

      describe 'with an invalid string' do
        it { expect(instance.dig 'psionics').to be nil }
      end

      describe 'with an invalid symbol' do
        it { expect(instance.dig :psionics).to be nil }
      end

      describe 'with a valid scoped string' do
        it 'should return nil' do
          expect(instance.dig 'weapons', 'swords', 'default_attack').to be nil
        end
      end

      describe 'with a valid scoped symbol' do
        it 'should return nil' do
          expect(instance.dig :weapons, :swords, :default_attack).to be nil
        end
      end

      context 'when the data includes a value for the option' do
        let(:initial_state) { data }

        describe 'with a valid scoped string' do
          it 'should find the value' do
            expect(instance.dig 'weapons', 'swords', 'default_attack')
              .to be == data[:weapons][:swords][:default_attack]
          end
        end

        describe 'with a valid scoped symbol' do
          it 'should find the value' do
            expect(instance.dig :weapons, :swords, :default_attack)
              .to be == data[:weapons][:swords][:default_attack]
          end
        end
      end
    end
  end

  describe '#fetch' do
    it 'should define the method' do
      expect(instance).to respond_to(:fetch).with(1..2).arguments
    end

    describe 'with nil' do
      it 'should raise an error' do
        expect { configuration.fetch nil }
          .to raise_error TypeError, 'nil is not a symbol nor a string'
      end
    end

    describe 'with an invalid string' do
      it 'should raise an error' do
        expect { configuration.fetch 'psionics' }
          .to raise_error KeyError, 'key not found: "psionics"'
      end

      describe 'with a block' do
        it 'should evaluate and return the block' do
          expect(configuration.fetch('psionics') { 'No value' })
            .to be == 'No value'
        end
      end

      describe 'with a block with a yielded parameter' do
        it 'should evaluate and return the block' do
          expect(configuration.fetch('psionics') { |key| "Unknown key #{key}" })
            .to be == 'Unknown key psionics'
        end
      end

      describe 'with a default value' do
        it 'should return the default value' do
          expect(configuration.fetch('psionics', 'unknown'))
            .to be == 'unknown'
        end
      end
    end

    describe 'with an invalid symbol' do
      it 'should raise an error' do
        expect { configuration.fetch :psionics }
          .to raise_error KeyError, 'key not found: :psionics'
      end

      describe 'with a block' do
        it 'should evaluate and return the block' do
          expect(configuration.fetch(:psionics) { 'No value' })
            .to be == 'No value'
        end
      end

      describe 'with a block with a yielded parameter' do
        it 'should evaluate and return the block' do
          expect(configuration.fetch(:psionics) { |key| "Unknown key #{key}" })
            .to be == 'Unknown key psionics'
        end
      end

      describe 'with a default value' do
        it 'should return the default value' do
          expect(configuration.fetch(:psionics, 'unknown'))
            .to be == 'unknown'
        end
      end
    end

    context 'when an option is defined' do
      include_context 'when an option is defined'

      describe 'with nil' do
        it 'should raise an error' do
          expect { configuration.fetch nil }
            .to raise_error TypeError, 'nil is not a symbol nor a string'
        end
      end

      describe 'with an invalid string' do
        it 'should raise an error' do
          expect { configuration.fetch 'psionics' }
            .to raise_error KeyError, 'key not found: "psionics"'
        end

        describe 'with a block' do
          it 'should evaluate and return the block' do
            expect(configuration.fetch('psionics') { 'No value' })
              .to be == 'No value'
          end
        end

        describe 'with a block with a yielded parameter' do
          it 'should evaluate and return the block' do
            expect(
              configuration.fetch('psionics') { |key| "Unknown key #{key}" }
            )
              .to be == 'Unknown key psionics'
          end
        end

        describe 'with a default value' do
          it 'should return the default value' do
            expect(configuration.fetch('psionics', 'unknown'))
              .to be == 'unknown'
          end
        end
      end

      describe 'with an invalid symbol' do
        it 'should raise an error' do
          expect { configuration.fetch :psionics }
            .to raise_error KeyError, 'key not found: :psionics'
        end

        describe 'with a block' do
          it 'should evaluate and return the block' do
            expect(configuration.fetch(:psionics) { 'No value' })
              .to be == 'No value'
          end
        end

        describe 'with a block with a yielded parameter' do
          it 'should evaluate and return the block' do
            expect(
              configuration.fetch(:psionics) { |key| "Unknown key #{key}" }
            )
              .to be == 'Unknown key psionics'
          end
        end

        describe 'with a default value' do
          it 'should return the default value' do
            expect(configuration.fetch(:psionics, 'unknown'))
              .to be == 'unknown'
          end
        end
      end

      describe 'with a valid string' do
        it 'should return the value' do
          expect(configuration.fetch 'rations').to be nil
        end

        describe 'with a block' do
          it 'should return the value' do
            expect(configuration.fetch('rations') { 'No value' }).to be nil
          end
        end

        describe 'with a block with a yielded parameter' do
          it 'should return the value' do
            expect(
              configuration.fetch('rations') { |key| "Unknown key #{key}" }
            )
              .to be nil
          end
        end

        describe 'with a default value' do
          it 'should return the value' do
            expect(configuration.fetch('rations', 'unknown')).to be nil
          end
        end
      end

      describe 'with a valid symbol' do
        it 'should return the value' do
          expect(configuration.fetch :rations).to be nil
        end

        describe 'with a block' do
          it 'should return the value' do
            expect(configuration.fetch(:rations) { 'No value' }).to be nil
          end
        end

        describe 'with a block with a yielded parameter' do
          it 'should return the value' do
            expect(
              configuration.fetch(:rations) { |key| "Unknown key #{key}" }
            )
              .to be nil
          end
        end

        describe 'with a default value' do
          it 'should return the value' do
            expect(configuration.fetch(:rations, 'unknown')).to be nil
          end
        end
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when the data includes a value for the option' do
        let(:initial_state) { data }

        describe 'with a valid string' do
          it 'should return the value' do
            expect(configuration.fetch 'rations')
              .to be == data[:rations]
          end

          describe 'with a block' do
            it 'should return the value' do
              expect(configuration.fetch('rations') { 'No value' })
                .to be == data[:rations]
            end
          end

          describe 'with a block with a yielded parameter' do
            it 'should return the value' do
              expect(
                configuration.fetch('rations') { |key| "Unknown key #{key}" }
              )
                .to be == data[:rations]
            end
          end

          describe 'with a default value' do
            it 'should return the value' do
              expect(configuration.fetch('rations', 'unknown'))
                .to be == data[:rations]
            end
          end
        end

        describe 'with a valid symbol' do
          it 'should return the value' do
            expect(configuration.fetch :rations)
              .to be == data[:rations]
          end

          describe 'with a block' do
            it 'should return the value' do
              expect(configuration.fetch(:rations) { 'No value' })
                .to be == data[:rations]
            end
          end

          describe 'with a block with a yielded parameter' do
            it 'should return the value' do
              expect(
                configuration.fetch(:rations) { |key| "Unknown key #{key}" }
              )
                .to be == data[:rations]
            end
          end

          describe 'with a default value' do
            it 'should return the value' do
              expect(configuration.fetch(:rations, 'unknown'))
                .to be == data[:rations]
            end
          end
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end
  end
end
