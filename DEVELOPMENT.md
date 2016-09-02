# Development Notes

## Future Tasks

- Remove 'extend self' from Tools modules.

### Features

#### Tools

- StringTools#chain |

  tools.chain(str, :underscore, :pluralize)
  #=> shorthand for tools.pluralize(tools.underscore str)

- ObjectTools#pretty - returns user-friendly string representation. :multiline option? Delegates to specific toolset implementations.
- RegexpTools#matching_string - generates a string that matches the regular expression. Does not support advanced Regexp features.
- RegexpTools#nonmatching_strings - generates a set of strings that do not match the regular expression.
- Identity Methods
  - RegexpTools#regexp? - true if object is regular expression, otherwise false.

#### Toolkit

- Configuration
- ConstantEnumerator |

  class MyClass
    ROLES = ConstantEnumerator.new do
      USER  = 'user'
      ADMIN = 'admin'
    end

    MyClass::ROLES::USER # 'user'
    MyClass::ROLES.admin # 'admin'
    MyClass::ROLES.all { 'USER' => 'user', 'ADMIN' => 'admin' }
  end
- ImmutableConstantEnumerator
  - Values cannot be added or removed after initial block
  - Freezes individual values
  - Equivalent to ConstantEnumerator.new do ... end.immutable!

### Maintenance

- Remove deprecated StringTools#pluralize(int, str, str) implementation.
