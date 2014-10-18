# SleepingKingStudios::Tools [![Build Status](https://travis-ci.org/sleepingkingstudios/sleeping_king_studios-tools.svg?branch=master)](https://travis-ci.org/sleepingkingstudios/sleeping_king_studios-tools)

A library of utility services and concerns to expand the functionality of core classes without polluting the global namespace.

## Contribute

- https://github.com/sleepingkingstudios/sleeping_king_studios-tools

### A Note From The Developer

Hi, I'm Rob Smith, a Ruby Engineer and the developer of this library. I use these tools every day, but they're not just written for me. If you find this project helpful in your own work, or if you have any questions, suggestions or critiques, please feel free to get in touch! I can be reached on GitHub (see above, and feel encouraged to submit bug reports or merge requests there) or via email at `merlin@sleepingkingstudios.com`. I look forward to hearing from you!

## Additional Features

### Semantic Version

    require 'sleeping_king_studios/tools/semantic_version'

Module mixin for using semantic versioning (see http://semver.org) with helper methods for generating strict and gem-compatible version strings.

    module Version
      extend SleepingKingStudios::Tools::SemanticVersion

      MAJOR = 3
      MINOR = 1
      PATCH = 4
      PRERELEASE = 'beta'
      BUILD = 1
    end # module

    VERSION = Version.to_version
    #=> '3.1.4-beta+1'

#### `#to_gem_version`

Concatenates the MAJOR, MINOR, and PATCH constant values with PRERELEASE and BUILD (if available) to generate a modified semantic version string compatible with Rubygems. The major, minor, patch, prerelease, and build values (if available) are separated by dots (.).

#### `#to_version`

Concatenates the MAJOR, MINOR, and PATCH constant values with PRERELEASE and BUILD (if available) to generate a semantic version string. The major, minor, and patch values are separated by dots (.), then the prerelease (if available) preceded by a hyphen (-), and the build (if available) preceded by a plus (+).
