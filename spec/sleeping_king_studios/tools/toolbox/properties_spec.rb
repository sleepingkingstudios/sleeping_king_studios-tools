# frozen_string_literal: true

require 'bigdecimal'

require 'sleeping_king_studios/tools/toolbox/properties'

=begin
class LaunchSite
  include SleepingKingStudios::Tools::Toolbox::Properties

  property :name
  property :latitude,  type: Float
  property :longitude, type: Float
end

FuelProperties = SleepingKingStudios::Tools::Toolbox::Properties.new(
  :volume,
  fuel_type: {
    # enum: %w[LF LF/O Monopropellent Xenon],
    type: String
  }
)

class RocketPart
  include SleepingKingStudios::Tools::Toolbox::Properties

  property :name
  property :mass
end

class RocketEngine < RocketPart
  include FuelProperties

  property :thrust
end

RSpec.describe LaunchSite do
  subject(:launch_site) { described_class.new(**attributes) }

  let(:attributes) do
    {
      name: 'Kerbal Space Center'
    }
  end

  describe '.properties' do
    let(:expected) { %w[name latitude longitude] }

    it { expect(described_class.properties.keys).to be == expected }
  end

  describe '#name' do
    it { expect(launch_site.name).to be == attributes[:name] }
  end

  describe '#properties' do
    let(:expected) do
      {
        'latitude'  => nil,
        'longitude' => nil,
        'name'      => attributes[:name]
      }
    end

    it { expect(launch_site.properties).to contain_exactly(*expected) }
  end
end

RSpec.describe RocketEngine do
  describe '.properties' do
    let(:expected) { %w[fuel_type mass name thrust volume] }

    it { expect(described_class.properties.keys).to contain_exactly(*expected) }
  end
end

RSpec.describe RocketPart do
  describe '.properties' do
    let(:expected) { %w[mass name] }

    it { expect(described_class.properties.keys).to contain_exactly(*expected) }
  end
end
=end

RSpec.describe SleepingKingStudios::Tools::Toolbox::Properties do
  extend  RSpec::SleepingKingStudios::Concerns::ExampleConstants
  include RSpec::SleepingKingStudios::Examples::PropertyExamples

  shared_context 'when included in a class' do
    subject(:widget) { described_class.new(**properties) }

    let(:described_class) { Spec::Widget }
    let(:properties)      { {} }

    example_class 'Spec::Widget' do |klass|
      klass.include SleepingKingStudios::Tools::Toolbox::Properties # rubocop:disable RSpec/DescribedClass
    end
  end

  shared_context 'with a subclass' do
    let(:described_class) { Spec::Gadget }

    example_class 'Spec::Gadget', 'Spec::Widget'
  end

  let(:described_class) do
    SleepingKingStudios::Tools::Toolbox::Properties.new # rubocop:disable RSpec/DescribedClass
  end

  describe '::Property' do
    subject(:property) { described_class::Property.new(**constructor_options) }

    let(:described_class) { SleepingKingStudios::Tools::Toolbox::Properties } # rubocop:disable RSpec/DescribedClass
    let(:constructor_options) do
      {
        error_message: 'must be a valid name',
        name:          'name',
        predicate:     false,
        optional:      false,
        read_only:     false,
        type:          String
      }
    end

    include_examples 'should define constant', :Property, -> { be_a Class }

    describe '#error_message' do
      include_examples 'should define reader',
        :error_message,
        -> { constructor_options[:error_message] }
    end

    describe '#name' do
      include_examples 'should define reader',
        :name,
        -> { constructor_options[:name] }
    end

    describe '#optional?' do
      include_examples 'should define predicate',
        :optional?,
        -> { constructor_options[:optional] }
    end

    describe '#predicate?' do
      include_examples 'should define predicate',
        :predicate?,
        -> { constructor_options[:predicate] }
    end

    describe '#read_only?' do
      include_examples 'should define predicate',
        :read_only?,
        -> { constructor_options[:read_only] }
    end

    describe '#type' do
      include_examples 'should define reader',
        :type,
        -> { constructor_options[:type] }
    end

    # rubocop:disable RSpec/NestedGroups
    describe '#validate' do
      let(:error_message) do
        "#{constructor_options[:name]} #{constructor_options[:error_message]}"
      end

      it { expect(property).to respond_to(:validate).with(1).argument }

      context 'when initialized with type: nil' do
        let(:constructor_options) { super().merge(type: nil) }

        describe 'with nil' do
          let(:value) { nil }

          it { expect { property.validate(value) }.not_to raise_error }
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          it { expect { property.validate(value) }.not_to raise_error }
        end
      end

      context 'when initialized with type: a Class' do
        let(:constructor_options) { super().merge(type: StandardError) }

        describe 'with nil' do
          let(:value) { nil }

          it 'should raise an exception' do
            expect { property.validate(value) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          it 'should raise an exception' do
            expect { property.validate(value) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an instance of the Class' do
          let(:value) { StandardError.new }

          it { expect { property.validate(value) }.not_to raise_error }
        end

        describe 'with an instance of a subclass' do
          let(:value) { RuntimeError.new }

          it { expect { property.validate(value) }.not_to raise_error }
        end

        context 'when initialized with optional: true' do
          let(:constructor_options) { super().merge(optional: true) }

          describe 'with nil' do
            let(:value) { nil }

            it { expect { property.validate(value) }.not_to raise_error }
          end

          describe 'with an Object' do
            let(:value) { Object.new.freeze }

            it 'should raise an exception' do
              expect { property.validate(value) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with an instance of the Class' do
            let(:value) { StandardError.new }

            it { expect { property.validate(value) }.not_to raise_error }
          end

          describe 'with an instance of a subclass' do
            let(:value) { RuntimeError.new }

            it { expect { property.validate(value) }.not_to raise_error }
          end
        end
      end

      context 'when initialized with type: a Module' do
        let(:constructor_options) { super().merge(type: Enumerable) }

        describe 'with nil' do
          let(:value) { nil }

          it 'should raise an exception' do
            expect { property.validate(value) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          it 'should raise an exception' do
            expect { property.validate(value) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an object extending the Module' do
          let(:value) { [] }

          it { expect { property.validate(value) }.not_to raise_error }
        end

        context 'when initialized with optional: true' do
          let(:constructor_options) { super().merge(optional: true) }

          describe 'with nil' do
            let(:value) { nil }

            it { expect { property.validate(value) }.not_to raise_error }
          end

          describe 'with an Object' do
            let(:value) { Object.new.freeze }

            it 'should raise an exception' do
              expect { property.validate(value) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with an object extending the Module' do
            let(:value) { [] }

            it { expect { property.validate(value) }.not_to raise_error }
          end
        end
      end

      context 'when initialized with type: a Proc' do
        let(:type)                { ->(value) { value >= 0 } }
        let(:constructor_options) { super().merge(type: type) }

        describe 'with nil' do
          let(:value) { nil }

          it 'should raise an exception' do
            expect { property.validate(value) }.to raise_error NoMethodError
          end
        end

        describe 'with a non-matching value' do
          let(:value) { -1 }

          it 'should raise an exception' do
            expect { property.validate(value) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a matching value' do
          let(:value) { 1 }

          it { expect { property.validate(value) }.not_to raise_error }
        end

        context 'when initialized with optional: true' do
          let(:constructor_options) { super().merge(optional: true) }

          describe 'with nil' do
            let(:value) { nil }

            it { expect { property.validate(value) }.not_to raise_error }
          end

          describe 'with a non-matching value' do
            let(:value) { -1 }

            it 'should raise an exception' do
              expect { property.validate(value) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a matching value' do
            let(:value) { 1 }

            it { expect { property.validate(value) }.not_to raise_error }
          end
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups
  end

  describe '.new' do
    pending
  end

  describe '.properties' do
    def be_a_property( # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
      name,
      error_message: nil,
      boolean:       false,
      optional:      false,
      predicate:     nil,
      read_only:     false,
      type:          nil
    )
      message = error_message || expected_error(boolean: boolean, type: type)

      be_a(described_class::Property).and(
        have_attributes(
          error_message: message,
          name:          name,
          optional?:     optional,
          predicate?:    predicate.nil? ? boolean : (predicate || false),
          read_only?:    read_only,
          type:          type || (boolean ? be_a(Proc) : nil)
        )
      )
    end

    def expected_error(boolean:, type:)
      if boolean
        'must be true or false'
      elsif type.is_a?(Module)
        "must be an instance of #{type.name}"
      else
        'is invalid'
      end
    end

    include_examples 'should define class reader', :properties, {}

    context 'when there are many defined properties' do
      let(:expected_keys) { %w[mass name nuclear] }

      before(:example) do
        described_class.property(:mass,    type: BigDecimal)
        described_class.property(:name,    type: String)
        described_class.property(:nuclear, type: :boolean)
      end

      it 'should contain the expected properties' do
        expect(described_class.properties.keys)
          .to contain_exactly(*expected_keys)
      end

      it 'should define the "mass" property' do
        expect(described_class.properties['mass'])
          .to be_a_property('mass', type: BigDecimal)
      end

      it 'should define the "name" property' do
        expect(described_class.properties['name'])
          .to be_a_property('name', type: String)
      end

      it 'should define the "nuclear" property' do
        expect(described_class.properties['nuclear'])
          .to be_a_property('nuclear', boolean: true)
      end
    end

    wrap_context 'when included in a class' do
      include_examples 'should define class reader', :properties, {}

      context 'when there are many defined properties' do
        let(:expected_keys) { %w[mass name nuclear] }

        before(:example) do
          described_class.property(:mass,    type: BigDecimal)
          described_class.property(:name,    type: String)
          described_class.property(:nuclear, type: :boolean)
        end

        it 'should contain the expected properties' do
          expect(described_class.properties.keys)
            .to contain_exactly(*expected_keys)
        end

        it 'should define the "mass" property' do
          expect(described_class.properties['mass'])
            .to be_a_property('mass', type: BigDecimal)
        end

        it 'should define the "name" property' do
          expect(described_class.properties['name'])
            .to be_a_property('name', type: String)
        end

        it 'should define the "nuclear" property' do
          expect(described_class.properties['nuclear'])
            .to be_a_property('nuclear', boolean: true)
        end
      end

      context 'with an included property module' do
        pending
      end

      context 'with multiple included property modules' do
        pending
      end

      wrap_context 'with a subclass' do
        pending
      end
    end
  end

  describe '.property' do
    shared_examples 'should define the property' do
      it 'should define the property', :aggregate_failures do
        property = described_class.property(property_name, **property_options)

        expect(described_class.properties.key?(property_name.to_s)).to be true

        expect(described_class.properties[property_name.to_s]).to be property
      end

      it { expect(property.name).to be == property_name.to_s }
    end

    let(:property) do
      described_class.property(property_name, **property_options)
    end
    let(:property_name)    { :value }
    let(:property_options) { {} }

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:property)
        .with(1).argument
        .and_keywords(:predicate, :read_only, :type)
    end

    describe 'with nil' do
      let(:error_message) { "name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.property nil }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:error_message) { 'name is not a String or a Symbol' }

      it 'should raise an exception' do
        expect { described_class.property Object.new.freeze }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty string' do
      let(:error_message) { "name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.property '' }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty symbol' do
      let(:error_message) { "name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.property :'' }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a String' do
      let(:property_name) { 'value' }

      include_examples 'should define the property'

      it { expect(property.error_message).to be == 'is invalid' }

      it { expect(property.predicate?).to be false }

      it { expect(property.read_only?).to be false }

      it { expect(property.type).to be nil }
    end

    describe 'with a symbol' do
      let(:property_name) { :value }

      include_examples 'should define the property'

      it { expect(property.error_message).to be == 'is invalid' }

      it { expect(property.predicate?).to be false }

      it { expect(property.read_only?).to be false }

      it { expect(property.type).to be nil }
    end

    describe 'with predicate: false' do
      let(:property_options) { super().merge(predicate: false) }

      include_examples 'should define the property'

      it { expect(property.predicate?).to be false }
    end

    describe 'with predicate: true' do
      let(:property_options) { super().merge(predicate: true) }

      include_examples 'should define the property'

      it { expect(property.predicate?).to be true }
    end

    describe 'with read_only: false' do
      let(:property_options) { super().merge(read_only: false) }

      include_examples 'should define the property'

      it { expect(property.read_only?).to be false }
    end

    describe 'with read_only: true' do
      let(:property_options) { super().merge(read_only: true) }

      include_examples 'should define the property'

      it { expect(property.read_only?).to be true }
    end

    describe 'with type: an Object' do
      let(:error_message) do
        'type must be a Class or Module, the name of a Class or Module,' \
          ' or a Proc'
      end

      it 'should raise an exception' do
        expect do
          described_class.property(property_name, type: Object.new.freeze)
        end
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with type: an empty String' do
      let(:error_message) do
        'type must be a Class or Module, the name of a Class or Module,' \
          ' or a Proc'
      end

      it 'should raise an exception' do
        expect { described_class.property(property_name, type: '') }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with type: an empty Symbol' do
      let(:error_message) do
        'type must be a Class or Module, the name of a Class or Module,' \
          ' or a Proc'
      end

      it 'should raise an exception' do
        expect { described_class.property(property_name, type: :'') }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with type: a Class' do
      let(:property_options) { super().merge(type: String) }
      let(:error_message)    { 'must be an instance of String' }

      include_examples 'should define the property'

      it { expect(property.error_message).to be == error_message }

      it { expect(property.type).to be String }

      describe 'with an anonymous class' do
        let(:type)             { Class.new(Hash) }
        let(:property_options) { super().merge(type: type) }
        let(:error_message) do
          "must be an instance of #{type.inspect} (Hash)"
        end

        it { expect(property.error_message).to be == error_message }
      end

      describe 'with error_message: value' do
        let(:error_message)    { 'must be pointed toward space' }
        let(:property_options) { super().merge(error_message: error_message) }

        it { expect(property.error_message).to be == error_message }
      end
    end

    describe 'with type: a Module' do
      let(:property_options) { super().merge(type: Enumerable) }
      let(:error_message)    { 'must be an instance of Enumerable' }

      include_examples 'should define the property'

      it { expect(property.error_message).to be == error_message }

      it { expect(property.type).to be Enumerable }

      describe 'with an anonymous module' do
        let(:type)             { Module.new }
        let(:property_options) { super().merge(type: type) }
        let(:error_message)    { "must be an instance of #{type.inspect}" }

        it { expect(property.error_message).to be == error_message }
      end

      describe 'with error_message: value' do
        let(:error_message)    { 'must be pointed toward space' }
        let(:property_options) { super().merge(error_message: error_message) }

        it { expect(property.error_message).to be == error_message }
      end
    end

    describe 'with type: a Proc' do
      let(:type) do
        ->(value) { value.is_a?(Integer) && value >= 0 }
      end
      let(:property_options) { super().merge(type: type) }

      include_examples 'should define the property'

      it { expect(property.error_message).to be == 'is invalid' }

      it { expect(property.type).to be type }

      describe 'with error_message: value' do
        let(:error_message)    { 'must be pointed toward space' }
        let(:property_options) { super().merge(error_message: error_message) }

        it { expect(property.error_message).to be == error_message }
      end
    end

    describe 'with type: a String' do
      let(:property_options) { super().merge(type: 'String') }
      let(:error_message)    { 'must be an instance of String' }

      include_examples 'should define the property'

      it { expect(property.error_message).to be == error_message }

      it { expect(property.type).to be String }

      describe 'with error_message: value' do
        let(:error_message)    { 'must be pointed toward space' }
        let(:property_options) { super().merge(error_message: error_message) }

        it { expect(property.error_message).to be == error_message }
      end
    end

    describe 'with type: a Symbol' do
      let(:property_options) { super().merge(type: :symbol) }
      let(:error_message)    { 'must be an instance of Symbol' }

      include_examples 'should define the property'

      it { expect(property.error_message).to be == error_message }

      it { expect(property.type).to be Symbol }

      describe 'with error_message: value' do
        let(:error_message)    { 'must be pointed toward space' }
        let(:property_options) { super().merge(error_message: error_message) }

        it { expect(property.error_message).to be == error_message }
      end
    end

    describe 'with type: "boolean"' do
      let(:property_options) { super().merge(type: 'boolean') }
      let(:error_message)    { 'must be true or false' }

      include_examples 'should define the property'

      it { expect(property.error_message).to be == error_message }

      it { expect(property.predicate?).to be true }

      it { expect(property.type).to be_a Proc }

      describe 'with error_message: value' do
        let(:error_message)    { 'must be pointed toward space' }
        let(:property_options) { super().merge(error_message: error_message) }

        it { expect(property.error_message).to be == error_message }
      end

      describe 'with predicate: false' do
        let(:property_options) { super().merge(predicate: false) }

        it { expect(property.predicate?).to be false }
      end

      describe 'with predicate: true' do
        let(:property_options) { super().merge(predicate: true) }

        it { expect(property.predicate?).to be true }
      end
    end

    describe 'with type: :boolean' do
      let(:property_options) { super().merge(type: :boolean) }
      let(:error_message)    { 'must be true or false' }

      include_examples 'should define the property'

      it { expect(property.error_message).to be == error_message }

      it { expect(property.predicate?).to be true }

      it { expect(property.type).to be_a Proc }

      describe 'with error_message: value' do
        let(:error_message)    { 'must be pointed toward space' }
        let(:property_options) { super().merge(error_message: error_message) }

        it { expect(property.error_message).to be == error_message }
      end

      describe 'with predicate: false' do
        let(:property_options) { super().merge(predicate: false) }

        it { expect(property.predicate?).to be false }
      end

      describe 'with predicate: true' do
        let(:property_options) { super().merge(predicate: true) }

        it { expect(property.predicate?).to be true }
      end
    end
  end

  describe '#initialize' do
    include_context 'when included in a class'

    pending
  end

  describe '#properties' do
    include_context 'when included in a class'

    pending
  end

  describe '#:property_name' do
    include_context 'when included in a class'

    pending
  end

  describe '#:property_name?' do
    include_context 'when included in a class'

    pending
  end

  describe '#:property_name=' do
    include_context 'when included in a class'

    pending
  end
end
