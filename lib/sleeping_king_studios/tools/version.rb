# lib/sleeping_king_studios/tools/version.rb

require 'sleeping_king_studios/tools/semantic_version'

module SleepingKingStudios
  module Tools
    # SleepingKingStudios::Tools uses semantic versioning.
    #
    # @see http://semver.org
    module Version
      extend SleepingKingStudios::Tools::SemanticVersion

      private

      MAJOR = 0
      MINOR = 2
      PATCH = 0
    end # module

    VERSION = Version.to_gem_version
  end # module
end # module
