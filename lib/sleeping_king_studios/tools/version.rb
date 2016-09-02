# lib/sleeping_king_studios/tools/version.rb

require 'sleeping_king_studios/tools/toolbox/semantic_version'

module SleepingKingStudios
  module Tools
    # SleepingKingStudios::Tools uses semantic versioning.
    #
    # @see http://semver.org
    module Version
      extend SleepingKingStudios::Tools::Toolbox::SemanticVersion

      private

      MAJOR      = 0
      MINOR      = 5
      PATCH      = 0
      PRERELEASE = :rc
      BUILD      = 0
    end # module

    VERSION = Version.to_gem_version
  end # module
end # module
