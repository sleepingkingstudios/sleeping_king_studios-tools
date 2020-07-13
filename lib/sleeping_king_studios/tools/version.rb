# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/semantic_version'

module SleepingKingStudios
  module Tools
    # SleepingKingStudios::Tools uses semantic versioning.
    #
    # @see http://semver.org
    module Version
      extend SleepingKingStudios::Tools::Toolbox::SemanticVersion

      MAJOR      = 0
      MINOR      = 7
      PATCH      = 1
      PRERELEASE = nil
      BUILD      = nil
    end

    VERSION = Version.to_gem_version
  end
end
