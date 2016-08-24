# Development Notes

## Version 0.5.0 - The Cold Update

- ObjectTools#freeze - delegates to specific toolset implementation
  - Arrays freeze the collection and each item
  - Hashes freeze the collection and each key and value
- ObjectTools#frozen_copy
- StringTools#humanize_list - accept a block. If block given, yield each item and join the results.

## Future Tasks

- Remove 'extend self' from Tools modules.

### Features

#### Tools

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
