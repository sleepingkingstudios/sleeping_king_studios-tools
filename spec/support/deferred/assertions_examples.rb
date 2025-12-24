# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'support/deferred'

module Spec::Support::Deferred
  module AssertionsExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should define the assertion methods' \
    do |**deferred_options|
      prefix = deferred_options.fetch(:prefix, 'assert') # rubocop:disable RSpec/LeakyLocalVariable

      define_method :default_keywords do
        return %i[message] if deferred_options.key?(:error_class)

        %i[message error_class]
      end

      describe "##{prefix}" do
        let(:error_key) { 'block' }

        define_method :assert do
          subject.public_send(prefix, **options, &block)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(prefix.to_sym)
            .with(0).arguments
            .and_keywords(*default_keywords)
            .and_a_block
        end

        describe 'with a block that returns a falsy value' do
          let(:block) { -> {} }

          include_deferred 'should fail the assertion',
            skip_as: true,
            **deferred_options
        end

        describe 'with a block that returns a truthy value' do
          let(:block) { -> { :ok } }

          include_deferred 'should pass the assertion'
        end
      end

      describe "##{prefix}_blank" do
        let(:error_key) { 'blank' }

        define_method :assert do
          subject.public_send("#{prefix}_blank", value, **options)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:"#{prefix}_blank")
            .with(1).argument
            .and_keywords(*default_keywords, :as)
        end

        describe 'with nil' do
          let(:value) { nil }

          include_deferred 'should pass the assertion'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with an empty value' do
          let(:value) { Struct.new(:empty) { def empty? = empty }.new(true) }

          include_deferred 'should pass the assertion'
        end

        describe 'with a non-empty value' do
          let(:value) { Struct.new(:empty) { def empty? = empty }.new(false) }

          include_deferred 'should fail the assertion', **deferred_options
        end
      end

      describe "##{prefix}_boolean" do
        let(:error_key) { 'boolean' }

        define_method :assert do
          subject.public_send(:"#{prefix}_boolean", value, **options)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:"#{prefix}_boolean")
            .with(1).argument
            .and_keywords(*default_keywords, :as, :optional)
        end

        describe 'with nil' do
          let(:value) { nil }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with false' do
          let(:value) { false }

          include_deferred 'should pass the assertion'
        end

        describe 'with true' do
          let(:value) { true }

          include_deferred 'should pass the assertion'
        end

        describe 'with optional: false' do
          let(:options) { super().merge(optional: false) }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should fail the assertion', **deferred_options
          end
        end

        describe 'with optional: true' do
          let(:options) { super().merge(optional: true) }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should pass the assertion'
          end
        end
      end

      describe "##{prefix}_class" do
        let(:error_key) { 'class' }

        define_method :assert do
          subject.public_send(:"#{prefix}_class", value, **options)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:assert_class)
            .with(1).argument
            .and_keywords(*default_keywords, :as, :optional)
        end

        describe 'with nil' do
          let(:value) { nil }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with a Module' do
          let(:value) { Module.new }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with a Class' do
          let(:value) { Class.new }

          include_deferred 'should pass the assertion'
        end

        describe 'with optional: false' do
          let(:options) { super().merge(optional: false) }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should fail the assertion', **deferred_options
          end
        end

        describe 'with optional: true' do
          let(:options) { super().merge(optional: true) }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should pass the assertion'
          end
        end
      end

      describe "##{prefix}_group" do
        let(:block) { ->(_) {} }

        define_method :assert do
          subject.public_send(:"#{prefix}_group", **options, &block)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:"#{prefix}_group")
            .with(0).arguments
            .and_keywords(*default_keywords)
            .and_a_block
        end

        it 'should alias the method' do
          expect(subject).to have_aliased_method(:assert_group).as(:aggregate)
        end

        describe 'without a block' do
          let(:error_message) { 'no block given' }

          it 'should raise an exception' do
            expect { subject.public_send(:"#{prefix}_group") }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a block that raises an exception' do
          let(:block)         { ->(*) { raise error_message } }
          let(:error_message) { 'something went wrong' }

          it 'should raise an exception' do
            expect { assert }.to raise_error RuntimeError, error_message
          end
        end

        describe 'with a block with no assertions' do
          let(:block) { ->(_) {} }

          include_deferred 'should pass the assertion'
        end

        describe 'with a block with a failing assertion' do
          let(:value)            { Object.new.freeze }
          let(:expected_message) { 'value is not a String or a Symbol' }
          let(:block) do
            lambda do |aggregator|
              aggregator.assert_name(value)
            end
          end

          include_deferred 'should fail the assertion',
            skip_as: true,
            **deferred_options
        end

        describe 'with a block with a passing assertion' do
          let(:value) { 'ok' }
          let(:block) do
            lambda do |aggregator|
              aggregator.assert_name(value)
            end
          end

          include_deferred 'should pass the assertion'
        end

        describe 'with a block with many failing assertions' do
          let(:label) { nil }
          let(:value) { Object.new.freeze }
          let(:expected_message) do
            'value is not a String or a Symbol, label is not an instance of ' \
              'String, something went wrong'
          end
          let(:block) do
            lambda do |aggregator|
              aggregator.assert_name(value)
              aggregator.assert_instance_of(
                label,
                expected: String,
                as:       'label'
              )
              aggregator.validate(message: 'something went wrong') { false }
            end
          end

          include_deferred 'should fail the assertion',
            skip_as: true,
            **deferred_options
        end

        describe 'with a block with many passing assertions' do
          let(:label) { 'self-sealing stem bolts' }
          let(:value) { 'Quantity: 1,000' }
          let(:block) do
            lambda do |aggregator|
              aggregator.assert_name(value)
              aggregator.assert_instance_of(
                label,
                expected: String,
                as:       'label'
              )
              aggregator.validate(message: 'something went wrong') { true }
            end
          end

          include_deferred 'should pass the assertion'
        end

        describe 'with a block with nested aggregations' do
          let(:quantity) { nil }
          let(:label)    { nil }
          let(:expected_message) do
            "label is not an instance of String, label can't be blank, " \
              'quantity is not an instance of Integer'
          end
          let(:block) do
            lambda do |aggregator|
              aggregator.assert_group do |inner|
                inner.assert_instance_of(label, expected: String, as: 'label')
                inner.assert_presence(label, as: 'label')
              end

              aggregator
                .assert_instance_of(quantity, expected: Integer, as: 'quantity')
            end
          end

          include_deferred 'should fail the assertion',
            skip_as: true,
            **deferred_options
        end

        describe 'with a block with nested aggregations and message: value' do
          let(:quantity) { nil }
          let(:label)    { nil }
          let(:expected_message) do
            'label is invalid, quantity is not an instance of Integer'
          end
          let(:block) do
            lambda do |aggregator|
              aggregator.assert_group(message: 'label is invalid') do |inner|
                inner.assert_instance_of(label, expected: String, as: 'label')
                inner.assert_presence(label, as: 'label')
              end

              aggregator
                .assert_instance_of(quantity, expected: Integer, as: 'quantity')
            end
          end

          include_deferred 'should fail the assertion',
            skip_as: true,
            **deferred_options
        end

        describe 'with message: value' do
          let(:message) { 'something went wrong' }
          let(:options) { super().merge(message:) }

          describe 'with a block with no assertions' do
            let(:block) { ->(_) {} }

            include_deferred 'should pass the assertion'
          end

          describe 'with a block with a failing assertion' do
            let(:value) { Object.new.freeze }
            let(:block) do
              lambda do |aggregator|
                aggregator.assert_name(value)
              end
            end
            let(:expected_message) { message }

            include_deferred 'should fail the assertion',
              skip_as: true,
              **deferred_options
          end

          describe 'with a block with a passing assertion' do
            let(:value) { 'ok' }
            let(:block) do
              lambda do |aggregator|
                aggregator.assert_name(value)
              end
            end

            include_deferred 'should pass the assertion'
          end

          describe 'with a block with many failing assertions' do
            let(:label) { nil }
            let(:value) { Object.new.freeze }
            let(:block) do
              lambda do |aggregator|
                aggregator.assert_name(value)
                aggregator.assert_instance_of(
                  label,
                  expected: String,
                  as:       'label'
                )
                aggregator.validate(message: 'something went wrong') { false }
              end
            end
            let(:expected_message) { message }

            include_deferred 'should fail the assertion',
              skip_as: true,
              **deferred_options
          end

          describe 'with a block with many passing assertions' do
            let(:label) { 'self-sealing stem bolts' }
            let(:value) { 'Quantity: 1,000' }
            let(:block) do
              lambda do |aggregator|
                aggregator.assert_name(value)
                aggregator.assert_instance_of(
                  label,
                  expected: String,
                  as:       'label'
                )
                aggregator.validate(message: 'something went wrong') { true }
              end
            end

            include_deferred 'should pass the assertion'
          end

          describe 'with a block with nested aggregations' do
            let(:quantity) { nil }
            let(:label)    { nil }
            let(:block) do
              lambda do |aggregator|
                aggregator.assert_group do |inner|
                  inner.assert_instance_of(label, expected: String, as: 'label')
                  inner.assert_presence(label, as: 'label')
                end

                aggregator.assert_instance_of(
                  quantity,
                  expected: Integer,
                  as:       'quantity'
                )
              end
            end
            let(:expected_message) { message }

            include_deferred 'should fail the assertion',
              skip_as: true,
              **deferred_options
          end

          describe 'with a block with nested aggregations and message: value' do
            let(:quantity) { nil }
            let(:label)    { nil }
            let(:block) do
              lambda do |aggregator|
                aggregator.assert_group(message: 'label is invalid') do |inner|
                  inner.assert_instance_of(label, expected: String, as: 'label')
                  inner.assert_presence(label, as: 'label')
                end

                aggregator.assert_instance_of(
                  quantity,
                  expected: Integer,
                  as:       'quantity'
                )
              end
            end
            let(:expected_message) { message }

            include_deferred 'should fail the assertion',
              skip_as: true,
              **deferred_options
          end
        end
      end

      describe "##{prefix}_inherits_from" do
        let(:error_key) { 'inherit_from' }
        let(:expected)  { StandardError }
        let(:options)   { { expected: } }

        define_method :assert do
          subject.public_send(:"#{prefix}_inherits_from", value, **options)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:"#{prefix}_inherits_from")
            .with(1).argument
            .and_keywords(*default_keywords, :as, :expected, :strict)
        end

        describe 'with nil' do
          let(:error_key) { 'class_or_module' }
          let(:value)     { nil }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with an Object' do
          let(:error_key) { 'class_or_module' }
          let(:value)     { Object.new.freeze }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with a Class that is not a subclass of the expected class' do
          let(:value) { Class.new }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with a Class that is a subclass of the expected class' do
          let(:value) { RuntimeError }

          include_deferred 'should pass the assertion'
        end

        describe 'with the expected class' do
          let(:value) { expected }

          include_deferred 'should pass the assertion'
        end

        describe 'with expected: nil' do
          let(:value)    { nil }
          let(:expected) { nil }

          it 'should raise an exception' do
            expect { assert }.to raise_error(
              ArgumentError,
              'expected must be a Class or Module'
            )
          end
        end

        describe 'with expected: an Object' do
          let(:value)    { nil }
          let(:expected) { Object.new.freeze }

          it 'should raise an exception' do
            expect { assert }.to raise_error(
              ArgumentError,
              'expected must be a Class or Module'
            )
          end
        end

        describe 'with expected: a Module' do
          let(:expected) { Enumerable }

          describe 'with a Class does not inherit from the module' do
            let(:value) { Class.new }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a Class that extends the module' do
            let(:value) { Class.new.extend(Enumerable) }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a Class that includes the module' do
            let(:value) { Array }

            include_deferred 'should pass the assertion'
          end

          describe 'with a Class that prepends the module' do
            let(:value) { Class.new.prepend(Enumerable) }

            include_deferred 'should pass the assertion'
          end

          describe 'with the given module' do
            let(:value) { expected }

            include_deferred 'should pass the assertion'
          end

          describe 'with a Module that does not inherit from the module' do
            let(:value) { Module.new }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a Module that extends the module' do
            let(:value) { Module.new.extend(Enumerable) }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a Module that includes the module' do
            let(:value) { Module.new.include(Enumerable) }

            include_deferred 'should pass the assertion'
          end

          describe 'with a Module that prepends the module' do
            let(:value) { Module.new.prepend(Enumerable) }

            include_deferred 'should pass the assertion'
          end
        end

        describe 'with strict: false' do
          let(:options) { super().merge(strict: false) }

          describe 'with a Class that is not a subclass' do
            let(:value) { Class.new }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a Class that is a subclass' do
            let(:value) { RuntimeError }

            include_deferred 'should pass the assertion'
          end

          describe 'with the expected class' do
            let(:value) { expected }

            include_deferred 'should pass the assertion'
          end

          describe 'with expected: a Module' do
            describe 'with the given module' do
              let(:value) { expected }

              include_deferred 'should pass the assertion'
            end
          end
        end

        describe 'with strict: true' do
          let(:options) { super().merge(strict: true) }

          describe 'with a Class that is not a subclass' do
            let(:value) { Class.new }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a Class that is a subclass' do
            let(:value) { RuntimeError }

            include_deferred 'should pass the assertion'
          end

          describe 'with the expected class' do
            let(:value) { expected }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with expected: a Module' do
            describe 'with the given module' do
              let(:value) { expected }

              include_deferred 'should fail the assertion', **deferred_options
            end
          end
        end
      end

      describe "##{prefix}_instance_of" do
        let(:error_key) { 'instance_of' }
        let(:expected)  { StandardError }
        let(:options)   { { expected: } }

        define_method :assert do
          subject.public_send(:"#{prefix}_instance_of", value, **options)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:"#{prefix}_instance_of")
            .with(1).argument
            .and_keywords(*default_keywords, :as, :expected, :optional)
        end

        describe 'with nil' do
          let(:value) { nil }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with an instance of the class' do
          let(:value) { StandardError.new }

          include_deferred 'should pass the assertion'
        end

        describe 'with an instance of a subclass of the class' do
          let(:value) { RuntimeError.new }

          include_deferred 'should pass the assertion'
        end

        describe 'with expected: nil' do
          let(:value)    { nil }
          let(:expected) { nil }

          it 'should raise an exception' do
            expect { assert }.to raise_error(
              ArgumentError,
              'expected must be a Class or Module'
            )
          end
        end

        describe 'with expected: an Object' do
          let(:value)    { nil }
          let(:expected) { Object.new.freeze }

          it 'should raise an exception' do
            expect { assert }.to raise_error(
              ArgumentError,
              'expected must be a Class or Module'
            )
          end
        end

        describe 'with expected: an anonymous subclass' do
          let(:error_key) { 'instance_of_anonymous' }
          let(:expected)  { Class.new(StandardError) }
          let(:message_options) do
            options.merge(parent: StandardError)
          end

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an Object' do
            let(:value) { Object.new.freeze }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an instance of the class' do
            let(:value) { expected.new }

            include_deferred 'should pass the assertion'
          end

          describe 'with an instance of a subclass of the class' do
            let(:value) { Class.new(expected).new }

            include_deferred 'should pass the assertion'
          end
        end

        describe 'with expected: a module' do
          let(:expected) { Enumerable }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an Object' do
            let(:value) { Object.new.freeze }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an object extends the Module' do
            let(:value) { Object.new.extend(Enumerable) }

            include_deferred 'should pass the assertion'
          end

          describe 'with an instance of a class that includes the Module' do
            let(:value) { [] }

            include_deferred 'should pass the assertion'
          end

          describe 'with an instance of a class that prepends the Module' do
            let(:value) { Class.new.prepend(Enumerable).new }

            include_deferred 'should pass the assertion'
          end
        end

        describe 'with optional: false' do
          let(:options) { super().merge(optional: false) }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an Object' do
            let(:value) { Object.new.freeze }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an instance of the class' do
            let(:value) { StandardError.new }

            include_deferred 'should pass the assertion'
          end

          describe 'with an instance of a subclass of the class' do
            let(:value) { RuntimeError.new }

            include_deferred 'should pass the assertion'
          end
        end

        describe 'with optional: true' do
          let(:options) { super().merge(optional: true) }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should pass the assertion'
          end

          describe 'with an Object' do
            let(:value) { Object.new.freeze }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an instance of the class' do
            let(:value) { StandardError.new }

            include_deferred 'should pass the assertion'
          end

          describe 'with an instance of a subclass of the class' do
            let(:value) { RuntimeError.new }

            include_deferred 'should pass the assertion'
          end
        end
      end

      describe "##{prefix}_matches" do
        let(:error_key)   { 'matches' }
        let(:value)       { nil }
        let(:expected)    { Spec::ExampleMatcher.new('expected') }
        let(:options)     { { expected: } }
        let(:matching)    { 'expected' }
        let(:nonmatching) { 'actual' }

        example_class 'Spec::ExampleMatcher', Struct.new(:value) do |klass|
          klass.define_method(:===) { |other| other == value }
        end

        define_method :assert do
          subject.public_send(:"#{prefix}_matches", value, **options)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:"#{prefix}_matches")
            .with(1).arguments
            .and_keywords(*default_keywords, :as, :expected, :optional)
        end

        describe 'with nil' do
          let(:value) { nil }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with a non-matching value' do
          let(:value) { nonmatching }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with a matching value' do
          let(:value) { matching }

          include_deferred 'should pass the assertion'
        end

        describe 'with expected: a Class' do
          let(:error_key) { 'instance_of' }
          let(:expected)  { StandardError }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a non-matching value' do
            let(:value) { nonmatching }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an instance of the class' do
            let(:value) { StandardError.new }

            include_deferred 'should pass the assertion'
          end

          describe 'with an instance of a subclass of the class' do
            let(:value) { RuntimeError.new }

            include_deferred 'should pass the assertion'
          end
        end

        describe 'with expected: an anonymous Class' do
          let(:error_key) { 'instance_of_anonymous' }
          let(:message_options) do
            options.merge(parent: StandardError)
          end
          let(:expected) { Class.new(StandardError) }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a non-matching value' do
            let(:value) { nonmatching }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an instance of the class' do
            let(:value) { expected.new }

            include_deferred 'should pass the assertion'
          end

          describe 'with an instance of a subclass of the class' do
            let(:value) { Class.new(expected).new }

            include_deferred 'should pass the assertion'
          end
        end

        describe 'with expected: a Module' do
          let(:error_key) { 'instance_of' }
          let(:expected)  { Enumerable }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a non-matching value' do
            let(:value) { nonmatching }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an object extends the Module' do
            let(:value) { Object.new.extend(Enumerable) }

            include_deferred 'should pass the assertion'
          end

          describe 'with an instance of a class that includes the Module' do
            let(:value) { [] }

            include_deferred 'should pass the assertion'
          end

          describe 'with an instance of a class that prepends the Module' do
            let(:value) { Class.new.prepend(Enumerable).new }

            include_deferred 'should pass the assertion'
          end
        end

        describe 'with expected: a Proc' do
          let(:error_key) { 'matches_proc' }
          let(:expected)  { ->(value) { value >= 0 } }

          describe 'with nil' do
            let(:value) { nil }

            it { expect { assert }.to raise_error NoMethodError }
          end

          describe 'with a non-matching value' do
            let(:value) { -1 }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a matching value' do
            let(:value) { 1 }

            include_deferred 'should pass the assertion'
          end
        end

        describe 'with expected: a Regexp' do
          let(:error_key) { 'matches_regexp' }
          let(:expected)  { /foo/ }
          let(:message_options) do
            options.merge(pattern: expected.inspect)
          end

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a non-matching value' do
            let(:value) { 'bar' }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a matching value' do
            let(:value) { 'foo' }

            include_deferred 'should pass the assertion'
          end
        end

        describe 'with optional: false' do
          let(:options) { super().merge(optional: false) }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a non-matching value' do
            let(:value) { nonmatching }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a matching value' do
            let(:value) { matching }

            include_deferred 'should pass the assertion'
          end
        end

        describe 'with optional: true' do
          let(:options) { super().merge(optional: true) }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should pass the assertion'
          end

          describe 'with a non-matching value' do
            let(:value) { nonmatching }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a matching value' do
            let(:value) { matching }

            include_deferred 'should pass the assertion'
          end
        end
      end

      describe "##{prefix}_name" do
        let(:error_key) { 'presence' }

        define_method :assert do
          subject.public_send(:"#{prefix}_name", value, **options)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:"#{prefix}_name")
            .with(1).argument
            .and_keywords(*default_keywords, :as, :optional)
        end

        describe 'with nil' do
          let(:value) { nil }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with an Object' do
          let(:error_key) { 'name' }
          let(:value)     { Object.new.freeze }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with an empty String' do
          let(:value) { '' }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with an empty Symbol' do
          let(:value) { :'' }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with a String' do
          let(:value) { 'string' }

          include_deferred 'should pass the assertion'
        end

        describe 'with a Symbol' do
          let(:value) { :symbol }

          include_deferred 'should pass the assertion'
        end

        describe 'with optional: false' do
          let(:options) { super().merge(optional: false) }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an Object' do
            let(:error_key) { 'name' }
            let(:value)     { Object.new.freeze }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an empty String' do
            let(:value) { '' }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an empty Symbol' do
            let(:value) { :'' }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a String' do
            let(:value) { 'string' }

            include_deferred 'should pass the assertion'
          end

          describe 'with a Symbol' do
            let(:value) { :symbol }

            include_deferred 'should pass the assertion'
          end
        end

        describe 'with optional: true' do
          let(:options) { super().merge(optional: true) }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should pass the assertion'
          end

          describe 'with an Object' do
            let(:error_key) { 'name' }
            let(:value)     { Object.new.freeze }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an empty String' do
            let(:value) { '' }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an empty Symbol' do
            let(:value) { :'' }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a String' do
            let(:value) { 'string' }

            include_deferred 'should pass the assertion'
          end

          describe 'with a Symbol' do
            let(:value) { :symbol }

            include_deferred 'should pass the assertion'
          end
        end
      end

      describe "##{prefix}_nil" do
        let(:error_key) { 'nil' }

        define_method :assert do
          subject.public_send(:"#{prefix}_nil", value, **options)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:"#{prefix}_nil")
            .with(1).argument
            .and_keywords(*default_keywords, :as)
        end

        describe 'with nil' do
          let(:value) { nil }

          include_deferred 'should pass the assertion'
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_deferred 'should fail the assertion', **deferred_options
        end
      end

      describe "##{prefix}_not_nil" do
        let(:error_key) { 'not_nil' }

        define_method :assert do
          subject.public_send(:"#{prefix}_not_nil", value, **options)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:"#{prefix}_not_nil")
            .with(1).argument
            .and_keywords(*default_keywords, :as)
        end

        describe 'with nil' do
          let(:value) { nil }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_deferred 'should pass the assertion'
        end
      end

      describe "##{prefix}_presence" do
        let(:error_key) { 'presence' }

        define_method :assert do
          subject.public_send(:"#{prefix}_presence", value, **options)
        end

        it 'should define the method' do
          expect(subject)
            .to respond_to(:"#{prefix}_presence")
            .with(1).argument
            .and_keywords(*default_keywords, :as, :optional)
        end

        describe 'with nil' do
          let(:value) { nil }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with an Object' do
          let(:value) { Object.new.freeze }

          include_deferred 'should pass the assertion'
        end

        describe 'with an empty value' do
          let(:value) { Struct.new(:empty) { def empty? = empty }.new(true) }

          include_deferred 'should fail the assertion', **deferred_options
        end

        describe 'with a non-empty value' do
          let(:value) { Struct.new(:empty) { def empty? = empty }.new(false) }

          include_deferred 'should pass the assertion'
        end

        describe 'with optional: false' do
          let(:options) { super().merge(optional: false) }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with an Object' do
            let(:value) { Object.new.freeze }

            include_deferred 'should pass the assertion'
          end

          describe 'with an empty value' do
            let(:value) { Struct.new(:empty) { def empty? = empty }.new(true) }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a non-empty value' do
            let(:value) { Struct.new(:empty) { def empty? = empty }.new(false) }

            include_deferred 'should pass the assertion'
          end
        end

        describe 'with optional: true' do
          let(:options) { super().merge(optional: true) }

          describe 'with nil' do
            let(:value) { nil }

            include_deferred 'should pass the assertion'
          end

          describe 'with an Object' do
            let(:value) { Object.new.freeze }

            include_deferred 'should pass the assertion'
          end

          describe 'with an empty value' do
            let(:value) { Struct.new(:empty) { def empty? = empty }.new(true) }

            include_deferred 'should fail the assertion', **deferred_options
          end

          describe 'with a non-empty value' do
            let(:value) { Struct.new(:empty) { def empty? = empty }.new(false) }

            include_deferred 'should pass the assertion'
          end
        end
      end
    end
  end
end
