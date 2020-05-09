# frozen_string_literal: true

require 'spec_helper'

require 'sleeping_king_studios/tools/toolbox/mixin'

RSpec.describe SleepingKingStudios::Tools::Toolbox::Mixin do
  extend RSpec::SleepingKingStudios::Concerns::ExampleConstants

  shared_context 'when the mixin includes another mixin' do
    example_constant 'Spec::SecondMixin' do
      Module.new do
        extend  SleepingKingStudios::Tools::Toolbox::Mixin
        include Spec::FirstMixin

        self::ClassMethods.define_method(:second_class_method) { :ni }

        define_method(:second_instance_method) { :ni }
      end
    end

    let(:described_class) do
      Class.new.tap { |klass| klass.include Spec::SecondMixin }
    end
  end

  shared_context 'when the mixin overrides another mixin' do
    example_constant 'Spec::ThirdMixin' do
      Module.new do
        extend  SleepingKingStudios::Tools::Toolbox::Mixin
        include Spec::FirstMixin

        self::ClassMethods.define_method(:first_class_method) do
          [super(), :san]
        end

        define_method(:first_instance_method) { [super(), :san] }
      end
    end

    let(:described_class) do
      Class.new.tap { |klass| klass.include Spec::ThirdMixin }
    end
  end

  let(:described_class) do
    Class.new.tap { |klass| klass.include Spec::FirstMixin }
  end
  let(:instance) { described_class.new }

  example_constant 'Spec::FirstMixin' do
    Module.new do
      extend SleepingKingStudios::Tools::Toolbox::Mixin

      def first_instance_method
        :ichi
      end
    end
  end

  example_constant 'Spec::FirstMixin::ClassMethods' do
    Module.new do
      def first_class_method
        :ichi
      end
    end
  end

  describe 'should inherit class methods' do
    describe '::first_class_method' do
      it { expect(described_class).to respond_to(:first_class_method) }

      it { expect(described_class.first_class_method).to be :ichi }

      context 'when the mixin includes another mixin' do
        include_context 'when the mixin includes another mixin'

        it { expect(described_class).to respond_to(:first_class_method) }

        it { expect(described_class.first_class_method).to be :ichi }
      end

      context 'when the mixin overrides another mixin' do
        include_context 'when the mixin overrides another mixin'

        it { expect(described_class).to respond_to(:first_class_method) }

        it { expect(described_class.first_class_method).to be == %i[ichi san] }
      end
    end

    describe '::second_class_method' do
      it { expect(described_class).not_to respond_to(:second_class_method) }

      wrap_context 'when the mixin includes another mixin' do
        it { expect(described_class).to respond_to(:second_class_method) }

        it { expect(described_class.second_class_method).to be :ni }
      end
    end
  end

  describe 'should inherit instance methods' do
    describe '#first_instance_method' do
      it { expect(instance).to respond_to(:first_instance_method) }

      it { expect(instance.first_instance_method).to be :ichi }

      context 'when the mixin includes another mixin' do
        include_context 'when the mixin includes another mixin'

        it { expect(instance).to respond_to(:first_instance_method) }

        it { expect(instance.first_instance_method).to be :ichi }
      end

      context 'when the mixin overrides another mixin' do
        include_context 'when the mixin overrides another mixin'

        it { expect(instance).to respond_to(:first_instance_method) }

        it { expect(instance.first_instance_method).to be == %i[ichi san] }
      end
    end

    describe '#second_instance_method' do
      it { expect(instance).not_to respond_to(:second_instance_method) }

      wrap_context 'when the mixin includes another mixin' do
        it { expect(instance).to respond_to(:second_instance_method) }

        it { expect(instance.second_instance_method).to be :ni }
      end
    end
  end
end
