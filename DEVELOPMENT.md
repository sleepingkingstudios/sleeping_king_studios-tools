# Development Notes

## 1.0.0

- Documentation pass.

### Constants Maps

- Remove lazy definition of constant readers.
- Define #[], #each_key, #each_pair, #each_value, #fetch, #to_h.

## Future Tasks

### Tools

- HashTools#bisect_keys
- HashTools#slice
- ObjectTools#apply_with_arity
- ObjectTools#method_arity
- ObjectTools#pretty - returns user-friendly string representation. :multiline option? Delegates to specific toolset implementations.
- RegexpTools#matching_string - generates a string that matches the regular expression. Does not support advanced Regexp features.
- RegexpTools#nonmatching_strings - generates a set of strings that do not match the regular expression.

#### Identity Methods

- RegexpTools#regexp? - true if object is regular expression, otherwise false.
