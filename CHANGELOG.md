# Changelog

### 0.8.0

Last minor release before 1.0.0.

This release adds a number of deprecations. All deprecated code will be removed
in version 1.0.0. Update dependent code accordingly.

- Removed deprecated SleepingKingStudios::Tools::SemanticVersion. This
  functionality is still available as
  SleepingKingStudios::Tools::Toolbox::SemanticVersion.

#### Tools

- Refactored all Tools modules to classes.
- Removed StringTools::PluralInflector. It's functionality is now handled by
  Toolbox::Inflector.
- Added support for deprecation strategy to CoreTools#deprecate.

#### Toolbelt

- Refactored Toolbelt to reference Tools instances rather than classes.
- Defined new abbreviated helpers #ary, #hsh, #int, #obj, #str.
- Defined new helpers #array_tools, #core_tools, #hash_tools, #integer_tools,
  #object_tools, #string_tools.
- Deprecated old abbreviated helpers #array, #core, #hash, #integer, #object,
  #string.

#### Toolbox

- Deprecate Toolbox::Configuration. Use a struct instead.
- Deprecate Toolbox::Delegator. Use the stdlib Forwardable module instead.
- Implement Toolbox::Inflector, which serves as a delegate for StringTools.

### 0.7.1

- Implement CoreTools#empty_binding.
- Implement HashTools#generate_binding.

### 0.7.0

#### Tools

- Support symbol arguments to StringTools methods.
- Implement StringTools#chain.
- Implement StringTools#indent.
- Implement StringTools#map_lines.

#### Toolbox

- Implement Toolbox::Configuration.

#### Misc.

- IntegerTools#pluralize now accepts 2..3 arguments, and will automatically generate the plural string using StringTools#pluralize if an explicit plural is not given.
- SleepingKingStudios::Tools::Toolbelt is now autoloaded from SleepingKingStudios::Tools.

### 0.6.0

- Implement HashTools#convert_keys_to_strings and #convert_keys_to_symbols.
- Implement ObjectTools#dig.
- Implement StringTools#singular? and #plural?.
- Implement Toolbelt::instance, #inspect, #to_s.
- Implement Toolbox::ConstantMap.
- Implement Toolbox::Mixin.
- Add support for Ruby 2.4.0.

### 0.5.0

- Implement CoreTools#require_each.
- Implement StringTools#camelize.
- Add an optional block argument to ArrayTools#humanize_list.

#### Toolbox

- Implement Delegator#delegate, Delegator#wrap_delegate.
- Refactor SemanticVersion to the Toolbox namespace. Accessing SemanticVersion as Tools::SemanticVersion is now deprecated, use Tools::Toolbox::SemanticVersion.

#### Identity Methods

- Implement a set of methods to classify objects by type: ArrayTools#array?, HashTools#hash?, IntegerTools#integer?, ObjectTools#object?, and StringTools#string?.

#### Mutability Methods

Implement #immutable? and #mutable? for ObjectTools, ArrayTools, and HashTools, which indicate whether or not a given object is mutable.

Implement #deep_freeze for ObjectTools, ArrayTools, and HashTools which recursively freezes the object and any children (array items, hash keys, and hash values).

## Previous Releases

### 0.4.0

#### CoreTools

Implement CoreTools#deprecate.

#### IntegerTools

Implement #pluralize.

#### StringTools

Implement #pluralize and #singularize. The previous behavior of #pluralize is deprecated; use IntegerTools#pluralize.

### 0.3.0

Implement ArrayTools#bisect and ArrayTools#splice.

#### StringTools

Implement #underscore.

### 0.2.0

Split EnumerableTools into ArrayTools and HashTools.

Implement ArrayTools#deep_dup, HashTools#deep_dup and ObjectTools#deep_dup.

### 0.1.3

Properly support both keywords and optional arguments in ObjectTools#apply.

### 0.1.2

Fix loading order issues when loading SemanticVersion in isolation.

### 0.1.1

Add configuration options to EnumerableTools#humanize_list.

### 0.1.0

Initial release.
