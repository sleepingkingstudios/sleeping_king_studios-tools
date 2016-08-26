# Changelog

## Pre-release Versions

### 0.5.0

Add an optional block argument to ArrayTools#humanize_list.

#### Toolbox

Implement Delegator#delegate, Delegator#wrap_delegate.

#### Identity Methods

Implement a set of methods to classify objects by type: ArrayTools#array?, HashTools#hash?, IntegerTools#integer?, ObjectTools#object?, and StringTools#string?.

#### Mutability Methods

Implement #immutable? and #mutable? for ObjectTools, ArrayTools, and HashTools, which indicate whether or not a given object is mutable.

Implement #deep_freeze for ObjectTools, ArrayTools, and HashTools which recursively freezes the object and any children (array items, hash keys, and hash values).

## Current Release

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

## Previous Releases

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
