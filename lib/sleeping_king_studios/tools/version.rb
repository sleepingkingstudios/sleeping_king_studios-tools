# lib/sleeping_king_studios/tools/version.rb

require 'sleeping_king_studios/tools/semantic_version'

module SleepingKingStudios
  module Tools
    module Version
      extend SleepingKingStudios::Tools::SemanticVersion

      MAJOR = 0
      MINOR = 0
      PATCH = 1
    end # module

    VERSION = Version.to_gem_version
  end # module
end # module
