# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/heritable_data'

RSpec.describe SleepingKingStudios::Tools::Toolbox::HeritableData do
  subject(:data) { described_class.new(**attributes) }

  deferred_context 'with an inherited data class' do
    let(:described_class) { Spec::UserEvent }
    let(:attributes) do
      super().merge(user: Spec::User.new(name: 'Alan Bradley', role: 'user'))
    end

    example_constant 'Spec::User', Data.define(:name, :role)

    example_constant 'Spec::UserEvent' do
      Spec::Event.define(:user) do
        def admin? = user.role == 'admin'
      end
    end
  end

  let(:concern)         { SleepingKingStudios::Tools::Toolbox::HeritableData } # rubocop:disable RSpec/DescribedClass
  let(:described_class) { Spec::Event }
  let(:attributes)      { { type: 'spec.event' } }

  example_constant 'Spec::Event' do
    SleepingKingStudios::Tools::Toolbox::HeritableData.define(:type) do # rubocop:disable RSpec/DescribedClass
      def event_type = type
    end
  end

  describe '::HeritableMethods' do
    it { expect(described_class).to define_constant(:HeritableMethods) }
  end

  describe 'singleton_class.define' do
    let(:symbols)    { [] }
    let(:methods)    { nil }
    let(:options)    { {} }
    let(:subclass)   { concern.define(*symbols, **options, &methods) }
    let(:attributes) { {} }
    let(:instance)   { subclass.new(**attributes) }

    it 'should define the class method' do
      expect(concern)
        .to respond_to(:define)
        .with_unlimited_arguments
        .and_keywords(:parent_class)
        .and_a_block
    end

    it { expect(subclass).to be_a(Class) }

    it { expect(subclass.superclass).to be Data }

    it { expect(subclass).to be < concern }

    it { expect(subclass.members).to be == [] }

    describe 'with a block' do
      let(:methods) do
        lambda do
          def greet = 'Greetings, programs!'
        end
      end

      it { expect(instance).to respond_to(:greet).with(0).arguments }

      it { expect(instance.greet).to be == 'Greetings, programs!' }
    end

    describe 'with symbols' do
      let(:symbols) { %i[details] }

      it { expect(subclass.members).to be == %i[details] }
    end

    describe 'with parent_class: value' do
      let(:parent_class) { Spec::Event }
      let(:options)      { { parent_class: } }
      let(:attributes)   { super().merge(type: 'spec.event') }

      it { expect(subclass).to be_a(Class) }

      it { expect(subclass.superclass).to be Data }

      it { expect(subclass).to be < concern }

      it { expect(subclass.members).to be == %i[type] }

      it { expect(instance.event_type).to be == 'spec.event' }

      describe 'with a block' do
        let(:methods) do
          lambda do
            def greet = 'Greetings, programs!'
          end
        end

        it { expect(instance).to respond_to(:greet).with(0).arguments }

        it { expect(instance.greet).to be == 'Greetings, programs!' }
      end

      describe 'with symbols' do
        let(:symbols) { %i[details] }

        it { expect(subclass.members).to be == %i[type details] }
      end
    end
  end

  describe '.<' do
    describe 'with nil' do
      it { expect(described_class < nil).to be nil }
    end

    describe 'with an Object' do
      it { expect(described_class < Object.new.freeze).to be nil }
    end

    describe 'with an instance of the class' do
      it { expect(described_class < data).to be nil }
    end

    describe 'with Data' do
      it { expect(described_class < Data).to be true }
    end

    describe 'with the class' do
      it { expect(described_class < described_class).to be false } # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    end

    describe 'with a subclass' do
      example_constant 'Spec::DetailsEvent' do
        described_class.define(:details)
      end

      it { expect(described_class < Spec::DetailsEvent).to be false }
    end

    wrap_deferred 'with an inherited data class' do
      describe 'with Data' do
        it { expect(described_class < Data).to be true }
      end

      describe 'with a parent class' do
        it { expect(described_class < Spec::Event).to be true }
      end

      describe 'with the class' do
        it { expect(described_class < described_class).to be false } # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      end

      describe 'with a subclass' do
        example_constant 'Spec::DetailsEvent' do
          described_class.define(:details)
        end

        it { expect(described_class < Spec::DetailsEvent).to be false }
      end
    end
  end

  describe '.<=' do
    describe 'with nil' do
      it { expect(described_class <= nil).to be nil }
    end

    describe 'with an Object' do
      it { expect(described_class <= Object.new.freeze).to be nil }
    end

    describe 'with an instance of the class' do
      it { expect(described_class <= data).to be nil }
    end

    describe 'with Data' do
      it { expect(described_class <= Data).to be true }
    end

    describe 'with the class' do
      it { expect(described_class <= described_class).to be true } # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    end

    describe 'with a subclass' do
      example_constant 'Spec::DetailsEvent' do
        described_class.define(:details)
      end

      it { expect(described_class <= Spec::DetailsEvent).to be false }
    end

    wrap_deferred 'with an inherited data class' do
      describe 'with Data' do
        it { expect(described_class <= Data).to be true }
      end

      describe 'with a parent class' do
        it { expect(described_class <= Spec::Event).to be true }
      end

      describe 'with the class' do
        it { expect(described_class <= described_class).to be true } # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      end

      describe 'with a subclass' do
        example_constant 'Spec::DetailsEvent' do
          described_class.define(:details)
        end

        it { expect(described_class <= Spec::DetailsEvent).to be false }
      end
    end
  end

  describe '.<=>' do
    describe 'with nil' do
      it { expect(described_class <=> nil).to be nil }
    end

    describe 'with an Object' do
      it { expect(described_class <=> Object.new.freeze).to be nil }
    end

    describe 'with an instance of the class' do
      it { expect(described_class <=> data).to be nil }
    end

    describe 'with Data' do
      it { expect(described_class <=> Data).to be(-1) }
    end

    describe 'with the class' do
      it { expect(described_class <=> described_class).to be 0 } # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    end

    describe 'with a subclass' do
      example_constant 'Spec::DetailsEvent' do
        described_class.define(:details)
      end

      it { expect(described_class <=> Spec::DetailsEvent).to be 1 }
    end

    wrap_deferred 'with an inherited data class' do
      describe 'with Data' do
        it { expect(described_class <=> Data).to be(-1) }
      end

      describe 'with a parent class' do
        it { expect(described_class <=> Spec::Event).to be(-1) }
      end

      describe 'with the class' do
        it { expect(described_class <=> described_class).to be 0 } # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      end

      describe 'with a subclass' do
        example_constant 'Spec::DetailsEvent' do
          described_class.define(:details)
        end

        it { expect(described_class <=> Spec::DetailsEvent).to be 1 }
      end
    end
  end

  # rubocop:disable Style/CaseEquality
  describe '.===' do
    describe 'with nil' do
      it { expect(described_class === nil).to be false } # rubocop:disable Style/NilComparison
    end

    describe 'with an Object' do
      it { expect(described_class === Object.new.freeze).to be false }
    end

    describe 'with the class' do
      it { expect(described_class === described_class).to be false } # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    end

    describe 'with a Data instance' do
      it { expect(described_class === Data.define.new).to be false }
    end

    describe 'with an instance of the class' do
      it { expect(described_class === data).to be true }
    end

    describe 'with a subclass' do
      let(:attributes) { super().merge(details: 'Not important.') }
      let(:instance)   { Spec::DetailsEvent.new(**attributes) }

      example_constant 'Spec::DetailsEvent' do
        described_class.define(:details)
      end

      it { expect(described_class === instance).to be true }
    end

    wrap_deferred 'with an inherited data class' do
      describe 'with an instance of the parent class' do
        let(:instance) { Spec::Event.new(type: attributes[:type]) }

        it { expect(described_class === instance).to be false }
      end

      describe 'with a Data instance' do
        it { expect(described_class === Data.define.new).to be false }
      end

      describe 'with an instance of the class' do
        it { expect(described_class === data).to be true }
      end

      describe 'with a subclass' do
        let(:attributes) { super().merge(details: 'Not important.') }
        let(:instance)   { Spec::DetailsEvent.new(**attributes) }

        example_constant 'Spec::DetailsEvent' do
          described_class.define(:details)
        end

        it { expect(described_class === instance).to be true }
      end
    end
  end
  # rubocop:enable Style/CaseEquality

  describe '.>' do
    describe 'with nil' do
      it { expect(described_class > nil).to be nil }
    end

    describe 'with an Object' do
      it { expect(described_class > Object.new.freeze).to be nil }
    end

    describe 'with an instance of the class' do
      it { expect(described_class > data).to be nil }
    end

    describe 'with Data' do
      it { expect(described_class > Data).to be false }
    end

    describe 'with the class' do
      it { expect(described_class > described_class).to be false } # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    end

    describe 'with a subclass' do
      example_constant 'Spec::DetailsEvent' do
        described_class.define(:details)
      end

      it { expect(described_class > Spec::DetailsEvent).to be true }
    end

    wrap_deferred 'with an inherited data class' do
      describe 'with Data' do
        it { expect(described_class > Data).to be false }
      end

      describe 'with a parent class' do
        it { expect(described_class > Spec::Event).to be false }
      end

      describe 'with the class' do
        it { expect(described_class > described_class).to be false } # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      end

      describe 'with a subclass' do
        example_constant 'Spec::DetailsEvent' do
          described_class.define(:details)
        end

        it { expect(described_class > Spec::DetailsEvent).to be true }
      end
    end
  end

  describe '.>=' do
    describe 'with nil' do
      it { expect(described_class >= nil).to be nil }
    end

    describe 'with an Object' do
      it { expect(described_class >= Object.new.freeze).to be nil }
    end

    describe 'with an instance of the class' do
      it { expect(described_class >= data).to be nil }
    end

    describe 'with Data' do
      it { expect(described_class >= Data).to be false }
    end

    describe 'with the class' do
      it { expect(described_class >= described_class).to be true } # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
    end

    describe 'with a subclass' do
      example_constant 'Spec::DetailsEvent' do
        described_class.define(:details)
      end

      it { expect(described_class >= Spec::DetailsEvent).to be true }
    end

    wrap_deferred 'with an inherited data class' do
      describe 'with Data' do
        it { expect(described_class >= Data).to be false }
      end

      describe 'with a parent class' do
        it { expect(described_class >= Spec::Event).to be false }
      end

      describe 'with the class' do
        it { expect(described_class >= described_class).to be true } # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
      end

      describe 'with a subclass' do
        example_constant 'Spec::DetailsEvent' do
          described_class.define(:details)
        end

        it { expect(described_class >= Spec::DetailsEvent).to be true }
      end
    end
  end

  describe '.define' do
    let(:symbols)  { [] }
    let(:methods)  { nil }
    let(:subclass) { described_class.define(*symbols, &methods) }
    let(:instance) { subclass.new(**attributes) }

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:define)
        .with_unlimited_arguments
        .and_a_block
    end

    it { expect(subclass).to be_a(Class) }

    it { expect(subclass.superclass).to be Data }

    it { expect(subclass).to be < concern }

    it { expect(subclass.members).to be == %i[type] }

    it { expect(instance.event_type).to be == 'spec.event' }

    describe 'with a block' do
      let(:methods) do
        lambda do
          def loud_type = type.upcase
        end
      end

      it { expect(instance).to respond_to(:loud_type).with(0).arguments }

      it { expect(instance.loud_type).to be == 'SPEC.EVENT' }
    end

    describe 'with symbols' do
      let(:symbols) { %i[details] }

      it { expect(subclass.members).to be == %i[type details] }
    end

    wrap_deferred 'with an inherited data class' do
      it { expect(subclass).to be_a(Class) }

      it { expect(subclass.superclass).to be Data }

      it { expect(subclass).to be < concern }

      it { expect(subclass.members).to be == %i[type user] }

      it { expect(instance).to respond_to(:admin?).with(0).arguments }

      it { expect(instance.admin?).to be false }

      it { expect(instance.event_type).to be == 'spec.event' }

      describe 'with a block' do
        let(:methods) do
          lambda do
            def loud_type = type.upcase
          end
        end

        it { expect(instance).to respond_to(:loud_type).with(0).arguments }

        it { expect(instance.loud_type).to be == 'SPEC.EVENT' }
      end

      describe 'with symbols' do
        let(:symbols) { %i[details] }

        it { expect(subclass.members).to be == %i[type user details] }
      end
    end
  end

  describe '#is_a?' do
    it { expect(data).to have_aliased_method(:is_a?).as(:kind_of?) }

    describe 'with nil' do
      let(:error_message) do
        'class or module required'
      end

      it 'should raise an exception' do
        expect { data.is_a?(nil) }.to raise_error TypeError, error_message
      end
    end

    describe 'with an Object' do
      let(:error_message) do
        'class or module required'
      end

      it 'should raise an exception' do
        expect { data.is_a?(Object.new.freeze) }
          .to raise_error TypeError, error_message
      end
    end

    describe 'with BasicObject' do
      it { expect(data.is_a?(BasicObject)).to be true }
    end

    describe 'with Object' do
      it { expect(data.is_a?(Object)).to be true }
    end

    describe 'with Data' do
      it { expect(data.is_a?(Data)).to be true }
    end

    describe 'with another Data class' do
      it { expect(data.is_a?(Data.define)).to be false }
    end

    describe 'with the class' do
      it { expect(data.is_a?(described_class)).to be true }
    end

    describe 'with a subclass' do
      example_constant 'Spec::DetailsEvent' do
        described_class.define(:details)
      end

      it { expect(data.is_a?(Spec::DetailsEvent)).to be false }
    end

    wrap_deferred 'with an inherited data class' do
      describe 'with Data' do
        it { expect(data.is_a?(Data)).to be true }
      end

      describe 'with another Data class' do
        it { expect(data.is_a?(Data.define)).to be false }
      end

      describe 'with the parent class' do
        it { expect(data.is_a?(Spec::Event)).to be true }
      end

      describe 'with the class' do
        it { expect(data.is_a?(described_class)).to be true }
      end

      describe 'with a subclass' do
        example_constant 'Spec::DetailsEvent' do
          described_class.define(:details)
        end

        it { expect(data.is_a?(Spec::DetailsEvent)).to be false }
      end
    end
  end
end
