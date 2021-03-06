# frozen_string_literal: true

require 'spec_helper'

require 'sleeping_king_studios/tools/toolbox/semantic_version'

RSpec.describe SleepingKingStudios::Tools::Toolbox::SemanticVersion do
  let(:instance) { Module.new.extend described_class }

  describe '#to_gem_version' do
    let(:major)      { 3 }
    let(:minor)      { 1 }
    let(:patch)      { 4 }
    let(:prerelease) { 'beta' }
    let(:build)      { 159 }

    it { expect(instance).to respond_to(:to_gem_version) }

    context 'with a missing Major version' do
      let(:error_message) { 'undefined constant for major version' }

      it 'should raise an error' do
        expect { instance.to_gem_version }
          .to raise_error described_class::InvalidVersionError, error_message
      end
    end

    context 'with a missing Minor version' do
      let(:error_message) { 'undefined constant for minor version' }

      before(:example) do
        instance.const_set :MAJOR, major
      end

      it 'should raise an error' do
        expect { instance.to_gem_version }
          .to raise_error described_class::InvalidVersionError, error_message
      end
    end

    context 'with a missing Patch version' do
      let(:error_message) { 'undefined constant for patch version' }

      before(:example) do
        instance.const_set :MAJOR, major
        instance.const_set :MINOR, minor
      end

      it 'should raise an error' do
        expect { instance.to_gem_version }
          .to raise_error described_class::InvalidVersionError, error_message
      end
    end

    context 'with Major, Minor, and Patch versions' do
      before(:example) do
        instance.const_set :MAJOR, major
        instance.const_set :MINOR, minor
        instance.const_set :PATCH, patch
      end

      it 'should return the version string' do
        expect(instance.to_gem_version).to be == "#{major}.#{minor}.#{patch}"
      end

      context 'with a Prerelease version' do
        before(:example) { instance.const_set :PRERELEASE, prerelease }

        it 'should return the version string' do
          expect(instance.to_gem_version)
            .to be == "#{major}.#{minor}.#{patch}.#{prerelease}"
        end

        context 'with a Build version' do
          before(:example) { instance.const_set :BUILD, build }

          it 'should return the version string' do
            expect(instance.to_gem_version)
              .to be == "#{major}.#{minor}.#{patch}.#{prerelease}.#{build}"
          end
        end
      end

      context 'with a Build version' do
        before(:example) { instance.const_set :BUILD, build }

        it 'should return the version string' do
          expect(instance.to_gem_version)
            .to be == "#{major}.#{minor}.#{patch}.#{build}"
        end
      end
    end
  end

  describe '#to_version' do
    let(:major)      { 3 }
    let(:minor)      { 1 }
    let(:patch)      { 4 }
    let(:prerelease) { 'beta.1' }
    let(:build)      { 592 }

    it { expect(instance).to respond_to(:to_version) }

    context 'with a missing Major version' do
      let(:error_message) { 'undefined constant for major version' }

      it 'should raise an error' do
        expect { instance.to_version }
          .to raise_error described_class::InvalidVersionError, error_message
      end
    end

    context 'with a missing Minor version' do
      let(:error_message) { 'undefined constant for minor version' }

      before(:example) do
        instance.const_set :MAJOR, major
      end

      it 'should raise an error' do
        expect { instance.to_version }
          .to raise_error described_class::InvalidVersionError, error_message
      end
    end

    context 'with a missing Patch version' do
      let(:error_message) { 'undefined constant for patch version' }

      before(:example) do
        instance.const_set :MAJOR, major
        instance.const_set :MINOR, minor
      end

      it 'should raise an error' do
        expect { instance.to_version }
          .to raise_error described_class::InvalidVersionError, error_message
      end
    end

    context 'with Major, Minor, and Patch versions' do
      before(:example) do
        instance.const_set :MAJOR, major
        instance.const_set :MINOR, minor
        instance.const_set :PATCH, patch
      end

      it 'should return the version string' do
        expect(instance.to_version).to be == "#{major}.#{minor}.#{patch}"
      end

      context 'with a Prerelease version' do
        before(:example) { instance.const_set :PRERELEASE, prerelease }

        it 'should return the version string' do
          expect(instance.to_version)
            .to be == "#{major}.#{minor}.#{patch}-#{prerelease}"
        end

        context 'with a Build version' do
          before(:example) { instance.const_set :BUILD, build }

          it 'should return the version string' do
            expect(instance.to_version)
              .to be == "#{major}.#{minor}.#{patch}-#{prerelease}+#{build}"
          end
        end
      end

      context 'with a Build version' do
        before(:example) { instance.const_set :BUILD, build }

        it 'should return the version string' do
          expect(instance.to_version)
            .to be == "#{major}.#{minor}.#{patch}+#{build}"
        end
      end
    end
  end
end
