# Changelog

## Pre-release Versions

### 0.5.0

#### ArrayTools

Implement #array?.

#### HashTools

Implement #hash?.

#### IntegerTools

Implement #integer?.

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
