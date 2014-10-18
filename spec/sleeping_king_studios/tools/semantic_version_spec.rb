# spec/sleeping_king_studios/tools/semantic_version_spec.rb

require 'sleeping_king_studios/tools/semantic_version'

RSpec.describe SleepingKingStudios::Tools::SemanticVersion do
  let(:instance) { Module.new.extend described_class }

  describe '#to_gem_version' do
    let(:major)      { 3 }
    let(:minor)      { 1 }
    let(:patch)      { 4 }
    let(:prerelease) { 'beta' }
    let(:build)      { 159 }

    it { expect(instance).to respond_to(:to_gem_version) }

    context 'with a missing Major version' do
      it 'raises an error' do
        expect { instance.to_gem_version }.to raise_error SleepingKingStudios::Tools::SemanticVersion::InvalidVersionError,
          'undefined constant for major version'
      end # it
    end # context

    context 'with a missing Minor version' do
      before(:each) do
        instance.const_set :MAJOR, major
      end # before each

      it 'raises an error' do
        expect { instance.to_gem_version }.to raise_error SleepingKingStudios::Tools::SemanticVersion::InvalidVersionError,
          'undefined constant for minor version'
      end # it
    end # context

    context 'with a missing Patch version' do
      before(:each) do
        instance.const_set :MAJOR, major
        instance.const_set :MINOR, minor
      end # before each

      it 'raises an error' do
        expect { instance.to_gem_version }.to raise_error SleepingKingStudios::Tools::SemanticVersion::InvalidVersionError,
          'undefined constant for patch version'
      end # it
    end # context

    context 'with Major, Minor, and Patch versions' do
      before(:each) do
        instance.const_set :MAJOR, major
        instance.const_set :MINOR, minor
        instance.const_set :PATCH, patch
      end # before each

      it 'returns the version string' do
        expect(instance.to_gem_version).to be == "#{major}.#{minor}.#{patch}"
      end # it

      context 'with a Prerelease version' do
        before(:each) { instance.const_set :PRERELEASE, prerelease }

        it 'returns the version string' do
          expect(instance.to_gem_version).to be == "#{major}.#{minor}.#{patch}.#{prerelease}"
        end # it

        context 'with a Build version' do
          before(:each) { instance.const_set :BUILD, build }

          it 'returns the version string' do
            expect(instance.to_gem_version).to be == "#{major}.#{minor}.#{patch}.#{prerelease}.#{build}"
          end # it
        end # context
      end # context

      context 'with a Build version' do
        before(:each) { instance.const_set :BUILD, build }

        it 'returns the version string' do
          expect(instance.to_gem_version).to be == "#{major}.#{minor}.#{patch}.#{build}"
        end # it
      end # context
    end # context
  end # describe

  describe '#to_version' do
    let(:major)      { 3 }
    let(:minor)      { 1 }
    let(:patch)      { 4 }
    let(:prerelease) { 'beta.1' }
    let(:build)      { 592 }

    it { expect(instance).to respond_to(:to_version) }

    context 'with a missing Major version' do
      it 'raises an error' do
        expect { instance.to_version }.to raise_error SleepingKingStudios::Tools::SemanticVersion::InvalidVersionError,
          'undefined constant for major version'
      end # it
    end # context

    context 'with a missing Minor version' do
      before(:each) do
        instance.const_set :MAJOR, major
      end # before each

      it 'raises an error' do
        expect { instance.to_version }.to raise_error SleepingKingStudios::Tools::SemanticVersion::InvalidVersionError,
          'undefined constant for minor version'
      end # it
    end # context

    context 'with a missing Patch version' do
      before(:each) do
        instance.const_set :MAJOR, major
        instance.const_set :MINOR, minor
      end # before each

      it 'raises an error' do
        expect { instance.to_version }.to raise_error SleepingKingStudios::Tools::SemanticVersion::InvalidVersionError,
          'undefined constant for patch version'
      end # it
    end # context

    context 'with Major, Minor, and Patch versions' do
      before(:each) do
        instance.const_set :MAJOR, major
        instance.const_set :MINOR, minor
        instance.const_set :PATCH, patch
      end # before each

      it 'returns the version string' do
        expect(instance.to_version).to be == "#{major}.#{minor}.#{patch}"
      end # it

      context 'with a Prerelease version' do
        before(:each) { instance.const_set :PRERELEASE, prerelease }

        it 'returns the version string' do
          expect(instance.to_version).to be == "#{major}.#{minor}.#{patch}-#{prerelease}"
        end # it

        context 'with a Build version' do
          before(:each) { instance.const_set :BUILD, build }

          it 'returns the version string' do
            expect(instance.to_version).to be == "#{major}.#{minor}.#{patch}-#{prerelease}+#{build}"
          end # it
        end # context
      end # context

      context 'with a Build version' do
        before(:each) { instance.const_set :BUILD, build }

        it 'returns the version string' do
          expect(instance.to_version).to be == "#{major}.#{minor}.#{patch}+#{build}"
        end # it
      end # context
    end # context
  end # describe
end # describe
