---
breadcrumbs:
  - name: Documentation
    path: '../'
  - name: Tools
    path: './'
---

# Assertions

The `Assertions` tool is used to define invariants in the code to catch invalid data.

For a list of available assertions, see [Defined Assertions](#defined-assertions) below, or the [Reference documentation]({{site.baseurl}}/reference/sleeping-king-studios/tools/assertions).

## Contents

- [Using Assertions](#using-assertions)
  - [Grouped Assertions](#grouped-assertions)
  - [Error Messages](#error-messages)
    - [Redefining Error Messages](#redefining-error-messages)
  - [Validating Method Parameters](#validating-method-parameters)
- [Defined Assertions](#defined-assertions)
  - [#assert](#assert)
  - [#assert_blank](#assert_blank)
  - [#assert_boolean](#assert_boolean)
  - [#assert_class](#assert_class)
  - [#assert_exclusion](#assert_exclusion)
  - [#assert_inclusion](#assert_inclusion)
  - [#assert_inherits_from](#assert_inherits_from)
  - [#assert_instance_of](#assert_instance_of)
  - [#assert_matches](#assert_matches)
  - [#assert_name](#assert_name)
  - [#assert_nil](#assert_nil)
  - [#assert_not_nil](#assert_not_nil)
  - [#assert_presence](#assert_presence)

## Using Assertions

Assertion methods are accessed using the `Toolbelt#assertions` method.

```ruby
tools = SleepingKingStudios::Tools::Toolbelt.instance

tools.assertions.assert_name('Alan Bradley')
#=> does not raise an exception

tools.assertions.assert_name(nil)
#=> raises an AssertionError with message "value can't be blank"

tools.assertions.assert_name(Object.new)
#=> raises an AssertionError with message 'value is not a String or a Symbol'

tools.assertions.assert_name(Object.new, as: 'username')
#=> raises an AssertionError with message 'username is not a String or a Symbol'

tools.assertions.assert_inclusion('options', expected: %w[get post put delete])
#=> raises an AssertionError with message 'username is not one of "get", "post", "put", "delete"'
```

Each assertion takes the value being asserted on, an optional `as:` parameter used to generate the error message, and an optional `error_class:` parameter used to configured the raised exception. Some assertions may require an `expected:` parameter indicating the expected value, and/or an `optional:` parameter indicating that `nil` values are accepted.

### Grouped Assertions

To perform multiple assertions and aggregate the failures, use the `Assertions#assert_group` method.

```ruby
tools.assertions.assert_group do |group|
  group.assert_name(nil, as: 'label')
  group.assert_instance_of(0.0, expected: Integer, as: 'quantity')
end
#=> raises an AssertionError with message: "label can't be blank, quantity is not an instance of Integer"
```

A grouped assertion will fail and raise an exception if any of the inner assertions fail. Grouped assertions can also be nested.

### Error Messages

Error messages for failed assertions are generated based on the `as:` parameter (defaults to `"value"`) and any expected parameters. The same error message can be generated using the `Assertions#error_message_for` method.

```ruby
tools.assertions.error_message_for('name', as: 'username')
#=> returns "username is not a String or a Symbol"
```

The `#error_message_for` method is particularly useful when writing tests, as it ensures that the expected message will always match the configured message for that error without requiring updates if the message format is changed.

You can also pass a full scoped key to `#error_message_for`, which will return the corresponding [message]({{site.baseurl}}/tools/messages) defined for that scoped key. This is useful when defining custom assertions.

Using error messages requires the [initializer]({{site.baseurl}}/initializers) for `SleepingKingStudios::Tools` to be called; otherwise, a fallback message starting with `"Message missing:"` will be used. The fallback is also used for error messages when the key is not defined, which may occur when defining custom assertions.

#### Redefining Error Messages

The base message for each assertion is defined using a [Messages strategy]({{site.baseurl}}/tools/messages) with scope `"sleeping_king_studios.tools.assertions"`. To override the default messages, use a custom Messages registry or define a new strategy for that scope.

### Validating Method Parameters

The most common use for `Assertions` is validating method parameters. To do so, `Assertions` defines `#validate_` aliases for the [defined assertions](#defined-assertions), which raise `ArgumentError`s instead of `AssertionError`s on a failure. For example, instead of calling `#assert_presence`, use `#validate_presence` for parameter validation.

```ruby
def build_rocket(rocket_name, fuel_amount: 0.0)
  tools.assertions.validate_name(rocket_name, as: 'rocket_name')
  tools.assertions.validate_instance_of(
    fuel_amount,
    as:       'fuel_amount',
    expected: Numeric
  )

  Rocket.new(rocket_name).refuel(fuel_amount)
end

build_rocket('Imp VI')
#=> returns a Rocket

build_rocket('')
#=> raises an ArgumentError with message "rocket_name can't be blank"

build_rocket('Imp VI', fuel_amount: 'N/A')
#=> raises an ArgumentError with message "fuel_amount is not an instance of Numeric"
```

Validating method parameters helps to avoid bugs farther down the line.

## Defined Assertions

`Assertions` defines the following methods, as well as their `#validate_` equivalents.

- [#assert](#assert)
- [#assert_blank](#assert_blank)
- [#assert_boolean](#assert_boolean)
- [#assert_class](#assert_class)
- [#assert_exclusion](#assert_exclusion)
- [#assert_inclusion](#assert_inclusion)
- [#assert_inherits_from](#assert_inherits_from)
- [#assert_instance_of](#assert_instance_of)
- [#assert_matches](#assert_matches)
- [#assert_name](#assert_name)
- [#assert_nil](#assert_nil)
- [#assert_not_nil](#assert_not_nil)
- [#assert_presence](#assert_presence)

For a full list of methods, see the [Reference documentation]({{site.baseurl}}/reference/sleeping-king-studios/tools/assertions).

### `#assert`

Generic assertion that takes a message and a block.

```ruby
array = %w[ichi ni san]

tools.assertions.assert { array.empty? }
#=> raises an AssertionError with message "block returned a falsy value"

tools.assertions.assert(message: 'must be empty', as: 'array') { array.empty? }
#=> raises an AssertionError with message "array must be empty"
```

[Back to Defined Assertions](#defined-assertions) \| [Back to Top](#)

### `#assert_blank`

Asserts that the value is `nil`, or responds to `#empty?` and `value.empty?` is `true`.

```ruby
tools.assertions.assert_blank(nil)
#=> does not raise an exception

tools.assertions.assert_blank([])
#=> does not raise an exception

tools.assertions.assert_blank(Object.new)
#=> raises an AssertionError

tools.assertions.assert_blank(%w[ichi ni san])
#=> raises an AssertionError
```

[Back to Defined Assertions](#defined-assertions) \| [Back to Top](#)

### `#assert_boolean`

Asserts that the value is `true` or `false`.

```ruby
tools.assertions.assert_boolean(nil)
#=> raises an AssertionError

tools.assertions.assert_boolean(Object.new)
#=> raises an AssertionError

tools.assertions.assert_boolean(false)
#=> does not raise an exception

tools.assertions.assert_boolean(true)
#=> does not raise an exception

tools.assertions.assert_boolean(nil, optional: true)
#=> does not raise an exception
```

[Back to Defined Assertions](#defined-assertions) \| [Back to Top](#)

### `#assert_class`

Asserts that the value is `Class`.

```ruby
tools.assertions.assert_class(nil)
#=> raises an AssertionError

tools.assertions.assert_class(Object.new)
#=> raises an AssertionError

tools.assertions.assert_class(String)
#=> does not raise an exception

tools.assertions.assert_class(nil, optional: true)
#=> does not raise an exception
```

[Back to Defined Assertions](#defined-assertions) \| [Back to Top](#)

### `#assert_exclusion`

Asserts that the value is not one of the provided values. Requires an `expected:` parameter.

```ruby
tools.assertions.assert_exclusion(nil, expected: %w[get post put delete])
#=> does not raise an exception

tools.assertions.assert_exclusion('options', expected: %w[get post put delete])
#=> does not raise an exception

tools.assertions.assert_exclusion('get', expected: %w[get post put delete])
#=> raises an AssertionError
```

[Back to Defined Assertions](#defined-assertions) \| [Back to Top](#)

### `#assert_inclusion`

Asserts that the value is one of the provided values. Requires an `expected:` parameter.

```ruby
tools.assertions.assert_inclusion(nil, expected: %w[get post put delete])
#=> raises an AssertionError

tools.assertions.assert_inclusion('options', expected: %w[get post put delete])
#=> raises an AssertionError

tools.assertions.assert_inclusion('get', expected: %w[get post put delete])
#=> does not raise an exception

tools.assertions.assert_inclusion(nil, expected: %w[get post put delete], optional: true)
#=> does not raise an exception
```

[Back to Defined Assertions](#defined-assertions) \| [Back to Top](#)

### `#assert_inherits_from`

Asserts that the value is a `Class` or `Module` that has the provided value as an ancestor. Requires an `expected:` parameter.

```ruby
tools.assertions.assert_inherits_from(nil, expected: StandardError)
#=> raises an AssertionError

tools.assertions.assert_inherits_from(String, expected: StandardError)
#=> raises an AssertionError

tools.assertions.assert_inherits_from(ArgumentError, expected: StandardError)
#=> does not raise an exception

tools.assertions.assert_inherits_from(StandardError, expected: StandardError)
#=> does not raise an exception
```

If the `strict:` parameter is set to true, does not match if the given and expected values are the same `Class` or `Module`.

```ruby
tools.assertions.assert_inherits_from(StandardError, expected: StandardError, strict: true)
#=> raises an AssertionError
```

[Back to Defined Assertions](#defined-assertions) \| [Back to Top](#)

### `#assert_instance_of`

Asserts that the value is an instance of the given `Class`, or if the value's class inherits from the given `Class` or `Module`. Requires an `expected:` parameter.

```ruby
tools.assertions.assert_instance_of(nil, expected: String)
#=> raises an AssertionError

tools.assertions.assert_instance_of(Object.new, expected: String)
#=> raises an AssertionError

tools.assertions.assert_instance_of('Greetings, programs!', expected: String)
#=> does not raise an exception

tools.assertions.assert_instance_of(%w[ichi ni san], expected: Enumerable)
#=> does not raise an exception
```

[Back to Defined Assertions](#defined-assertions) \| [Back to Top](#)

### `#assert_matches`

Asserts that the value matches the given value using the `#===` case equality operator. Requires an `expected:` parameter.

```ruby
tools.assertions.assert_matches('bar', expected: /foo/)
#=> raises an AssertionError

tools.assertions.assert_matches('foo', expected: /foo/)
#=> does not raise an exception

tools.assertions.assert_matches('foo', expected: String)
#=> does not raise an exception

tools.assertions.assert_matches('foo', expected: ->(str) { str.start_with?('f') })
#=> does not raise an exception
```

[Back to Defined Assertions](#defined-assertions) \| [Back to Top](#)

### `#assert_name`

Asserts that the value is a non-empty `String` or `Symbol`.

```ruby
tools.assertions.assert_name(nil)
#=> raises an AssertionError

tools.assertions.assert_name(Object.new)
#=> raises an AssertionError

tools.assertions.assert_name('')
#=> raises an AssertionError

tools.assertions.assert_name(:'')
#=> raises an AssertionError

tools.assertions.assert_name('Alan Bradley')
#=> does not raise an exception

tools.assertions.assert_name(:username)
#=> does not raise an exception
```

[Back to Defined Assertions](#defined-assertions) \| [Back to Top](#)

### `#assert_nil`

Asserts that the value is `nil`.

```ruby
tools.assertions.assert_nil(nil)
#=> does not raise an exception

tools.assertions.assert_nil(Object.new)
#=> raises an AssertionError
```

[Back to Defined Assertions](#defined-assertions) \| [Back to Top](#)

### `#assert_not_nil`

Asserts that the value is not `nil`.

```ruby
tools.assertions.assert_not_nil(nil)
#=> raises an AssertionError

tools.assertions.assert_not_nil(Object.new)
#=> does not raise an exception
```

[Back to Defined Assertions](#defined-assertions) \| [Back to Top](#)

### `#assert_presence`

Asserts that the value is not `nil`, and if the value responds to `#empty?`, is not empty.

```ruby
tools.assertions.assert_presence(nil)
#=> raises an AssertionError

tools.assertions.assert_presence(Object.new)
#=> does not raise an exception

tools.assertions.assert_presence('')
#=> raises an AssertionError

tools.assertions.assert_presence('Alan Bradley')
#=> does not raise an exception

tools.assertions.assert_presence([])
#=> raises an AssertionError

tools.assertions.assert_presence(%w[ichi ni san])
#=> does not raise an exception
```

[Back to Defined Assertions](#defined-assertions) \| [Back to Top](#)

{% include breadcrumbs.md %}
