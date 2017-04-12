# spec/sleeping_king_studios/tools/toolbox/configuration_spec.rb

require 'sleeping_king_studios/tools/toolbox/configuration'

RSpec.describe SleepingKingStudios::Tools::Toolbox::Configuration do
  shared_context 'when the data source is nil' do
    let(:instance) { described_class.new }
  end # shared_context

  shared_context 'when the data source is an object' do
    let(:instance) { described_class.new(build_configuration(hash), &block) }

    def build_configuration hsh
      obj = Struct.new(*hsh.keys).new

      hsh.each do |key, value|
        val = value.is_a?(Hash) ? build_configuration(value) : value

        obj.send :"#{key}=", val
      end # each

      obj
    end # method build_configuration
  end # shared_context

  shared_context 'when many configuration options are defined' do
    let(:block) do
      lambda do |config|
        config.option :rations

        config.namespace :armor do |armor|
          armor.option :materials
        end # namespace

        config.namespace :weapons do |weapons|
          weapons.option :allow_polearms

          weapons.namespace :swords do |swords|
            swords.option :upgrade_parts
          end # namespace
        end # namespace
      end # lambda
    end # let
  end # shared_context

  let(:hash) do
    {
      :weapons => {
        :swords => {
          :default_attack => :slash,
          :upgrade_parts  => %w(hilt tang pommel)
        }, # end swords
        :bows => {
          :quiver_capacity => 30
        }, # end bows
        :allow_polearms => true
      }, # end weapons
      :armor => {
        :materials => %w(leather iron steel mithril adamantium orichalcum)
      }, # end armor
      :rations          => '1/day',
      :tutorial_monster => ->() { double('goblin') },
      :fix_bards        => false,
      :eleven_foot_pole => nil
    } # end hash
  end # let
  let(:block)    { ->(_) {} }
  let(:instance) { described_class.new(hash, &block) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }

    wrap_context 'when many configuration options are defined' do
      it 'should evaluate the block' do
        expect(instance.rations).
          to be == hash.fetch(:rations)

        expect(instance.armor.materials).
          to be == hash.fetch(:armor).fetch(:materials)

        expect(instance.weapons.swords.upgrade_parts).
          to be == hash.fetch(:weapons).fetch(:swords).fetch(:upgrade_parts)
      end # it
    end # wrap_context
  end # describe

  describe '::namespace' do
    let(:described_class) { Class.new(super()) }

    it 'should define the class method' do
      expect(described_class).
        to respond_to(:namespace).
        with(1).argument.and_a_block
    end # it

    it 'should define the namespace' do
      described_class.namespace :psionics

      expect(instance.psionics).
        to be_a SleepingKingStudios::Tools::Toolbox::Configuration
    end # it

    it 'should set the root namespace' do
      described_class.namespace :psionics

      expect(instance.psionics.send :__root_namespace__).to be instance
    end # it

    context 'when a value is defined for the namespace' do
      it 'should define the namespace' do
        described_class.namespace :armor do |config|
          config.option :materials
        end # namespace

        expect(instance.armor).
          to be_a SleepingKingStudios::Tools::Toolbox::Configuration
        expect(instance.armor.materials).
          to be == hash.fetch(:armor).fetch(:materials)
      end # it
    end # context

    context 'when nested hash is defined for the namespace' do
      it 'should define the nested namespaces' do
        described_class.namespace :weapons do |config|
          config.namespace :swords do |swords|
            swords.option :default_attack
          end # namespace
        end # namespace

        expect(instance.weapons).
          to be_a SleepingKingStudios::Tools::Toolbox::Configuration
        expect(instance.weapons.swords).
          to be_a SleepingKingStudios::Tools::Toolbox::Configuration
        expect(instance.weapons.swords.default_attack).
          to be == hash.fetch(:weapons).fetch(:swords).fetch(:default_attack)
      end # it

      it 'should set the root namespace' do
        described_class.namespace :weapons do |config|
          config.namespace :swords
        end # namespace

        expect(instance.weapons.swords.send :__root_namespace__).to be instance
      end # it
    end # context

    context 'when a namespace is defined on a subclass' do
      let(:subclass) do
        Class.new(described_class) do
          option :moral_axes
        end # class
      end # let
      let(:instance) { subclass.new(hash) }

      it 'should not recursively define itself' do
        described_class.namespace :planar_mechanics do |planar_mechanics|
          planar_mechanics.option :elemental_affinities
        end # described_class

        expect(instance.planar_mechanics).
          to be_a SleepingKingStudios::Tools::Toolbox::Configuration
        expect(instance.planar_mechanics).not_to be_a subclass
        expect(instance.planar_mechanics).
          not_to respond_to(:planar_mechanics, :moral_axes)
      end # it
    end # context
  end # describe

  describe '::option' do
    let(:described_class) { Class.new(super()) }

    it 'should define the class method' do
      expect(described_class).
        to respond_to(:option).
        with(1).argument.
        and_keywords(:allow_nil, :default, :enum)
    end # it

    it 'should define the accessor' do
      described_class.option :magic_enabled

      expect(instance).to have_reader(:magic_enabled).with_value(nil)
    end # it

    it 'should define the mutator' do
      described_class.option :magic_enabled

      expect(instance).to have_writer(:magic_enabled)

      expect { instance.magic_enabled = :confirmed }.
        to change(instance, :magic_enabled).
        to be == :confirmed
    end # it

    context 'when a value is defined for the option' do
      it 'should define the accessor' do
        described_class.option :rations

        expect(instance).
          to have_reader(:rations).
          with_value(hash.fetch :rations)
      end # it

      it 'should define the mutator' do
        described_class.option :rations

        expect(instance).to have_writer(:rations)

        expect { instance.rations = :confirmed }.
          to change(instance, :rations).
          to be == :confirmed
      end # it
    end # context

    describe 'with :default => object' do
      let(:default) { :new_value }

      it 'should define the accessor' do
        described_class.option :magic_enabled, :default => default

        expect(instance).
          to have_reader(:magic_enabled).
          with_value(be == default)
      end # it

      context 'when a nil value is defined for the option' do
        it 'should define the accessor' do
          described_class.option :eleven_foot_pole, :default => default

          expect(instance).
          to have_reader(:eleven_foot_pole).
          with_value(default)
        end # it
      end # context

      context 'when a falsy value is defined for the option' do
        it 'should define the accessor' do
          described_class.option :fix_bards, :default => default

          expect(instance).
            to have_reader(:fix_bards).
            with_value(hash.fetch :fix_bards)
        end # it
      end # context

      context 'when a value is defined for the option' do
        it 'should define the accessor' do
          described_class.option :rations, :default => default

          expect(instance).
            to have_reader(:rations).
            with_value(hash.fetch :rations)
        end # it
      end # context
    end # describe

    describe 'with :default => proc' do
      let(:default) { ->() { :custom_value } }

      it 'should define the accessor' do
        described_class.option :magic_enabled, :default => default

        expect(instance).
          to have_reader(:magic_enabled).
          with_value(be == default.call)
      end # it

      context 'when a nil value is defined for the option' do
        it 'should define the accessor' do
          described_class.option :eleven_foot_pole, :default => default

          expect(instance).
            to have_reader(:eleven_foot_pole).
            with_value(default.call)
        end # it
      end # context

      context 'when a falsy value is defined for the option' do
        it 'should define the accessor' do
          described_class.option :fix_bards, :default => default

          expect(instance).
            to have_reader(:fix_bards).
            with_value(hash.fetch :fix_bards)
        end # it
      end # context

      context 'when a value is defined for the option' do
        it 'should define the accessor' do
          described_class.option :rations, :default => default

          expect(instance).
            to have_reader(:rations).
            with_value(hash.fetch :rations)
        end # it
      end # context
    end # describe

    describe 'with :default => method_call' do
      let(:default) { ->() { scouter_level } }

      before(:example) do
        instance.define_singleton_method :scouter_level, ->() { 9_001 }
      end # before_example

      it 'should define the accessor' do
        described_class.option :magic_enabled, :default => default

        expect(instance).
          to have_reader(:magic_enabled).
          with_value(be == instance.scouter_level)
      end # it

      context 'when a nil value is defined for the option' do
        it 'should define the accessor' do
          described_class.option :eleven_foot_pole, :default => default

          expect(instance).
            to have_reader(:eleven_foot_pole).
            with_value(instance.scouter_level)
        end # it
      end # context

      context 'when a falsy value is defined for the option' do
        it 'should define the accessor' do
          described_class.option :fix_bards, :default => default

          expect(instance).
            to have_reader(:fix_bards).
            with_value(hash.fetch :fix_bards)
        end # it
      end # context

      context 'when a value is defined for the option' do
        it 'should define the accessor' do
          described_class.option :rations, :default => default

          expect(instance).
            to have_reader(:rations).
            with_value(hash.fetch :rations)
        end # it
      end # context

      context 'when the option is defined on a nested namespace' do
        it 'should define the accessor' do
          described_class.namespace :weapons do |weapons|
            weapons.namespace :swords do |swords|
              swords.option :overkill_damage, :default => default
            end # namespace
          end # namespace

          expect(instance.weapons.swords.overkill_damage).
            to be == instance.scouter_level
        end # it
      end # context
    end # describe

    describe 'with :enum => an Array' do
      let(:hash) { super().fetch(:weapons) }
      let(:enum) { %w(spear pike halberd bohemian-earspoon) }
      let(:name) { :starting_polearm }
      let(:opts) { { :enum => enum } }

      before(:example) do
        described_class.option name, **opts
      end # before example

      def error_message value
        array_tools   = ::SleepingKingStudios::Tools::ArrayTools
        valid_options =
          array_tools.humanize_list(
            enum.map(&:inspect),
            :last_separator => ' or '
          ) # end humanize_list

        "expected option to be #{valid_options}, but was #{value.inspect}"
      end # method error_message

      describe 'should define the accessor' do
        it { expect(instance).to have_reader(:starting_polearm) }

        it 'should raise an error' do
          expect { instance.starting_polearm }.
            to raise_error error_message(nil)
        end # it

        describe 'with :allow_nil => true' do
          let(:opts) { super().merge :allow_nil => true }

          it 'should return nil' do
            expect(instance.starting_polearm).to be nil
          end # it
        end # describe
      end # describe

      describe 'should define the mutator' do
        it { expect(instance).to have_writer(:starting_polearm) }

        describe 'with nil' do
          it 'should raise an error' do
            expect { instance.starting_polearm = nil }.
              to raise_error error_message(nil)
          end # it
        end # describe

        describe 'with an invalid value' do
          it 'should raise an error' do
            expect { instance.starting_polearm = 'bec-du-corbin' }.
              to raise_error error_message('bec-du-corbin')
          end # it
        end # describe

        describe 'with a valid value' do
          it 'should set the value' do
            instance.starting_polearm = 'halberd'

            expect(instance.starting_polearm).to be == 'halberd'
          end # it
        end # describe
      end # describe

      context 'when an invalid value is defined for the option' do
        let(:hash) { super().merge :starting_polearm => 'bec-du-corbin' }

        describe 'should define the accessor' do
          it 'should raise an error' do
            expect { instance.starting_polearm }.
              to raise_error error_message('bec-du-corbin')
          end # it
        end # describe

        describe 'should define the mutator' do
          it 'should set the value' do
            instance.starting_polearm = 'halberd'

            expect(instance.starting_polearm).to be == 'halberd'
          end # it
        end # describe
      end # context

      context 'when a valid value is defined for the option' do
        let(:hash) { super().merge :starting_polearm => 'bohemian-earspoon' }

        describe 'should define the accessor' do
          it 'should return the value' do
            expect(instance.starting_polearm).to be == 'bohemian-earspoon'
          end # it
        end # describe

        describe 'should define the mutator' do
          it 'should set the value' do
            expect { instance.starting_polearm = 'halberd' }.
              to change(instance, :starting_polearm).
              to be == 'halberd'
          end # it
        end # describe
      end # context
    end # describe
  end # describe

  describe '#__data__' do
    def expect_object_to_equal_hash obj, hsh
      hsh.each do |key, expected|
        expect(obj).to respond_to(key).with(0).arguments

        value = obj.send(key)

        if expected.is_a?(Hash)
          expect_object_to_equal_hash value, expected
        else
          expect(value).to be == expected
        end # if-else
      end # each
    end # method obj, hsh

    it 'should define the private reader' do
      expect(instance).not_to respond_to(:__data__)

      expect(instance).to respond_to(:__data__, true).with(0).arguments
    end # it

    it { expect_object_to_equal_hash instance.send(:__data__), hash }

    wrap_context 'when the data source is nil' do
      it { expect(instance.send :__data__).to be nil }
    end # wrap_context

    wrap_context 'when the data source is an object' do
      it { expect_object_to_equal_hash instance.send(:__data__), hash }
    end # wrap_context
  end # describe

  describe '#__root_namespace__' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:__root_namespace__)

      expect(instance).
        to respond_to(:__root_namespace__, true).
        with(0).arguments
    end # it

    it { expect(instance.send :__root_namespace__).to be instance }
  end # describe
end # describe
