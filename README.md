# SleepingKingStudios::Tools [![Build Status](https://travis-ci.org/sleepingkingstudios/sleeping_king_studios-tools.svg?branch=master)](https://travis-ci.org/sleepingkingstudios/sleeping_king_studios-tools)

A library of utility services and concerns to expand the functionality of core classes without polluting the global namespace.

## Contribute

- https://github.com/sleepingkingstudios/sleeping_king_studios-tools

### A Note From The Developer

Hi, I'm Rob Smith, a Ruby Engineer and the developer of this library. I use these tools every day, but they're not just written for me. If you find this project helpful in your own work, or if you have any questions, suggestions or critiques, please feel free to get in touch! I can be reached on GitHub (see above, and feel encouraged to submit bug reports or merge requests there) or via email at `merlin@sleepingkingstudios.com`. I look forward to hearing from you!

## Tools

### Array Tools

    require 'sleeping_king_studios/tools/array_tools'

Tools for working with array-like enumerable objects.

#### `#bisect`

Separates the array into two arrays, the first containing all items in the original array that matches the provided block, and the second containing all items in the original array that do not match the provided block.

    original = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    selected, rejected = ArrayTools.bisect(original) { |item| item.even? }
    selected
    #=> [0, 2, 4, 6, 8]
    rejected
    #=> [1, 3, 5, 7, 9]

#### `#count_values`

Counts the number of times each value appears in the array, or if a block is given, calls the block with each item and counts the number of times each result appears.

    ArrayTools.count_values([1, 1, 1, 2, 2, 3])
    #=> { 1 => 3, 2 => 2, 3 => 1 }

    ArrayTools.count_values([1, 1, 1, 2, 2, 3]) { |i| i ** 2 }
    #=> { 1 => 3, 4 => 2, 9 => 1 }

    ArrayTools.count_values([1, 1, 1, 2, 2, 3], &:even?)
    #=> { false => 4, true => 2 }

#### `#deep_dup`

Creates a deep copy of the object by returning a new Array with deep copies of each array item. See also ObjectTools#deep_dup[#label-Object+Tools].

    ary = ['one', 'two', 'three']
    cpy = ArrayTools.deep_dup ary

    cpy << 'four'
    #=> ['one', 'two', 'three', 'four']
    ary
    #=> ['one', 'two', 'three']

    cpy.first.sub!(/on/, 'vu'); cpy
    #=> ['vun', 'two', 'three', 'four']
    ary
    #=> ['one', 'two', 'three']

#### `#humanize_list`

Accepts a list of values and returns a human-readable string of the values, with the format based on the number of items.

    # With One Item
    ArrayTools.humanize_list(['spam'])
    #=> 'spam'

    # With Two Items
    ArrayTools.humanize_list(['spam', 'eggs'])
    #=> 'spam and eggs'

    # With Three Or More Items
    ArrayTools.humanize_list(['spam', 'eggs', 'bacon', 'spam'])
    #=> 'spam, eggs, bacon, and spam'

#### `#splice`

Accepts an array, a start value, a number of items to delete, and zero or more items to insert at that index. Deletes the specified number of items, then inserts the given items at the index and returns the array of deleted items.

    # Deleting items from an Array
    values = %w(katana wakizashi tachi daito shoto)
    ArrayTools.splice values, 1, 2
    #=> ['wakizashi', 'tachi']
    values
    #=> ['katana', 'daito', 'shoto']

    # Inserting items into an Array
    values = %w(longsword broadsword claymore)
    ArrayTools.splice values, 1, 0, 'zweihänder'
    #=> []
    values
    #=> ['longsword', 'zweihänder', 'broadsword', 'claymore']

    # Inserting and deleting items
    values = %w(shortbow longbow crossbow)
    ArrayTools.splice values, 2, 1, 'arbalest', 'chu-ko-nu'
    #=> ['crossbow']
    values
    #=> ['shortbow', 'longbow', 'arbalest', 'chu-ko-nu']

### Hash Tools

Tools for working with array-like enumerable objects.

#### `#deep_dup`

Creates a deep copy of the object by returning a new Hash with deep copies of each key and value. See also ObjectTools#deep_dup[#label-Object+Tools].

    hsh = { :one => 'one', :two => 'two', :three => 'three' }
    cpy = HashTools.deep_dup hsh

    cpy.update :four => 'four'
    #=> { :one => 'one', :two => 'two', :three => 'three', :four => 'four' }
    hsh
    #=> { :one => 'one', :two => 'two', :three => 'three' }

    cpy[:one].sub!(/on/, 'vu'); cpy
    #=> { :one => 'vun', :two => 'two', :three => 'three', :four => 'four' }
    hsh
    #=> { :one => 'one', :two => 'two', :three => 'three' }

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

#### `#romanize`

Represents an integer between 1 and 4999 (inclusive) as a Roman numeral.

    IntegerTools.romanize(499)
    #=> 'CDXCIX'

### Object Tools

    require 'sleeping_king_studios/tools/object_tools'

Low-level tools for working with objects.

#### `#apply`

Takes a proc or lambda and invokes it with the given object as receiver, with any additional arguments or block provided.

    my_object = double('object', :to_s => 'A mock object')
    my_proc   = ->() { puts %{#{self.to_s} says "Greetings, programs!"} }

    ObjectTools.apply my_object, my_proc
    #=> Writes 'A mock object says "Greetings, programs!"' to STDOUT.

#### `#deep_dup`

Creates a deep copy of the object. If the object is an Array, returns a new Array with deep copies of each array item (see ArrayTools#deep_dup[#label-Array+Tools]). If the object is a Hash, returns a new Hash with deep copies of each hash key and value (see HashTools#deep_dup[#label-Hash+Tools]). Otherwise, returns Object#dup.

    data = {
      :songs = [
        {
          :name   => 'Welcome to the Jungle',
          :artist => "Guns N' Roses",
          :album  => 'Appetite for Destruction'
        }, # end hash
        {
          :name   => 'Hells Bells',
          :artist => 'AC/DC',
          :album  => 'Back in Black'
        }, # end hash
        {
          :name   => "Knockin' on Heaven's Door",
          :artist => 'Bob Dylan',
          :album  => 'Pat Garrett & Billy The Kid'
        } # end hash
      ] # end array
    } # end hash

    copy = ObjectTools.deep_dup data

    copy[:songs] << { :name => 'Sympathy for the Devil', :artist => 'The Rolling Stones', :album => 'Beggars Banquet' }
    data[:songs].count
    #=> 3

    copy[:songs][1][:name] = 'Shoot to Thrill'
    data[:songs][1]
    #=> { :name => 'Hells Bells', :artist => 'AC/DC', :album => 'Back in Black' }

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

#### '#underscore'

Converts a mixed-case string expression to a lowercase, underscore separated string, as per ActiveSupport::Inflector#underscore.

### Core Tools

Tools for working with an application or working environment.

#### '#deprecate'

Prints a deprecation warning.

    CoreTools.deprecate 'ObjectTools#old_method'
    #=> prints to stderr:

    [WARNING] ObjectTools#old_method is deprecated.
      called from /path/to/file.rb:4: in something_or_other

    CoreTools.deprecate 'ObjectTools#old_method', '0.1.0', :format => '%s was deprecated in version %s.'
    #=> prints to stderr:

    ObjectTools#old_method was deprecated in version 0.1.0.
      called from /path/to/file.rb:4: in something_or_other

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
