# Changelog

## 1.3.0

### Tools

Tools objects now define a circular `#toolbelt` reference.

Added the following methods to `SleepingKingStudios::Tools::Assertions`.

- `#assert_exclusion`
- `#assert_inclusion`
- `#assert_inherits_from` (aliased as `#assert_subclass`)
- `#validate_exclusion`
- `#validate_inclusion`
- `#validate_inherits_from` (aliased as `#validate_subclass`)

Updated `Assertions#assert_instance_of` to accept a `Module` as the expected value.

Updated `CoreTools` deprecations:

- Now supports passing `deprecate(message, caller:)` to override displayed backtrace.
- Initializing `CoreTools` with an invalid deprecation strategy now raises an `ArgumentError`.

Added `#[]` support to `ObjectTools#dig`, allowing access through indexed data structures.

#### Messages

Added `Messages` tool, which allows generating user-readable messages.

- Added `Messages::Registry` for defining scoped message strategies.
- Added `Messages::Strategy` and subclasses `FileStrategy` and `HashStrategy`.

### Toolbelt

Implemented `Toolbelt.global`, a thread-safe singleton instance with default configuration.

- Calling `Toolbelt.instance` now returns the singleton.

Tools objects are now defined lazily.

### Toolbox

Added keyword support to `ConstantMap.new`.

- The value returned by `ConstantMap#to_h` is now immutable.

Corrected the scope of `Mixin#included` and `Mixin#prepended` to be `private`.

#### Initializer

Added `Toolbox::Initializer`, used for defining a one-time initialization for a library or project.

## 1.2.1

Added support for Ruby 4.0.

## 1.2.0

Ended support for Ruby 2.7 and 3.0.

Added live documentation support.

### Inflector

Fixed behavior of `Inflector#camelize` for certain mixed-case strings.

### Tools

Added the following methods to `SleepingKingStudios::Tools::Assertions`.

- `#assert_blank`
- `#assert_group`
- `#assert_nil`
- `#assert_not_nil`
- `#assert_presence`
- `#error_message_for`
- `#validate_blank`
- `#validate_group`
- `#validate_nil`
- `#validate_not_nil`
- `#validate_presence`

Implemented `SleepingKingStudios::Tools::Assertions::Aggregator`.

### Toolbox

Added `.prepended` support to `SleepingKingStudios::Tools::Toolbox::Mixin`.

## 1.1.1

Fixed support for keyword parameters in `ObjectTools#apply` in Ruby 3.2.

## 1.1.0

Files in the `Toolbox` are now autoloaded.

### Tools

Implemented `SleepingKingStudios::Tools::Assertions` with the following methods:

- `#assert`
- `#assert_boolean`
- `#assert_class`
- `#assert_instance_of`
- `#assert_matches`
- `#assert_name`

Each method raises an exception if its condition is not met. `Assertions` also defines equivalent `#validate` methods, which always raise an `ArgumentError`.

Added :deprecation_caller_depth option to CoreTools. When calling #deprecate with the default strategy of 'warn', will print the specified number of lines from the caller. The default value is 3.

### Toolbelt

- Added `#assertions` to Toolbelt.

### Toolbox

Implemented `SleepingKingStudios::Tools::Toolbox::Subclass`, which implements partial application for constructor parameters.

## 1.0.2

Updated gem metadata.

## 1.0.1

Added a missing `require 'set'` to Toolbox::Inflector::Rules.

## 1.0.0

Removed all deprecated code from pre-1.0 releases.

### Toolbox

Added some Hash-like methods to ConstantMap - `#each_key`, `#each_value`,
`#keys`, `#to_h`, and `#values`.

## 0.8.0

Last minor release before 1.0.0.

This release adds a number of deprecations. All deprecated code will be removed
in version 1.0.0. Update dependent code accordingly.

- Removed deprecated SleepingKingStudios::Tools::SemanticVersion. This
  functionality is still available as
  SleepingKingStudios::Tools::Toolbox::SemanticVersion.

### Tools

- Refactored all Tools modules to classes.
- Removed StringTools::PluralInflector. It's functionality is now handled by
  Toolbox::Inflector.
- Added support for deprecation strategy to CoreTools#deprecate.

### Toolbelt

- Refactored Toolbelt to reference Tools instances rather than classes.
- Defined new abbreviated helpers #ary, #hsh, #int, #obj, #str.
- Defined new helpers #array_tools, #core_tools, #hash_tools, #integer_tools,
  #object_tools, #string_tools.
- Deprecated old abbreviated helpers #array, #core, #hash, #integer, #object,
  #string.

### Toolbox

- Deprecate Toolbox::Configuration. Use a struct instead.
- Deprecate Toolbox::Delegator. Use the stdlib Forwardable module instead.
- Implement Toolbox::Inflector, which serves as a delegate for StringTools.

## 0.7.1

- Implement CoreTools#empty_binding.
- Implement HashTools#generate_binding.

## 0.7.0

### Tools

- Support symbol arguments to StringTools methods.
- Implement StringTools#chain.
- Implement StringTools#indent.
- Implement StringTools#map_lines.

### Toolbox

- Implement Toolbox::Configuration.

### Misc.

- IntegerTools#pluralize now accepts 2..3 arguments, and will automatically generate the plural string using StringTools#pluralize if an explicit plural is not given.
- SleepingKingStudios::Tools::Toolbelt is now autoloaded from SleepingKingStudios::Tools.

## 0.6.0

- Implement HashTools#convert_keys_to_strings and #convert_keys_to_symbols.
- Implement ObjectTools#dig.
- Implement StringTools#singular? and #plural?.
- Implement Toolbelt::instance, #inspect, #to_s.
- Implement Toolbox::ConstantMap.
- Implement Toolbox::Mixin.
- Add support for Ruby 2.4.0.

## 0.5.0

- Implement CoreTools#require_each.
- Implement StringTools#camelize.
- Add an optional block argument to ArrayTools#humanize_list.

### Toolbox

- Implement Delegator#delegate, Delegator#wrap_delegate.
- Refactor SemanticVersion to the Toolbox namespace. Accessing SemanticVersion as Tools::SemanticVersion is now deprecated, use Tools::Toolbox::SemanticVersion.

### Identity Methods

- Implement a set of methods to classify objects by type: ArrayTools#array?, HashTools#hash?, IntegerTools#integer?, ObjectTools#object?, and StringTools#string?.

### Mutability Methods

Implement #immutable? and #mutable? for ObjectTools, ArrayTools, and HashTools, which indicate whether or not a given object is mutable.

Implement #deep_freeze for ObjectTools, ArrayTools, and HashTools which recursively freezes the object and any children (array items, hash keys, and hash values).

## 0.4.0

### CoreTools

Implement CoreTools#deprecate.

### IntegerTools

Implement #pluralize.

### StringTools

Implement #pluralize and #singularize. The previous behavior of #pluralize is deprecated; use IntegerTools#pluralize.

## 0.3.0

Implement ArrayTools#bisect and ArrayTools#splice.

### StringTools

Implement #underscore.

## 0.2.0

Split EnumerableTools into ArrayTools and HashTools.

Implement ArrayTools#deep_dup, HashTools#deep_dup and ObjectTools#deep_dup.

## 0.1.3

Properly support both keywords and optional arguments in ObjectTools#apply.

## 0.1.2

Fix loading order issues when loading SemanticVersion in isolation.

## 0.1.1

Add configuration options to EnumerableTools#humanize_list.

## 0.1.0

Initial release.
