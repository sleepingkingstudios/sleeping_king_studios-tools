# spec/sleeping_king_studios/tools/toolbox/mixin_spec.rb

require 'spec_helper'

require 'sleeping_king_studios/tools/toolbox/mixin'

RSpec.describe SleepingKingStudios::Tools::Toolbox::Mixin do
  shared_context 'when the mixin includes another mixin' do
    around(:example) do |example|
      begin
        module Spec
          module SecondMixin
            extend SleepingKingStudios::Tools::Toolbox::Mixin

            include Spec::FirstMixin

            module ClassMethods
              def second_class_method; :ni; end
            end # module

            def second_instance_method; :ni; end
          end # module
        end # module

        example.call
      ensure
        Spec.send :remove_const, :SecondMixin
      end # begin-ensure
    end # around

    let(:described_class) do
      Class.new.tap { |klass| klass.include Spec::SecondMixin }
    end # let
  end # shared_context

  shared_context 'when the mixin overrides another mixin' do
    around(:example) do |example|
      begin
        module Spec
          module ThirdMixin
            extend SleepingKingStudios::Tools::Toolbox::Mixin

            include Spec::FirstMixin

            module ClassMethods
              def first_class_method; [super, :san]; end
            end # module

            def first_instance_method; [super, :san]; end
          end # module
        end # module

        example.call
      ensure
        Spec.send :remove_const, :ThirdMixin
      end # begin-ensure
    end # around

    let(:described_class) do
      Class.new.tap { |klass| klass.include Spec::ThirdMixin }
    end # let
  end # shared_context

  let(:described_class) do
    Class.new.tap { |klass| klass.include Spec::FirstMixin }
  end # let
  let(:instance) { described_class.new }

  around(:example) do |example|
    begin
      module Spec
        module FirstMixin
          extend SleepingKingStudios::Tools::Toolbox::Mixin

          module ClassMethods
            def first_class_method; :ichi; end
          end # module

          def first_instance_method; :ichi; end
        end # module
      end # module

      example.call
    ensure
      Spec.send :remove_const, :FirstMixin
    end # begin-ensure
  end # around

  describe 'should inherit class methods' do
    describe '::first_class_method' do
      it { expect(described_class).to respond_to(:first_class_method) }

      it { expect(described_class.first_class_method).to be :ichi }

      wrap_context 'when the mixin includes another mixin' do
        it { expect(described_class).to respond_to(:first_class_method) }

        it { expect(described_class.first_class_method).to be :ichi }
      end # wrap_context

      wrap_context 'when the mixin overrides another mixin' do
        it { expect(described_class).to respond_to(:first_class_method) }

        it { expect(described_class.first_class_method).to be == [:ichi, :san] }
      end # wrap_context
    end # describe

    describe '::second_class_method' do
      it { expect(described_class).not_to respond_to(:second_class_method) }

      wrap_context 'when the mixin includes another mixin' do
        it { expect(described_class).to respond_to(:second_class_method) }

        it { expect(described_class.second_class_method).to be :ni }
      end # wrap_context
    end # describe
  end # describe

  describe 'should inherit instance methods' do
    describe '#first_instance_method' do
      it { expect(instance).to respond_to(:first_instance_method) }

      it { expect(instance.first_instance_method).to be :ichi }

      wrap_context 'when the mixin includes another mixin' do
        it { expect(instance).to respond_to(:first_instance_method) }

        it { expect(instance.first_instance_method).to be :ichi }
      end # wrap_context

      wrap_context 'when the mixin overrides another mixin' do
        it { expect(instance).to respond_to(:first_instance_method) }

        it { expect(instance.first_instance_method).to be == [:ichi, :san] }
      end # wrap_context
    end # describe

    describe '#second_instance_method' do
      it { expect(instance).not_to respond_to(:second_instance_method) }

      wrap_context 'when the mixin includes another mixin' do
        it { expect(instance).to respond_to(:second_instance_method) }

        it { expect(instance.second_instance_method).to be :ni }
      end # wrap_context
    end # describe
  end # describe
end # describe
