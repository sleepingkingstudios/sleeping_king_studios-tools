# frozen_string_literal: true

require 'spec_helper'

require 'sleeping_king_studios/tools/core_tools'

RSpec.describe SleepingKingStudios::Tools::CoreTools do
  let(:instance) { described_class.instance }

  describe '#deprecate' do
    let(:object)        { 'PHP' }
    let(:custom_format) { '[WARNING] %s has been deprecated.' }
    let(:object_string) { Kernel.format(custom_format, object) }
    let(:caller_string) { '/path/to/file.rb:4: in something_or_other' }
    let(:formatted_warning) do
      str = object_string
      str << "\n  called from #{caller_string}"
    end

    before(:example) do
      allow(instance).to receive(:caller).and_return([nil, caller_string])

      allow(Kernel).to receive(:warn)
    end

    it 'should define the method' do
      expect(instance)
        .to respond_to(:deprecate)
        .with(1).argument
        .and_keywords(:format, :message)
        .and_unlimited_arguments
    end

    it 'should print a deprecation warning' do
      instance.deprecate object

      expect(Kernel).to have_received(:warn).with(formatted_warning)
    end

    describe 'with an additional message' do
      let(:message) { 'You should probably switch to a real language.' }
      let(:formatted_warning) do
        str = object_string
        str << ' ' << message
        str << "\n  called from #{caller_string}"
      end

      it 'should print a deprecation warning' do
        instance.deprecate object, message: message

        expect(Kernel).to have_received(:warn).with(formatted_warning)
      end
    end

    describe 'with a custom format string' do
      let(:custom_format) { '[ALERT] %s has been deprecated since %s.' }
      let(:version)       { '1.0.0' }
      let(:object_string) { format(custom_format, object, version) }

      it 'should print a deprecation warning' do
        instance.deprecate object, version, format: custom_format

        expect(Kernel).to have_received(:warn).with(formatted_warning)
      end
    end
  end

  describe '#empty_binding' do
    it 'should define the method' do
      expect(described_class).to respond_to(:empty_binding).with(0).arguments
    end

    it { expect(described_class.empty_binding).to be_a Binding }

    it 'should set an Object as the receiver' do
      binding = described_class.empty_binding

      expect(binding.receiver.class).to be Object
    end
  end

  describe '#require_each' do
    before(:example) do
      allow(Kernel).to receive(:require)
    end

    it 'should define the method' do
      expect(described_class)
        .to respond_to(:require_each)
        .with_unlimited_arguments
    end

    describe 'with one file name' do
      let(:file_name) { '/path/to/file' }

      it 'should require the file' do
        instance.require_each file_name

        expect(Kernel).to have_received(:require).with(file_name)
      end
    end

    describe 'with many file names' do
      let(:file_names) do
        ['/path/to/first', '/path/to/second', '/path/to/third']
      end

      it 'should require the file', :aggregate_failures do
        instance.require_each(*file_names)

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
        instance.require_each file_pattern

        file_names.each do |file_name|
          expect(Kernel).to have_received(:require).with(file_name)
        end
      end
    end
  end
end
