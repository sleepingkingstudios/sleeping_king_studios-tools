# SleepingKingStudios::Tools [![Build Status](https://travis-ci.org/sleepingkingstudios/sleeping_king_studios-tools.svg?branch=master)](https://travis-ci.org/sleepingkingstudios/sleeping_king_studios-tools)

A library of utility services and concerns to expand the functionality of core classes without polluting the global namespace.

## About

SleepingKingStudios::Tools is tested against MRI Ruby 2.6 through 3.1.

### Documentation

Method and class documentation is available courtesy of RubyDoc.

Documentation is generated using [YARD](https://yardoc.org/), and can be generated locally using the `yard` gem.

### License

SleepingKingStudios::Tools is released under the [MIT License](https://opensource.org/licenses/MIT).

### Contribute

The canonical repository for this gem is on [GitHub](https://github.com/sleepingkingstudios/sleeping_king_studios-tasks). Community contributions are welcome - please feel free to fork or submit issues, bug reports or pull requests.

### Code of Conduct

Please note that the `SleepingKingStudios::Tools` project is released with a [Contributor Code of Conduct](https://github.com/sleepingkingstudios/sleeping_king_studios-tools/blob/master/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

## Tools

### Toolbelt

The tools can be accessed in a convenient form using the Toolbelt class.

```ruby
require 'sleeping_king_studios/tools'

tools = ::SleepingKingStudios::Tools::Toolbelt.instance

tools.ary.humanize_list 'one', 'two', 'three'
#=> calls ArrayTools#humanize_list

tools.core.deprecate 'my_method'
#=> calls CoreTools#deprecate

tools.str.underscore 'MyModuleName'
#=> calls StringTools#underscore
```

### Array Tools

    require 'sleeping_king_studios/tools/array_tools'

Tools for working with array-like enumerable objects.

#### `#array?`

Returns true if the object is or appears to be an Array.

    ArrayTools.array?(nil)
    #=> false
    ArrayTools.array?([])
    #=> true
    ArrayTools.array?({})
    #=> false

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

#### `#deep_freeze`

Freezes the array and performs a deep freeze on each array item. See also ObjectTools#deep_freeze[#label-Object+Tools].

    ary = ['one', 'two', 'three']
    ArrayTools.deep_freeze ary

    ary.frozen?
    #=> true
    ary.first.frozen?
    #=> true

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

    # With A Block
    ArrayTools.humanize_list(['bronze', 'silver', 'gold'], { |str| str.capitalize })
    #=> 'Bronze, Silver, and Gold'

#### `#immutable?`

Returns true if the array is immutable, i.e. the array is frozen and each array item is immutable.

    ArrayTools.immutable?([1, 2, 3])
    #=> false

    ArrayTools.immutable?([1, 2, 3].freeze)
    #=> true

    ArrayTools.immutable?(['ichi', 'ni', 'san'])
    #=> false

    ArrayTools.immutable?(['ichi', 'ni', 'san'].freeze)
    #=> false

    ArrayTools.immutable?(['ichi'.freeze, 'ni'.freeze, 'san'.freeze].freeze)
    #=> true

#### `#mutable?`

Returns true if the array is mutable (see `#immutable?`, above).

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

### Assertions

Tools for validating the current application state.

#### `#assert`

Raises an exception unless the given block returns a truthy value.

```ruby
Assertions.assert { true == false }
#=> raises an AssertionError with message 'block returned a falsy value'

Assertions.assert { true == true }
#=> does not raise an exception
```

It accepts the following options:

- `error_class:` The class of exception to raise. Defaults to `SleepingKingStudios::Tools::Assertions::AssertionError`.
- `message`: The error message to display.

#### `#assert_class`

Raises an exception unless the given value is a Class.

```ruby
Assertions.assert_class(Object.new)
#=> raises an AssertionError with message 'value is not a class'

Assertions.assert_class(String)
#=> does not raise an exception
```

It accepts the following options:

- `as:` A short descriptor of the given value. Defaults to `"value"`.
- `error_class:` The class of exception to raise. Defaults to `SleepingKingStudios::Tools::Assertions::AssertionError`.
- `message`: The error message to display.

#### `#assert_instance_of`

Raises an exception unless the given value is an instance of the expected Class or Module.

```ruby
Assertions.assert_instance_of(:foo, expected: String)
#=> raises an AssertionError with message 'value is not an instance of String'

Assertions.assert_instance_of('foo', expected: String)
#=> does not raise an exception
```

It accepts the following options:

- `as:` A short descriptor of the given value. Defaults to `"value"`.
- `error_class:` The class of exception to raise. Defaults to `SleepingKingStudios::Tools::Assertions::AssertionError`.
- `message`: The error message to display.

#### `#assert_matches`

Raises an exception unless the given value matches the expected value using case equality (`#===`).


```ruby
Assertions.assert_matches('bar', expected: /foo/)
#=> raises an AssertionError with message 'value does not match the pattern /foo/'

Assertions.assert_matches('foo', expected: /foo/)
#=> does not raise an exception
```

It accepts the following options:

- `as:` A short descriptor of the given value. Defaults to `"value"`.
- `error_class:` The class of exception to raise. Defaults to `SleepingKingStudios::Tools::Assertions::AssertionError`.
- `message`: The error message to display.

#### `#assert_name`

Raises an exception unless the given value is non-empty a String or Symbol.

```ruby
Assertions.assert_name(nil)
#=> raises an AssertionError with message "value can't be blank"

Assertions.assert_name(Object.new)
#=> raises an AssertionError with message 'value is not a String or a Symbol'

Assertions.assert_name('')
#=> raises an AssertionError with message "value can't be blank"

Assertions.assert_name('foo')
#=> does not raise an exception

Assertions.assert_name(:bar)
#=> does not raise an exception
```

It accepts the following options:

- `as:` A short descriptor of the given value. Defaults to `"value"`.
- `error_class:` The class of exception to raise. Defaults to `SleepingKingStudios::Tools::Assertions::AssertionError`.
- `message`: The error message to display.

#### `#validate`

Raises an `ArgumentError` unless the given block returns a truthy value.

```ruby
Assertions.validate { true == false }
#=> raises an ArgumentError with message 'block returned a falsy value'

Assertions.validate { true == true }
#=> does not raise an exception
```

It accepts the following options:

- `message`: The error message to display.

#### `#validate_class`

Raises an `ArgumentError` unless the given value is a Class.

```ruby
Assertions.validate_class(Object.new)
#=> raises an ArgumentError with message 'value is not a class'

Assertions.validate_class(String)
#=> does not raise an exception
```

It accepts the following options:

- `as:` A short descriptor of the given value. Defaults to `"value"`.
- `message`: The error message to display.

#### `#validate_instance_of`

Raises an `ArgumentError` unless the given value is an instance of the expected Class or Module.

```ruby
Assertions.validate_instance_of(:foo, expected: String)
#=> raises an AssertionError with message 'value is not an instance of String'

Assertions.validate_instance_of('foo', expected: String)
#=> does not raise an exception
```

It accepts the following options:

- `as:` A short descriptor of the given value. Defaults to `"value"`.
- `message`: The error message to display.

#### `#validate_matches`

Raises an `ArgumentError` unless the given value matches the expected value using case equality (`#===`).


```ruby
Assertions.validate_matches('bar', expected: /foo/)
#=> raises an ArgumentError with message 'value does not match the pattern /foo/'

Assertions.validate_matches('foo', expected: /foo/)
#=> does not raise an exception
```

It accepts the following options:

- `as:` A short descriptor of the given value. Defaults to `"value"`.
- `message`: The error message to display.

#### `#validate_name`

Raises an `ArgumentError` unless the given value is non-empty a String or Symbol.

```ruby
Assertions.validate_name(nil)
#=> raises an ArgumentError with message "value can't be blank"

Assertions.validate_name(Object.new)
#=> raises an AssertionError with message 'value is not a String or a Symbol'

Assertions.validate_name('')
#=> raises an ArgumentError with message "value can't be blank"

Assertions.validate_name('foo')
#=> does not raise an exception

Assertions.validate_name(:bar)
#=> does not raise an exception
```

It accepts the following options:

- `as:` A short descriptor of the given value. Defaults to `"value"`.
- `message`: The error message to display.

### Core Tools

Tools for working with an application or working environment.

#### `#deprecate`

Prints a deprecation warning.

```ruby
CoreTools.deprecate 'ObjectTools#old_method'
#=> prints to stderr:
#
#   [WARNING] ObjectTools#old_method is deprecated.
#       called from /path/to/file.rb:4: in something_or_other
```

You can also specify an additional message to display:

```ruby
CoreTools.deprecate 'ObjectTools#old_method',
  'Use #new_method instead.'
#=> prints to stderr:
#
#   [WARNING] ObjectTools#old_method is deprecated. Use #new_method instead.
#     called from /path/to/file.rb:4: in something_or_other
```

You can specify a custom format for the deprecation message:

```ruby
CoreTools.deprecate 'ObjectTools#old_method',
  '0.1.0',
  format: '%s was deprecated in version %s.'
#=> prints to stderr:
#
#   ObjectTools#old_method was deprecated in version 0.1.0.
#     called from /path/to/file.rb:4: in something_or_other
```

By default, `#deprecate` will print the last 3 lines of the caller, excluding
any lines from `Forwardable` and from `SleepingKingStudios::Tools` itself. To
print a different number of lines, pass a custom `deprecation_caller_depth` parameter to `CoreTools.new` or set the `DEPRECATION_CALLER_DEPTH` environment variable.

#### `#empty_binding`

Generates an empty Binding object. Note that this binding object still has
access to Object methods and constants - it is **not** eval-safe.

    CoreTools.empty_binding
    #=> Binding

#### `#require_each`

Takes a file pattern or a list of file names and requires each file.

    CoreTools.require_each '/path/to/one', '/path/to/two', '/path/to/three'
    #=> Requires each file.

    CoreTools.require_each '/path/to/directory/**/*.rb'
    #=> Requires each file matching the pattern.

### Hash Tools

Tools for working with array-like enumerable objects.

#### `#convert_keys_to_strings`

Creates a copy of the hash with the keys converted to strings, including keys of nested hashes and hashes inside nested arrays.

    hsh = { :one => 1, :two => 2, :three => 3 }
    cpy = HashTools.convert_keys_to_strings(hsh)
    #=> { 'one' => 1, 'two' => 2, 'three' => 3 }
    hsh
    #=> { :one => 1, :two => 2, :three => 3 }

    hsh = { :odd => { :one => 1, :three => 3 }, :even => { :two => 2, :four => 4 } }
    cpy = HashTools.convert_keys_to_strings(hsh)
    #=> { 'odd' => { 'one' => 1, 'three' => 3 }, 'even' => { 'two' => 2, 'four' => 4 } }
    hsh
    #=> { :odd => { :one => 1, :three => 3 }, :even => { :two => 2, :four => 4 } }

#### `#convert_keys_to_symbols`

Creates a copy of the hash with the keys converted to symbols, including keys of nested hashes and hashes inside nested arrays.

    hsh = { 'one' => 1, 'two' => 2, 'three' => 3 }
    cpy = HashTools.convert_keys_to_strings(hsh)
    #=> { :one => 1, :two => 2, :three => 3 }
    hsh
    #=> { 'one' => 1, 'two' => 2, 'three' => 3 }

    hsh = { 'odd' => { 'one' => 1, 'three' => 3 }, 'even' => { 'two' => 2, 'four' => 4 } }
    cpy = HashTools.convert_keys_to_strings(hsh)
    #=> { :odd => { :one => 1, :three => 3 }, :even => { :two => 2, :four => 4 } }
    hsh
    #=> { 'odd' => { 'one' => 1, 'three' => 3 }, 'even' => { 'two' => 2, 'four' => 4 } }

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

#### `#deep_freeze`

Freezes the hash and performs a deep freeze on each hash key and value.

    hsh = { :one => 'one', :two => 'two', :three => 'three' }
    HashTools.deep_freeze hsh

    hsh.frozen?
    #=> true
    hsh[:one].frozen?
    #=> true

#### `#generate_binding`

Generates a Binding object, with the hash converted to local variables in the
binding.

    hsh     = { :one => 'one', :two => 'two', :three => 'three' }
    binding = HashTools.generate_binding(hsh)
    #=> Binding

    binding.local_variable_defined?(:one)
    #=> true
    binding.local_variable_get(:one)
    #=> 'one'
    binding.eval('one')
    #=> 'one'

#### `#hash?`

Returns true if the object is or appears to be a Hash.

    HashTools.hash?(nil)
    #=> false
    HashTools.hash?([])
    #=> false
    HashTools.hash?({})
    #=> true

#### `#immutable?`

Returns true if the hash is immutable, i.e. if the hash is frozen and each hash key and hash value are immutable.

    HashTools.immutable?({ :id => 0, :title => 'The Ramayana' })
    #=> false

    HashTools.immutable?({ :id => 0, :title => 'The Ramayana' }.freeze)
    #=> false

    HashTools.immutable?({ :id => 0, :title => 'The Ramayana'.freeze }.freeze)
    #=> true

#### `#mutable?`

Returns true if the hash is mutable (see `#immutable?`, above).

#### `#stringify_keys`

See HashTools#convert_keys_to_strings[#label-Hash+Tools]

#### `#symbolize_keys`

See HashTools#convert_keys_to_symbols[#label-Hash+Tools]

### Integer Tools

Tools for working with integers.

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

#### `#integer?`

Returns true if the object is an Integer.

    IntegerTools.integer?(nil)
    #=> false
    IntegerTools.integer?([])
    #=> false
    IntegerTools.integer?({})
    #=> false
    IntegerTools.integer?(1)
    #=> true

#### `#pluralize`

Returns the singular or the plural value, depending on the provided item count. Can be given an explicit plural argument, or will delegate to StringTools#pluralize.

    IntegerTools.pluralize 4, 'light'
    #=> 'lights'

    IntegerTools.pluralize 3, 'cow', 'kine'
    #=> 'kine'

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
        },
        {
          :name   => 'Hells Bells',
          :artist => 'AC/DC',
          :album  => 'Back in Black'
        },
        {
          :name   => "Knockin' on Heaven's Door",
          :artist => 'Bob Dylan',
          :album  => 'Pat Garrett & Billy The Kid'
        }
      ]
    }

    copy = ObjectTools.deep_dup data

    copy[:songs] << { :name => 'Sympathy for the Devil', :artist => 'The Rolling Stones', :album => 'Beggars Banquet' }
    data[:songs].count
    #=> 3

    copy[:songs][1][:name] = 'Shoot to Thrill'
    data[:songs][1]
    #=> { :name => 'Hells Bells', :artist => 'AC/DC', :album => 'Back in Black' }

#### `#deep_freeze`

Performs a deep freeze of the object. If the object is an Array, freezes the array and performs a deep freeze on each array item (see ArrayTools#deep_dup[#label-Array+Tools]). If the object is a hash, freezes the hash and performs a deep freeze on each hash key and value (see HashTools#deep_dup[#label-Hash+Tools]). Otherwise, calls Object#freeze unless the object is already immutable.

    data = {
      :songs = [
        {
          :name   => 'Welcome to the Jungle',
          :artist => "Guns N' Roses",
          :album  => 'Appetite for Destruction'
        },
        {
          :name   => 'Hells Bells',
          :artist => 'AC/DC',
          :album  => 'Back in Black'
        },
        {
          :name   => "Knockin' on Heaven's Door",
          :artist => 'Bob Dylan',
          :album  => 'Pat Garrett & Billy The Kid'
        }
      ]
    }
    ObjectTools.deep_freeze(data)

    data.frozen?
    #=> true
    data[:songs].frozen?
    #=> true
    data[:songs][0].frozen?
    #=> true
    data[:songs][0].name.frozen?
    #=> true

#### `#dig`

Accesses deeply nested attributes by calling the first named method on the given object, and each subsequent method on the result of the previous method call. If the object does not respond to the method name, nil is returned instead of calling the method.

    ObjectTools.dig my_object, :first_method, :second_method, :third_method
    #=> my_object.first_method.second_method.third_method

#### `#eigenclass`, `#metaclass`

Returns the object's eigenclass.

    ObjectTools.eigenclass my_object
    #=> Shortcut for class << self; self; end.

#### `#immutable?`

Returns true if the object is immutable. Values of nil, false, and true are always immutable, as are instances of Numeric and Symbol. Arrays are immutable if the array is frozen and each array item is immutable. Hashes are immutable if the hash is frozen and each hash key and hash value are immutable. Otherwise, objects are immutable if they are frozen.

    ObjectTools.immutable?(nil)
    #=> true

    ObjectTools.immutable?(false)
    #=> true

    ObjectTools.immutable?(0)
    #=> true

    ObjectTools.immutable?(:hello)
    #=> true

    ObjectTools.immutable?("Greetings, programs!")
    #=> false

    ObjectTools.immutable?([1, 2, 3])
    #=> false

    ObjectTools.immutable?([1, 2, 3].freeze)
    #=> false

#### `#mutable?`

Returns true if the object is mutable (see `#immutable?`, above).

#### `#object?`

Returns true if the object is an Object.

    ObjectTools.object?(nil)
    #=> true
    ObjectTools.object?([])
    #=> true
    ObjectTools.object?({})
    #=> true
    ObjectTools.object?(1)
    #=> true
    ObjectTools.object?(BasicObject.new)
    #=> false

#### `#try`

As #send, but returns nil if the object does not respond to the method.

    ObjectTools.try(%w(ichi ni san), :count)
    #=> 3
    ObjectTools.try(nil, :count)
    #=> nil

### String Tools

    require 'sleeping_king_studios/tools/string_tools'

Tools for working with strings.

#### `#camelize`

Converts a lowercase, underscore separated string to a mixed-case string expression, as per ActiveSupport::Inflector#camelize.

    StringTools#camelize 'valhalla'
    #=> 'Valhalla'

    StringTools#camelize 'muspelheimr_and_niflheimr'
    #=> 'MuspelheimrAndNiflheimr'

#### `#chain`

Performs multiple string tools operations in sequence, starting with the given string and passing the result of each operation to the next.

    # Equivalent to `StringTools.underscore(StringTools.pluralize str)`.
    StringTools#chain 'ArchivedPeriodical', :underscore, :pluralize
    # => 'archived_periodicals'

Adds the specified number of spaces to the start of each line of the string. Defaults to 2 spaces.

    string = 'The Hobbit'
    StringTools.indent(string)
    #=> '  The Hobbit'

    titles = [
      "The Fellowship of the Ring",
      "The Two Towers",
      "The Return of the King"
    ]
    string = titles.join "\n"
    StringTools.indent(string, 4)
    #=> "    The Fellowship of the Ring\n"\
        "    The Two Towers\n"\
        "    The Return of the King"

#### `#map_lines`

Yields each line of the string to the provided block and combines the results into a new multiline string.

    string = 'The Hobbit'
    StringTools.map_lines(string) { |line| "  #{line}" }
    #=> '- The Hobbit'

    titles = [
      "The Fellowship of the Ring",
      "The Two Towers",
      "The Return of the King"
    ]
    string = titles.join "\n"
    StringTools.map_lines(string) { |line, index| "#{index}. #{line}" }
    #=> "0. The Fellowship of the Ring\n"\
        "1. The Two Towers\n"\
        "2. The Return of the King"

#### `#plural?`

Returns true if the word is in plural form, and returns false otherwise. A word is in plural form if and only if calling `#pluralize` (see below) on the word returns the word without modification.

    StringTools.plural? 'light'
    #=> false

    StringTools.plural? 'lights'
    #=> true

#### `#pluralize`

Takes a word in singular form and returns the plural form, based on the defined rules and known irregular/uncountable words.

First, checks if the word is known to be uncountable (see #define_uncountable_word). Then, checks if the word is known to be irregular (see #define_irregular_word). Finally, iterates through the defined plural rules from most recently defined to first defined (see #define_plural_rule).

    StringTools.pluralize 'light'
    #=> 'lights'

**Important Note:** The defined rules and exceptions are deliberately basic. Each application is responsible for defining its own pluralization rules using this framework.

Additional rules can be defined using the following methods:

    # Define a plural rule.
    StringTools.define_plural_rule(/lf$/, 'lves')
    StringTools.pluralize 'elf'
    #=> 'elves'

    # Define an irregular word.
    StringTools.define_irregular_word('goose', 'geese')
    StringTools.pluralize 'goose'
    #=> 'geese'

    # Define an uncountable word.
    StringTools.define_uncountable_word('series')
    StringTools.pluralize 'series'
    # => 'series'

#### `#singular?`

Returns true if the word is in singular form, and returns false otherwise. A word is in singular form if and only if calling `#singularize` (see below) on the word returns the word without modification.

    StringTools.singular? 'light'
    #=> true

    StringTools.singular? 'lights'
    #=> false

#### `#singularize`

Takes a word in plural form and returns the singular form, based on the defined rules and known irregular/uncountable words.

    StringTools.singularize 'lights'
    #=> 'light'

`StringTools#singularize` uses the same rules for irregular and uncountable words as `#pluralize`. Additional rules can be defined using the following method:

    StringTools.define_singular_rule(/lves$/, 'lf')
    StringTools.singularize 'elves'
    #=> 'elf'

#### `#string?`

Returns true if the object is a String.

    StringTools.string?(nil)
    #=> false
    StringTools.string?([])
    #=> false
    StringTools.string?('Greetings, programs!')
    #=> true
    StringTools.string?(:greetings_starfighter)
    #=> false

#### `#underscore`

Converts a mixed-case string expression to a lowercase, underscore separated string, as per ActiveSupport::Inflector#underscore.

    StringTools#underscore 'Bifrost'
    #=> 'bifrost'

    StringTools#underscore 'FenrisWolf'
    #=> 'fenris_wolf'

## Toolbox

Common objects or patterns that are useful across projects but are larger than or do not fit the functional paradigm of the tools.* pattern.

### ConstantMap

    require 'sleeping_king_studios/tools/toolbox/constant_map'

Provides an enumerable interface for defining a group of constants.

    UserRoles = ConstantMap.new(
      {
        GUEST: 'guest',
        USER:  'user',
        ADMIN: 'admin'
      }'
    )

    UserRoles::GUEST
    #=> 'guest'

    UserRoles.user
    #=> 'user'

    UserRoles.all
    #=> { :GUEST => 'guest', :USER => 'user', :ADMIN => 'admin' }

ConstantMap includes `Enumerable`, with `#each` yielding the name and value of each defined constant. It also defines the following additional methods:

#### `#each_key`

Yields each defined constant name, similar to `Hash#each_key`.

#### `#each_value`

Yields each defined constant value, similar to `Hash#each_value`.

#### `#keys`

Returns an array containing the names of the defined constants, similar to `Hash#keys`.

#### `#to_h`

Also `#all`. Returns a Hash representation of the constants.

#### `#values`

Returns an array containing the values of the defined constants, similar to `Hash#values`.

### Mixin

    require 'sleeping_king_studios/tools/toolbox/mixin'

Implements module-based inheritance for both instance- and class-level methods, similar to the (in)famous ActiveSupport::Concern. When a Mixin is included into a class, the class will be extended with any methods defined in the special ClassMethods module, even if the Mixin is being included indirectly via one or more intermediary Mixins.

    Widget = Struct.new(:widget_type)

    module Widgets
      extend SleepingKingStudios::Tools::Toolbox::Mixin

      module ClassMethods
        def widget_types
          %w(gadget doohickey thingamabob)
        end # class method widget_types
      end # module

      def widget? widget_type
        self.class.widget_types.include?(widget_type)
      end # method widget?
    end # module

    module WidgetBuilding
      extend SleepingKingStudios::Tools::Toolbox::Mixin

      include Widgets

      def build_widget widget_type
        raise ArgumentError, 'not a widget', caller unless widget?(widget_type)

        Widget.new(widget_type)
      end # method build_widget
    end # module

    class WidgetFactory
      include WidgetBuilding
    end # class

    factory = WidgetFactory.new

    factory.build_widget('gadget')
    #=> Widget

    WidgetFactory.widget_types
    #=> ['gadget', 'doohickey', 'thingamabob']

### Semantic Version

    require 'sleeping_king_studios/tools/toolbox/semantic_version'

Module mixin for using semantic versioning (see http://semver.org) with helper methods for generating strict and gem-compatible version strings.

    module Version
      extend SleepingKingStudios::Tools::Toolbox::SemanticVersion

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
