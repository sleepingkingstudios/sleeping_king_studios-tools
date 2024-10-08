# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox'

module SleepingKingStudios::Tools::Toolbox
  # Helper for generating semantic version strings with optional prerelease and
  # build parameters.
  #
  # @example
  #   module Version
  #     extend SleepingKingStudios::Tools::SemanticVersion
  #
  #     MAJOR = 3
  #     MINOR = 1
  #     PATCH = 4
  #     PRERELEASE = 'beta'
  #     BUILD = 1
  #   end # module
  #
  #   VERSION = Version.to_gem_version
  #
  # @see http://semver.org
  module SemanticVersion
    # Error class for handling missing constants in a version definition.
    class InvalidVersionError < StandardError; end

    # Concatenates the MAJOR, MINOR, and PATCH constant values with PRERELEASE
    # and BUILD (if available) to generate a modified semantic version string
    # compatible with Rubygems. The major, minor, patch, prerelease, and build
    # values (if available) are separated by dots (.).
    #
    # @example
    #   module Version
    #     extend SleepingKingStudios::Tools::SemanticVersion
    #
    #     MAJOR = 3
    #     MINOR = 1
    #     PATCH = 4
    #     PRERELEASE = 'beta'
    #     BUILD = 1
    #   end # module
    #
    #   VERSION = Version.to_gem_version
    #   #=> '3.1.4.beta.1'
    #
    # @return [String] The modified semantic version string.
    #
    # @raise InvalidVersionError If MAJOR, MINOR, or PATCH is undefined.
    def to_gem_version
      str = "#{const_fetch :MAJOR}.#{const_fetch :MINOR}.#{const_fetch :PATCH}"

      prerelease = const_fetch(:PRERELEASE, nil)
      str << ".#{prerelease}" unless prerelease.nil? || prerelease.empty?

      build = const_fetch(:BUILD, nil)
      str << ".#{build}" unless build.nil? || build.empty?

      str
    end

    # Concatenates the MAJOR, MINOR, and PATCH constant values with PRERELEASE
    # and BUILD (if available) to generate a semantic version string. The
    # major, minor, and patch values are separated by dots (.), then the
    # prerelease (if available) preceded by a hyphen (-), and the build (if
    # available) preceded by a plus (+).
    #
    # @example
    #   module Version
    #     extend SleepingKingStudios::Tools::SemanticVersion
    #
    #     MAJOR = 3
    #     MINOR = 1
    #     PATCH = 4
    #     PRERELEASE = 'beta'
    #     BUILD = 1
    #   end # module
    #
    #   VERSION = Version.to_version
    #   #=> '3.1.4-beta+1'
    #
    # @return [String] The semantic version string.
    #
    # @raise InvalidVersionError If MAJOR, MINOR, or PATCH is undefined.
    def to_version
      str = "#{const_fetch :MAJOR}.#{const_fetch :MINOR}.#{const_fetch :PATCH}"

      prerelease = const_fetch(:PRERELEASE, nil)
      str << "-#{prerelease}" unless prerelease.nil? || prerelease.empty?

      build = const_fetch(:BUILD, nil)
      str << "+#{build}" unless build.nil? || build.empty?

      str
    end

    private

    FETCH_DEFAULT = Object.new.freeze

    def const_fetch(name, default = FETCH_DEFAULT)
      return const_get(name).to_s if const_defined?(name)

      return nil unless default == FETCH_DEFAULT

      raise InvalidVersionError,
        "undefined constant for #{name.downcase} version"
    end
  end
end
