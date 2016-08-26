# spec/sleeping_king_studios/tools/core_tools_spec.rb

require 'spec_helper'

require 'sleeping_king_studios/tools/core_tools'

RSpec.describe SleepingKingStudios::Tools::CoreTools do
  let(:instance) { Object.new.extend described_class }

  describe '#deprecate' do
    let(:object)        { 'PHP' }
    let(:format)        { '[WARNING] %s has been deprecated.' }
    let(:object_string) { format % object }
    let(:caller_string) { '/path/to/file.rb:4: in something_or_other' }
    let(:formatted_warning) do
      str = object_string
      str << "\n  called from #{caller_string}"
    end # let

    before(:example) do
      allow(instance).to receive(:caller).and_return([nil, caller_string])
    end # before example

    it 'should define the method' do
      expect(instance).
        to respond_to(:deprecate).
        with(1).argument.
        and_keywords(:format, :message).
        and_unlimited_arguments
    end # it

    it 'should print a deprecation warning' do
      expect(Kernel).to receive(:warn).with(formatted_warning)

      instance.deprecate object
    end # it

    describe 'with an additional message' do
      let(:message) { 'You should probably switch to a real language.' }
      let(:formatted_warning) do
        str = object_string
        str << ' ' << message
        str << "\n  called from #{caller_string}"
      end # let

      it 'should print a deprecation warning' do
        expect(Kernel).to receive(:warn).with(formatted_warning)

        instance.deprecate object, :message => message
      end # it
    end # describe

    describe 'with a custom format string' do
      let(:format)        { '[ALERT] %s has been deprecated since %s.' }
      let(:version)       { '1.0.0' }
      let(:object_string) { format % [object, version] }

      it 'should print a deprecation warning' do
        expect(Kernel).to receive(:warn).with(formatted_warning)

        instance.deprecate object, version, :format => format
      end # it
    end # describe
  end # describe

  describe '#require_each' do
    it 'should define the method' do
      expect(described_class).
        to respond_to(:require_each).
        with_unlimited_arguments
    end # it

    describe 'with one file name' do
      let(:file_name) { '/path/to/file' }

      it 'should require the file' do
        expect(Kernel).to receive(:require).with(file_name)

        instance.require_each file_name
      end # it
    end # describe

    describe 'with many file names' do
      let(:file_names) { ['/path/to/first', '/path/to/second', '/path/to/third'] }

      it 'should require the file' do
        file_names.each do |file_name|
          expect(Kernel).to receive(:require).with(file_name)
        end # each

        instance.require_each *file_names
      end # it
    end # describe

    describe 'with a file pattern' do
      let(:file_pattern) { '/path/to/directory/**/*.rb' }
      let(:file_names) do
        [
          '/path/to/directory/one.rb',
          '/path/to/directory/two.rb',
          '/path/to/directory/three/point_one.rb'
        ] # end array
      end # let

      before(:example) do
        allow(Dir).to receive(:[]).with(file_pattern).and_return(file_names)
      end # before

      it 'should require all files matching the pattern' do
        file_names.each do |file_name|
          expect(Kernel).to receive(:require).with(file_name)
        end # each

        instance.require_each file_pattern
      end # it
    end # describe
  end # describe
end # describe
