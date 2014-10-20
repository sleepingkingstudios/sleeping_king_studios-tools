# SleepingKingStudios::Tools [![Build Status](https://travis-ci.org/sleepingkingstudios/sleeping_king_studios-tools.svg?branch=master)](https://travis-ci.org/sleepingkingstudios/sleeping_king_studios-tools)

A library of utility services and concerns to expand the functionality of core classes without polluting the global namespace.

## Contribute

- https://github.com/sleepingkingstudios/sleeping_king_studios-tools

### A Note From The Developer

Hi, I'm Rob Smith, a Ruby Engineer and the developer of this library. I use these tools every day, but they're not just written for me. If you find this project helpful in your own work, or if you have any questions, suggestions or critiques, please feel free to get in touch! I can be reached on GitHub (see above, and feel encouraged to submit bug reports or merge requests there) or via email at `merlin@sleepingkingstudios.com`. I look forward to hearing from you!

## Tools

### Object Tools

    require 'sleeping_king_studios/tools/object_tools'

Low-level tools for working with objects.

#### `::apply`

Takes a proc or lambda and invokes it with the given object as receiver, with any additional arguments or block provided.

    my_object = double('object', :to_s => 'A mock object')
    my_proc   = ->() { puts %{#{self.to_s} says "Greetings, programs!"} }

    ObjectTools.apply my_object, my_proc
    #=> Writes 'A mock object says "Greetings, programs!"' to STDOUT.

#### `::eigenclass`, `::metaclass`

Returns the object's eigenclass.

    ObjectTools.eigenclass my_object
    #=> Shortcut for class << self; self; end.

### String Tools

    require 'sleeping_king_studios/tools/string_tools'

Tools for working with strings.

#### '::pluralize'



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

Concatenates the MAJOR, MINOR, and PATCH constant values with PRERELEASE and BUILD (if available) to generate a modified semantic version string compatible with Rubygems. The major, minor, patch, prerelease, and build values (if available) are separated by dots `.`.

#### `#to_version`

Concatenates the MAJOR, MINOR, and PATCH constant values with PRERELEASE and BUILD (if available) to generate a semantic version string. The major, minor, and patch values are separated by dots `.`, then the prerelease (if available) preceded by a hyphen `-`, and the build (if available) preceded by a plus sign `+`.
