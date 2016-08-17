# Development Notes

## Version 0.4.0

### Features

- Identity Methods
  - ArrayTools#array? - true if object is array-like
  - HashTools#hash? - true if object is hash-like
  - IntegerTools#integer? - true if object is integer
  - ObjectTools#object? - true if object is object-like (not BasicObject!)
  - StringTools#string? - true if object is string

## Future Tasks

### Features

#### Tools

- StringTools#humanize_list - accept a block. If block given, yield each item and join the results.
- ObjectTools#pretty - returns user-friendly string representation. :multiline option? Delegates to specific toolset implementations.
- RegexpTools#matching_string - generates a string that matches the regular expression. Does not support advanced Regexp features.
- RegexpTools#nonmatching_strings - generates a set of strings that do not match the regular expression.
- Identity Methods
  - RegexpTools#regexp? - true if object is regular expression, otherwise false.
- ObjectTools#immutable? - delegates to specific toolset implementations.
  - Values of `nil`, `false`, and `true` are always immutable, as are instances of `Numeric` and `Symbol`.
  - Arrays are immutable if the array is frozen and all items are immutable.
  - Hashes are immutable if the hash is frozen and all keys and values are immutable.
  - All other objects are only immutable if the object is frozen.
- ObjectTools#freeze - delegates to specific toolset implementation
  - Arrays freeze the collection and each item
  - Hashes freeze the collection and each key and value
- ObjectTools#deprecation_warning

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

### Maintenance

- Deprecate StringTools#pluralize(int, str, str) implementation ~ move to IntegerTools#pluralize. For XTools, first argument must be an instance of X!
