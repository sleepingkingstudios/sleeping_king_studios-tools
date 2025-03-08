# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/semantic_version'

module SleepingKingStudios
  module Tools
    # SleepingKingStudios::Tools uses semantic versioning.
    #
    # @see http://semver.org
    module Version
      extend SleepingKingStudios::Tools::Toolbox::SemanticVersion

      # Major version.
      MAJOR = 1
      # Minor version.
      MINOR = 2
      # Patch version.
      PATCH = 0
      # Prerelease version.
      PRERELEASE = :rc
      # Build metadata.
      BUILD = 1
    end

    # The current version of the gem.
    VERSION = Version.to_gem_version
  end
end
