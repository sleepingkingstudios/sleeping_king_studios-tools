# Development Notes

## 0.7.0

- StringTools - support symbolic arguments
- StringTools#chain |

  tools.chain(str, :underscore, :pluralize)
  #=> shorthand for tools.pluralize(tools.underscore str)
- StringTools#map_lines |

  tools.map_lines("10\n20 GOTO 10") { |str| "  #{str}" }
  #=> "  10\n  20 GOTO 10"

- IntegerTools#pluralize - have third (plural string) parameter be optional and defer to StringTools#pluralize.

- Toolbelt should be autoloaded via Tools.

## Future Tasks

- Remove 'extend self' from Tools modules.

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

#### Toolkit

- Configuration

### Maintenance

- Remove deprecated StringTools#pluralize(int, str, str) implementation.
