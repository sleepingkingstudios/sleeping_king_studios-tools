# Development Notes

## 0.8.0

Preview build for 1.0.0: maintain backward compability with deprecation warnings

- Support Ruby 2.5 through 2.7
- Address all RuboCop warnings
- Remove Rakefile.

## 1.0.0

- Remove sleeping_king_studios/tools/all
- Remove all deprecated methods and references.
- Documentation pass.

## Future Tasks

### Features

- HashTools::slice, ::bisect_keys
- ObjectTools::apply_with_arity
- ObjectTools::method_arity
- Delegator#delegate, :prefix => prefix_name

#### Tools

- ObjectTools#pretty - returns user-friendly string representation. :multiline option? Delegates to specific toolset implementations.
- RegexpTools#matching_string - generates a string that matches the regular expression. Does not support advanced Regexp features.
- RegexpTools#nonmatching_strings - generates a set of strings that do not match the regular expression.
- Identity Methods
  - RegexpTools#regexp? - true if object is regular expression, otherwise false.
