# SleepingKingStudios::Tools [![Build Status](https://travis-ci.org/sleepingkingstudios/sleeping_king_studios-tools.svg?branch=master)](https://travis-ci.org/sleepingkingstudios/sleeping_king_studios-tools)

A library of utility services and concerns to expand the functionality of core classes without polluting the global namespace.

## Contribute

- https://github.com/sleepingkingstudios/sleeping_king_studios-tools

### A Note From The Developer

Hi, I'm Rob Smith, a Ruby Engineer and the developer of this library. I use these tools every day, but they're not just written for me. If you find this project helpful in your own work, or if you have any questions, suggestions or critiques, please feel free to get in touch! I can be reached on GitHub (see above, and feel encouraged to submit bug reports or merge requests there) or via email at `merlin@sleepingkingstudios.com`. I look forward to hearing from you!

## Tools

### Enumerable Tools

    require 'sleeping_king_studios/tools/enumerable_tools'

Tools for working with enumerable objects, such as arrays and hashes.

#### `#count_values`

Counts the number of times each value appears in the enumerable object, or if a block is given, calls the block with each item and counts the number of times each result appears.

    EnumerableTools.count_values([1, 1, 1, 2, 2, 3])
    #=> { 1 => 3, 2 => 2, 3 => 1 }

    EnumerableTools.count_values([1, 1, 1, 2, 2, 3]) { |i| i ** 2 }
    #=> { 1 => 3, 4 => 2, 9 => 1 }

    EnumerableTools.count_values([1, 1, 1, 2, 2, 3], &:even?)
    #=> { false => 4, true => 2 }

#### `#humanize_list`

Accepts a list of values and returns a human-readable string of the values, with the format based on the number of items.

    # With One Item
    EnumerableTools.humanize_list(['spam'])
    #=> 'spam'

    # With Two Items
    EnumerableTools.humanize_list(['spam', 'eggs'])
    #=> 'spam and eggs'

    # With Three Or More Items
    EnumerableTools.humanize_list(['spam', 'eggs', 'bacon', 'spam'])
    #=> 'spam, eggs, bacon, and spam'

### Integer Tools

Tools for working with integers and fixnums.

#### `#count_digits`

Returns the number of digits in the given integer when represented in the specified base. Ignores minus sign for negative numbers.

    # With a positive number.
    IntegerTools.count_digits(31)
    #=> 2

    # With a negative number.
    IntegerTools.count_digits(-141)
    #=> 3

    # With a binary number.
    IntegerTools.count_digits(189, :base => 2)
    #=> 8

    # With a hexadecimal number.
    IntegerTools.count_digits(16724838, :base => 16)
    #=> 6

#### `#digits`

Decomposes the given integer into its digits when represented in the given base.

    # With a number in base 10.
    IntegerTools.digits(15926)
    #=> ['1', '5', '9', '2', '6']

    # With a binary number.
    IntegerTools.digits(189, :base => 2)
    #=> ['1', '0', '1', '1', '1', '1', '0', '1']

    # With a hexadecimal number.
    IntegerTools.digits(16724838)
    #=> ['f', 'f', '3', '3', '6', '6']

### Object Tools

    require 'sleeping_king_studios/tools/object_tools'

Low-level tools for working with objects.

#### `#apply`

Takes a proc or lambda and invokes it with the given object as receiver, with any additional arguments or block provided.

    my_object = double('object', :to_s => 'A mock object')
    my_proc   = ->() { puts %{#{self.to_s} says "Greetings, programs!"} }

    ObjectTools.apply my_object, my_proc
    #=> Writes 'A mock object says "Greetings, programs!"' to STDOUT.

#### `#eigenclass`, `#metaclass`

Returns the object's eigenclass.

    ObjectTools.eigenclass my_object
    #=> Shortcut for class << self; self; end.

### String Tools

    require 'sleeping_king_studios/tools/string_tools'

Tools for working with strings.

#### '#pluralize'

Returns the singular or the plural value, depending on the provided item count.

    StringTools.pluralize 4, 'light', 'lights'
    #=> 'lights'

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

    GEM_VERSION = Version.to_gem_version
    #=> '3.1.4.beta.1'

    VERSION = Version.to_version
    #=> '3.1.4-beta+1'

#### `#to_gem_version`

Concatenates the MAJOR, MINOR, and PATCH constant values with PRERELEASE and BUILD (if available) to generate a modified semantic version string compatible with Rubygems. The major, minor, patch, prerelease, and build values (if available) are separated by dots `.`.

#### `#to_version`

Concatenates the MAJOR, MINOR, and PATCH constant values with PRERELEASE and BUILD (if available) to generate a semantic version string. The major, minor, and patch values are separated by dots `.`, then the prerelease (if available) preceded by a hyphen `-`, and the build (if available) preceded by a plus sign `+`.
