# frozen_string_literal: true

require 'sleeping_king_studios/tools/core_tools'

RSpec.describe SleepingKingStudios::Tools::CoreTools do
  subject(:core_tools) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  describe '.deprecation_strategies' do
    let(:expected) { Set.new(%w[ignore raise warn]) }

    include_examples 'should define class reader', :deprecation_strategies

    it { expect(described_class.deprecation_strategies).to be == expected }

    it { expect(described_class.deprecation_strategies).to be_frozen }
  end

  describe '.new' do
    let(:expected_keywords) do
      %i[
        deprecation_caller_depth
        deprecation_strategy
        toolbelt
      ]
    end

    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(*expected_keywords)
    end

    describe 'with deprecation_strategy: invalid value' do
      let(:constructor_options) { super().merge(deprecation_strategy: 'panic') }
      let(:error_message) do
        'invalid deprecation strategy "panic" - valid options are ' \
          '"ignore", "raise", "warn"'
      end

      it 'should raise an exception' do
        expect { described_class.new(**constructor_options) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#deprecate' do
    let(:deprecation_strategy) { 'warn' }
    let(:object)               { 'PHP' }
    let(:custom_format)        { '[WARNING] %s has been deprecated.' }
    let(:object_string)        { Kernel.format(custom_format, object) }
    let(:constructor_options)  { super().merge(deprecation_strategy:) }

    it 'should define the method' do
      expect(core_tools)
        .to respond_to(:deprecate)
        .with(1).argument
        .and_keywords(:caller, :format, :message)
        .and_unlimited_arguments
    end

    context 'when the deprecation strategy is "ignore"' do
      let(:deprecation_strategy) { 'ignore' }

      before(:example) { allow(Kernel).to receive(:warn) }

      it 'should not print a warning' do
        core_tools.deprecate object

        expect(Kernel).not_to have_received(:warn)
      end
    end

    context 'when the deprecation strategy is "raise"' do
      let(:deprecation_strategy) { 'raise' }
      let(:custom_format)        { '%s has been deprecated.' }
      let(:error_message)        { object_string }

      it 'should raise an error' do
        expect { core_tools.deprecate object }
          .to raise_error described_class::DeprecationError, error_message
      end

      it 'should truncate the exception backtrace' do
        core_tools.deprecate(object)
      rescue described_class::DeprecationError => exception
        expect(exception.backtrace.first).to include(__FILE__)
      end

      describe 'with an additional message' do
        let(:message)       { 'You should probably switch to a real language.' }
        let(:error_message) { "#{object_string} #{message}" }

        it 'should raise an error' do
          expect { core_tools.deprecate object, message: }
            .to raise_error described_class::DeprecationError, error_message
        end
      end

      describe 'with a custom format string' do
        let(:custom_format) { '%s has been deprecated since %s.' }
        let(:version)       { '1.0.0' }
        let(:object_string) { format(custom_format, object, version) }

        before(:example) do
          # rubocop:disable RSpec/SubjectStub
          allow(core_tools).to receive(:deprecate).and_wrap_original \
          do |original, *args, format: nil, **kwargs|
            original.call(*args, format:, **kwargs) if format
          end
          # rubocop:enable RSpec/SubjectStub
        end

        it 'should raise an error' do
          expect { core_tools.deprecate object, version, format: custom_format }
            .to raise_error described_class::DeprecationError, error_message
        end

        it 'should report the deprecated option' do # rubocop:disable RSpec/ExampleLength
          begin
            core_tools.deprecate(object, version, format: custom_format)
          rescue described_class::DeprecationError
            # Do nothing.
          end

          expect(core_tools) # rubocop:disable RSpec/SubjectStub
            .to have_received(:deprecate)
            .with("#{described_class.name}#deprecate with :format option")
        end
      end

      describe 'with caller: custom stack' do
        let(:caller_stack) do
          [
            "/custom/stack/first.rb in '<spec>'",
            "/custom/stack/second.rb in '<spec>'",
            "/custom/stack/third.rb in '<spec>'"
          ]
        end

        it 'should raise an error' do
          expect { core_tools.deprecate(object, caller: caller_stack) }
            .to raise_error described_class::DeprecationError, error_message
        end

        it 'should set the exception backtrace' do
          core_tools.deprecate(object, caller: caller_stack)
        rescue described_class::DeprecationError => exception
          expect(exception.backtrace).to be == caller_stack
        end
      end
    end

    context 'when the deprecation strategy is "warn"' do
      let(:deprecation_strategy) { 'warn' }
      let(:caller_string)        { '/path/to/file.rb:4: in something_or_other' }
      let(:caller_lines) do
        [
          '/path/to/sleeping_king_studios-tools/some/internal/code.rb',
          '/path/to/forwardable.rb',
          caller_string,
          *caller
        ]
      end
      let(:scoped_caller) do
        caller_lines[2..(1 + core_tools.deprecation_caller_depth)]
      end
      let(:formatted_caller) do
        scoped_caller
          .map { |line| "\n  called from #{line}" }
          .join
      end
      let(:formatted_warning) do
        str = object_string
        str << formatted_caller
      end

      before(:example) do
        allow(Kernel).to receive(:warn)

        allow(core_tools) # rubocop:disable RSpec/SubjectStub
          .to receive(:caller)
          .and_return(caller_lines)
      end

      it 'should print a deprecation warning' do
        core_tools.deprecate object

        expect(Kernel).to have_received(:warn).with(formatted_warning)
      end

      describe 'with an additional message' do
        let(:message) { 'You should probably switch to a real language.' }
        let(:formatted_warning) do
          str = object_string
          str << ' ' << message
          str << formatted_caller
        end

        it 'should print a deprecation warning' do
          core_tools.deprecate(object, message:)

          expect(Kernel).to have_received(:warn).with(formatted_warning)
        end
      end

      describe 'with a custom format string' do
        let(:custom_format) { '[ALERT] %s has been deprecated since %s.' }
        let(:version)       { '1.0.0' }
        let(:object_string) { format(custom_format, object, version) }

        before(:example) do
          # rubocop:disable RSpec/SubjectStub
          allow(core_tools).to receive(:deprecate).and_wrap_original \
          do |original, *args, format: nil, **kwargs|
            original.call(*args, format:, **kwargs) if format
          end
          # rubocop:enable RSpec/SubjectStub
        end

        it 'should print a deprecation warning' do
          core_tools.deprecate object, version, format: custom_format

          expect(Kernel).to have_received(:warn).with(formatted_warning)
        end

        it 'should report the deprecated option' do
          core_tools.deprecate(object, version, format: custom_format)

          expect(core_tools) # rubocop:disable RSpec/SubjectStub
            .to have_received(:deprecate)
            .with("#{described_class.name}#deprecate with :format option")
        end
      end

      describe 'with caller: custom stack' do
        let(:caller_stack) do
          [
            "/custom/stack/first.rb in '<spec>'",
            "/custom/stack/second.rb in '<spec>'",
            "/custom/stack/third.rb in '<spec>'"
          ]
        end
        let(:scoped_caller) { caller_stack }

        it 'should print a deprecation warning' do
          core_tools.deprecate(object, caller: caller_stack)

          expect(Kernel).to have_received(:warn).with(formatted_warning)
        end
      end

      context 'when initialized with deprecation_caller_depth: 0' do
        let(:constructor_options) do
          super().merge(deprecation_caller_depth: 0)
        end
        let(:formatted_warning) { object_string }

        it 'should print a deprecation warning' do
          core_tools.deprecate object

          expect(Kernel).to have_received(:warn).with(formatted_warning)
        end
      end

      context 'when initialized with deprecation_caller_depth: value' do
        let(:constructor_options) do
          super().merge(deprecation_caller_depth: 10)
        end

        it 'should print a deprecation warning' do
          core_tools.deprecate object

          expect(Kernel).to have_received(:warn).with(formatted_warning)
        end
      end
    end
  end

  describe '#deprecation_caller_depth' do
    let(:core_tools) do
      described_class.new(**constructor_options)
    end
    let(:constructor_options) { {} }

    it 'should define the method' do
      expect(core_tools)
        .to respond_to(:deprecation_caller_depth)
        .with(0)
        .arguments
    end

    context 'when ENV[DEPRECATION_CALLER_DEPTH] is not set' do
      around(:example) do |example|
        previous = ENV.fetch('DEPRECATION_CALLER_DEPTH', nil)

        ENV['DEPRECATION_CALLER_DEPTH'] = nil

        example.call
      ensure
        ENV['DEPRECATION_CALLER_DEPTH'] = previous
      end

      it { expect(core_tools.send :deprecation_caller_depth).to be 3 }

      context 'when initialized with deprecation_caller_depth: value' do
        let(:constructor_options) do
          super().merge(deprecation_caller_depth: 10)
        end

        it { expect(core_tools.send :deprecation_caller_depth).to be 10 }
      end
    end

    context 'when ENV[DEPRECATION_CALLER_DEPTH] is set' do
      around(:example) do |example|
        previous = ENV.fetch('DEPRECATION_CALLER_DEPTH', nil)

        ENV['DEPRECATION_CALLER_DEPTH'] = '15'

        example.call
      ensure
        ENV['DEPRECATION_CALLER_DEPTH'] = previous
      end

      it { expect(core_tools.send :deprecation_caller_depth).to be 15 }

      context 'when initialized with deprecation_caller_depth: value' do
        let(:constructor_options) do
          super().merge(deprecation_caller_depth: 10)
        end

        it { expect(core_tools.send :deprecation_caller_depth).to be 10 }
      end
    end
  end

  describe '#deprecation_strategy' do
    shared_context 'when ENV[DEPRECATION_STRATEGY] is not set' do
      around(:example) do |example|
        previous = ENV.fetch('DEPRECATION_STRATEGY', nil)

        ENV['DEPRECATION_STRATEGY'] = nil

        example.call
      ensure
        ENV['DEPRECATION_STRATEGY'] = previous
      end
    end

    shared_context 'when ENV[DEPRECATION_STRATEGY] is set' \
    do |configured_strategy|
      around(:example) do |example|
        previous = ENV.fetch('DEPRECATION_STRATEGY', nil)

        ENV['DEPRECATION_STRATEGY'] = configured_strategy

        example.call
      ensure
        ENV['DEPRECATION_STRATEGY'] = previous
      end
    end

    let(:core_tools) do
      described_class.new(**constructor_options)
    end
    let(:constructor_options) { {} }

    it 'should define the method' do
      expect(core_tools).to respond_to(:deprecation_strategy).with(0).arguments
    end

    wrap_context 'when ENV[DEPRECATION_STRATEGY] is not set' do
      it { expect(core_tools.deprecation_strategy).to be == 'warn' }
    end

    wrap_context 'when ENV[DEPRECATION_STRATEGY] is set', 'raise' do
      it { expect(core_tools.deprecation_strategy).to be == 'raise' }
    end

    context 'when initialized with deprecation_strategy: ignore' do
      let(:constructor_options) do
        super().merge(deprecation_strategy: 'ignore')
      end

      it { expect(core_tools.deprecation_strategy).to be == 'ignore' }

      wrap_context 'when ENV[DEPRECATION_STRATEGY] is not set' do
        it { expect(core_tools.deprecation_strategy).to be == 'ignore' }
      end

      wrap_context 'when ENV[DEPRECATION_STRATEGY] is set', 'raise' do
        it { expect(core_tools.deprecation_strategy).to be == 'ignore' }
      end
    end

    context 'when initialized with deprecation_strategy: raise' do
      let(:constructor_options) do
        super().merge(deprecation_strategy: 'raise')
      end

      it { expect(core_tools.deprecation_strategy).to be == 'raise' }

      wrap_context 'when ENV[DEPRECATION_STRATEGY] is not set' do
        it { expect(core_tools.deprecation_strategy).to be == 'raise' }
      end

      wrap_context 'when ENV[DEPRECATION_STRATEGY] is set', 'warn' do
        it { expect(core_tools.deprecation_strategy).to be == 'raise' }
      end
    end

    context 'when initialized with deprecation_strategy: warn' do
      let(:constructor_options) do
        super().merge(deprecation_strategy: 'warn')
      end

      it { expect(core_tools.deprecation_strategy).to be == 'warn' }

      wrap_context 'when ENV[DEPRECATION_STRATEGY] is not set' do
        it { expect(core_tools.deprecation_strategy).to be == 'warn' }
      end

      wrap_context 'when ENV[DEPRECATION_STRATEGY] is set', 'ignore' do
        it { expect(core_tools.deprecation_strategy).to be == 'warn' }
      end
    end
  end

  describe '#empty_binding' do
    it 'should define the method' do
      expect(described_class).to respond_to(:empty_binding).with(0).arguments
    end

    it { expect(core_tools.empty_binding).to be_a Binding }

    it 'should set an Object as the receiver' do
      binding = core_tools.empty_binding

      expect(binding.receiver.class).to be Object
    end
  end

  describe '#require_each' do
    before(:example) do
      allow(core_tools).to receive(:deprecate) # rubocop:disable RSpec/SubjectStub

      allow(Kernel).to receive(:require)
    end

    it 'should define the method' do
      expect(described_class)
        .to respond_to(:require_each)
        .with_unlimited_arguments
    end

    it 'should print a deprecation warning' do
      core_tools.require_each

      expect(core_tools) # rubocop:disable RSpec/SubjectStub
        .to have_received(:deprecate)
        .with("#{described_class.name}#require_each")
    end

    describe 'with one file name' do
      let(:file_name) { '/path/to/file' }

      it 'should require the file' do
        core_tools.require_each file_name

        expect(Kernel).to have_received(:require).with(file_name)
      end
    end

    describe 'with many file names' do
      let(:file_names) do
        ['/path/to/first', '/path/to/second', '/path/to/third']
      end

      it 'should require the file', :aggregate_failures do
        core_tools.require_each(*file_names)

        file_names.each do |file_name|
          expect(Kernel).to have_received(:require).with(file_name)
        end
      end
    end

    describe 'with a file pattern' do
      let(:file_pattern) { '/path/to/directory/**/*.rb' }
      let(:file_names) do
        [
          '/path/to/directory/one.rb',
          '/path/to/directory/two.rb',
          '/path/to/directory/three/point_one.rb'
        ]
      end

      before(:example) do
        allow(Dir).to receive(:[]).with(file_pattern).and_return(file_names)
      end

      it 'should require all files matching the pattern' do
        core_tools.require_each file_pattern

        file_names.each do |file_name|
          expect(Kernel).to have_received(:require).with(file_name)
        end
      end
    end
  end

  describe '#toolbelt' do
    let(:expected) { SleepingKingStudios::Tools::Toolbelt.global }

    it { expect(core_tools.toolbelt).to be expected }

    it { expect(core_tools).to have_aliased_method(:toolbelt).as(:tools) }

    context 'when initialized with toolbelt: value' do
      let(:toolbelt) { SleepingKingStudios::Tools::Toolbelt.new }
      let(:constructor_options) do
        super().merge(toolbelt:)
      end

      it { expect(core_tools.toolbelt).to be toolbelt }
    end
  end
end
