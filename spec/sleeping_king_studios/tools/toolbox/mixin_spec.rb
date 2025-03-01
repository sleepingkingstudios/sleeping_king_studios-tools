# frozen_string_literal: true

require 'spec_helper'

require 'sleeping_king_studios/tools/toolbox/mixin'

RSpec.describe SleepingKingStudios::Tools::Toolbox::Mixin do
  extend RSpec::SleepingKingStudios::Concerns::ExampleConstants

  subject(:instance) { described_class.new }

  shared_context 'when the mixin includes another mixin' do
    example_constant 'Spec::IncludedMixin' do
      Module.new do
        extend SleepingKingStudios::Tools::Toolbox::Mixin

        const_set(
          :ClassMethods,
          Module.new do
            define_method :included_class_method do
              { receiver: 'Spec::IncludedMixin' }
            end
          end
        )

        define_method :included_instance_method do
          { receiver: 'Spec::IncludedMixin' }
        end
      end
    end

    before(:example) do
      Spec::ExampleMixin.include(Spec::IncludedMixin)
    end
  end

  let(:mixin_module)    { SleepingKingStudios::Tools::Toolbox::Mixin } # rubocop:disable RSpec/DescribedClass
  let(:described_class) { Spec::BaseClass }

  example_constant 'Spec::FirstMixin' do
    Module.new do
      extend SleepingKingStudios::Tools::Toolbox::Mixin

      const_set(
        :ClassMethods,
        Module.new do
          define_method :first_class_method do
            :ichi
          end
        end
      )

      define_method :first_instance_method do
        :ichi
      end
    end
  end

  example_class 'Spec::BaseClass' do |klass|
    klass.define_singleton_method :example_class_method do
      (defined?(super()) ? super() : []) << 'Spec::BaseClass'
    end

    klass.define_method :example_instance_method do
      (defined?(super()) ? super() : []) << 'Spec::BaseClass'
    end
  end

  example_constant 'Spec::ExampleMixin' do
    Module.new do
      extend SleepingKingStudios::Tools::Toolbox::Mixin

      const_set(
        :ClassMethods,
        Module.new do
          define_method :example_class_method do
            (defined?(super()) ? super() : []) << 'Spec::ExampleMixin'
          end
        end
      )

      define_method :example_instance_method do
        (defined?(super()) ? super() : []) << 'Spec::ExampleMixin'
      end
    end
  end

  example_constant 'Spec::AdditionalMixin' do
    Module.new do
      extend SleepingKingStudios::Tools::Toolbox::Mixin

      const_set(
        :ClassMethods,
        Module.new do
          define_method :example_class_method do
            (defined?(super()) ? super() : []) << 'Spec::AdditionalMixin'
          end
        end
      )

      define_method :example_instance_method do
        (defined?(super()) ? super() : []) << 'Spec::AdditionalMixin'
      end
    end
  end

  describe '.included' do
    before(:example) { Spec::BaseClass.include(Spec::ExampleMixin) }

    it 'should add the class methods to the singleton class' do
      expect(described_class.singleton_class)
        .to be < Spec::ExampleMixin::ClassMethods
    end

    describe '.example_class_method' do
      let(:expected) { %w[Spec::ExampleMixin Spec::BaseClass] }

      it { expect(described_class.example_class_method).to be == expected }

      context 'when the class includes multiple mixins' do
        let(:expected) do
          %w[Spec::ExampleMixin Spec::AdditionalMixin Spec::BaseClass]
        end

        before(:example) { Spec::BaseClass.include(Spec::AdditionalMixin) }

        it { expect(described_class.example_class_method).to be == expected }
      end

      context 'when the mixin includes other mixins' do
        let(:expected) do
          %w[Spec::AdditionalMixin Spec::ExampleMixin Spec::BaseClass]
        end

        before(:example) { Spec::ExampleMixin.include(Spec::AdditionalMixin) }

        it { expect(described_class.example_class_method).to be == expected }
      end

      context 'when the mixin prepends other mixins' do
        let(:expected) do
          %w[Spec::ExampleMixin Spec::AdditionalMixin Spec::BaseClass]
        end

        before(:example) { Spec::ExampleMixin.prepend(Spec::AdditionalMixin) }

        it { expect(described_class.example_class_method).to be == expected }
      end
    end

    describe '#example_instance_method' do
      let(:expected) { %w[Spec::ExampleMixin Spec::BaseClass] }

      it { expect(instance.example_instance_method).to be == expected }

      context 'when the class includes multiple mixins' do
        let(:expected) do
          %w[Spec::ExampleMixin Spec::AdditionalMixin Spec::BaseClass]
        end

        before(:example) { Spec::BaseClass.include(Spec::AdditionalMixin) }

        it { expect(instance.example_instance_method).to be == expected }
      end

      context 'when the mixin includes other mixins' do
        let(:expected) do
          %w[Spec::AdditionalMixin Spec::ExampleMixin Spec::BaseClass]
        end

        before(:example) { Spec::ExampleMixin.include(Spec::AdditionalMixin) }

        it { expect(instance.example_instance_method).to be == expected }
      end

      context 'when the mixin prepends other mixins' do
        let(:expected) do
          %w[Spec::ExampleMixin Spec::AdditionalMixin Spec::BaseClass]
        end

        before(:example) { Spec::ExampleMixin.prepend(Spec::AdditionalMixin) }

        it { expect(instance.example_instance_method).to be == expected }
      end
    end
  end

  describe '.mixin?' do
    it { expect(mixin_module).to respond_to(:mixin?).with(1).argument }

    describe 'with nil' do
      it { expect(mixin_module.mixin? nil).to be false }
    end

    describe 'with an Object' do
      it { expect(mixin_module.mixin? Object.new.freeze).to be false }
    end

    describe 'with a Class' do
      it { expect(mixin_module.mixin? Class.new).to be false }
    end

    describe 'with a Class that includes a mixin' do
      let(:actual) { Class.new.extend(Spec::ExampleMixin) }

      it { expect(mixin_module.mixin? actual).to be false }
    end

    describe 'with a Module' do
      it { expect(mixin_module.mixin? Module.new).to be false }
    end

    describe 'with a Module that extends the mixin concern' do
      let(:actual) { Module.new.extend(mixin_module) }

      it { expect(mixin_module.mixin? actual).to be true }
    end

    describe 'with a Module that includes a mixin' do
      let(:actual) { Module.new.extend(Spec::ExampleMixin) }

      it { expect(mixin_module.mixin? actual).to be false }
    end
  end

  describe '.prepended' do
    before(:example) { Spec::BaseClass.prepend(Spec::ExampleMixin) }

    it 'should add the class methods to the singleton class' do
      expect(described_class.singleton_class)
        .to be < Spec::ExampleMixin::ClassMethods
    end

    describe '.example_class_method' do
      let(:expected) { %w[Spec::BaseClass Spec::ExampleMixin] }

      it { expect(described_class.example_class_method).to be == expected }

      context 'when the class includes multiple mixins' do
        let(:expected) do
          %w[Spec::BaseClass Spec::ExampleMixin Spec::AdditionalMixin]
        end

        before(:example) { Spec::BaseClass.prepend(Spec::AdditionalMixin) }

        it { expect(described_class.example_class_method).to be == expected }
      end

      context 'when the mixin includes other mixins' do
        let(:expected) do
          %w[Spec::BaseClass Spec::AdditionalMixin Spec::ExampleMixin]
        end

        before(:example) { Spec::ExampleMixin.include(Spec::AdditionalMixin) }

        it { expect(described_class.example_class_method).to be == expected }
      end

      context 'when the mixin prepends other mixins' do
        let(:expected) do
          %w[Spec::BaseClass Spec::ExampleMixin Spec::AdditionalMixin]
        end

        before(:example) { Spec::ExampleMixin.prepend(Spec::AdditionalMixin) }

        it { expect(described_class.example_class_method).to be == expected }
      end
    end

    describe '#example_instance_method' do
      let(:expected) { %w[Spec::BaseClass Spec::ExampleMixin] }

      it { expect(instance.example_instance_method).to be == expected }

      context 'when the class includes multiple mixins' do
        let(:expected) do
          %w[Spec::BaseClass Spec::ExampleMixin Spec::AdditionalMixin]
        end

        before(:example) { Spec::BaseClass.prepend(Spec::AdditionalMixin) }

        it { expect(instance.example_instance_method).to be == expected }
      end

      context 'when the mixin includes other mixins' do
        let(:expected) do
          %w[Spec::BaseClass Spec::AdditionalMixin Spec::ExampleMixin]
        end

        before(:example) { Spec::ExampleMixin.include(Spec::AdditionalMixin) }

        it { expect(instance.example_instance_method).to be == expected }
      end

      context 'when the mixin prepends other mixins' do
        let(:expected) do
          %w[Spec::BaseClass Spec::ExampleMixin Spec::AdditionalMixin]
        end

        before(:example) { Spec::ExampleMixin.prepend(Spec::AdditionalMixin) }

        it { expect(instance.example_instance_method).to be == expected }
      end
    end
  end
end
