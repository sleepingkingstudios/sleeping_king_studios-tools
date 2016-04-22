# Development Notes

### Features

- ObjectTools#pretty - returns user-friendly string representation. :multiline option? Delegates to specific toolset implementations.
- RegexpTools#matching_string - generates a string that matches the regular expression. Does not support advanced Regexp features.
- RegexpTools#nonmatching_strings - generates a set of strings that do not match the regular expression.
- Identity Methods
  - ArrayTools#array? - true if object is array-like
  - HashTools#hash? - true if object is hash-like
  - IntegerTools#
  - ObjectTools#object? - true if object is object-like (not BasicObject!)
  - RegexpTools#regexp? - true if object is regular expression, otherwise false.
  - StringTools#string? - true if object is string

### Maintenance

- Replace `extend self` with `module_method` in all tools.
