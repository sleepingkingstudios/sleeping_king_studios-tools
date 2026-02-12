---
breadcrumbs:
  - name: Documentation
    path: '../'
---

# Tools

The core feature of `SleepingKingStudios::Tools` is the toolbelt, which provides a set of functional tools for operating on Ruby objects, asserting on values, generating human-readable messages, and more.

Unlike other solutions such as `ActiveSupport` which patch core classes, `SleepingKingStudios::Tools` uses a functional style inspired by libraries like `lodash.js`.

## Contents

- [Toolbelt](#toolbelt)
  - [.instance](#toolbeltinstance)
- [Defined Tools](#defined-tools)
  - [Array Tools](#array-tools)
  - [Assertions](#assertions)
  - [Core Tools](#core-tools)
  - [Hash Tools](#hash-tools)
  - [Integer Tools](#integer-tools)
  - [Messages](#messages)
  - [Object Tools](#object-tools)
  - [String Tools](#string-tools)

## Toolbelt

While individual tools *can* be initialized separately, the intended entry point is the toolbelt, an instance of `SleepingKingStudios::Tools::Toolbelt`. A toolbelt (lazily) references its tools as needed and ensures that cross-dependencies between tools are handled consistently.

```ruby
toolbelt = SleepingKingStudios::Tools::Toolbelt.instance

# Accessing String tools.
toolbelt.string_tools.camelize('space_program') #=> 'Space Program'

# Accessing Object tools.
toolbelt.object_tools.immutable?(Object.new)        #=> false
toolbelt.object_tools.immutable?(Object.new.freeze) #=> true
```

For a full list of tools, see [Defined Tools](#defined-tools) below, or [Reference]({{site.baseurl}}/reference/sleeping-king-studios/tools/toolbelt).

### Toolbelt.instance

The `Toolbelt.instance` class method returns a toolbelt singleton.

```ruby
module Space::LaunchRocket
  def call(rocket_name, **options)
    rocket_name  = tools.string_tools.camelize(rocket_name)
    rocket_class = Object.const_get(rocket_name)

    rocket_class.new(**options).launch
  end

  private

  def tools = SleepingKingStudios::Tools::Toolbelt.instance
end
```

Above, we are defining a private `#tools` method that returns the `Toolbelt.instance` singleton. We then use the `tools.string_tools` helper to convert a string to CamelCase, allowing us to use it as a class name.

### Redefining Toolbelt.instance

By default, the `Toolbelt.instance` method returns the value of `Toolbelt.global`, a singleton with default configuration that is thread-safe (ensuring all calls to `Toolbelt.global` return the same object).

However, `Toolbelt.instance` is intended to be overwritten by the end user (at the application level, not by individual libraries or dependencies). For example, an application might define a custom inflector, or define its own rules for handling deprecated code. Overwriting `Toolbelt.instance` ensures that custom configuration will be used in every toolbelt reference, even in code that does not reference the application directly.

## Defined Tools

Each toolbelt defines the following tools:

### `array_tools`

Tools for working with `Array`s and `Array`-like objects (countable, enumerable, indexed collections).

`ArrayTools` methods include:

<dl>
  <dt><code>#deep_dup(ary)</code></dt>
  <dd>
    Creates a deep copy of the array and its contents.
  </dd>

  <dt><code>#deep_freeze(ary)</code></dt>
  <dd>
    Freezes the array and performs a deep freeze on each array item.
  </dd>

  <dt><code>#fetch(ary, index, default = nil, &default_block)</code></dt>
  <dd>
    Retrieves the value at the specified index.
  </dd>

  <dt><code>#humanize_list(ary)</code></dt>
  <dd>
    Generates a human-readable string representation of the list items.
  </dd>
</dl>

For a full list of methods, see [Reference]({{site.baseurl}}/reference/sleeping-king-studios/tools/array-tools).

[Back to Defined Tools](#defined-tools) \| [Back to Top](#)

### [Assertions](./assertions)

Methods for asserting on the type or content of values. See [Assertions documentation](./assertions).

`Assertions` methods include:

<dl>
  <dt><code>#assert_boolean(value)</code></dt>
  <dd>
    Raises an exception unless the value is <code>true</code> or <code>false</code>.
  </dd>

  <dt><code>#assert_exclusion(value, expected:)</code></dt>
  <dd>
    Raises an exception if the value is one of the given values.
  </dd>

  <dt><code>#assert_inclusion(value, expected:)</code></dt>
  <dd>
    Raises an exception if the value is not one of the given values.
  </dd>

  <dt><code>#assert_instance_of(value, expected:)</code></dt>
  <dd>
    Raises an exception if the value is not an instance of the given class.
  </dd>

  <dt><code>#assert_name(value)</code></dt>
  <dd>
    Raises an exception unless the value is a non-empty <code>String</code> or <code>Symbol</code>.
  </dd>

  <dt><code>#assert_presence(value)</code></dt>
  <dd>
    Raises an exception if the value is <code>nil</code> or <code>#empty?</code>.
  </dd>
</dl>

For a full list of methods, see [Reference]({{site.baseurl}}/reference/sleeping-king-studios/tools/assertions).

[Back to Defined Tools](#defined-tools) \| [Back to Top](#)

### Core Tools

Tools for working with an application or working environment.

`CoreTools` methods include:

<dl>
  <dt><code>#deprecate(details, message: nil)</code></dt>
  <dd>
    Prints a warning or raises an exception based on the configured deprecation stratey.
  </dd>
</dl>

To configure the deprecation strategy, set `ENV['DEPRECATION_STRATEGY']` to one of the following:

- `'ignore'` will silently ignore deprecations.
- `'raise'` will raise a `DeprecationError` for each deprecation.
- `'warn'` will print a deprecation warning using `Kernel.warn`.

For a full list of methods, see [Reference]({{site.baseurl}}/reference/sleeping-king-studios/tools/core-tools).

[Back to Defined Tools](#defined-tools) \| [Back to Top](#)

### Hash Tools

Tools for working with `Hash`es and `Hash`-like objects (enumerable key-value collections).

`HashTools` methods include:

<dl>
  <dt><code>#convert_keys_to_strings(hsh)</code></dt>
  <dd>
    Returns a deep copy of the hash with the keys converted to <code>String</code>s.
  </dd>

  <dt><code>#convert_keys_to_symbols(hsh)</code></dt>
  <dd>
    Returns a deep copy of the hash with the keys converted to <code>Symbol</code>s.
  </dd>

  <dt><code>#deep_dup(hsh)</code></dt>
  <dd>
    Creates a deep copy of the hash and its contents.
  </dd>

  <dt><code>#deep_freeze(hsh)</code></dt>
  <dd>
    Freezes the hash and performs a deep freeze on each hash key and value.
  </dd>

  <dt><code>#fetch(hsh, key, default = nil, &default_block)</code></dt>
  <dd>
    Retrieves the value at the specified key.
  </dd>
</dl>

For a full list of methods, see [Reference]({{site.baseurl}}/reference/sleeping-king-studios/tools/hash-tools).

[Back to Defined Tools](#defined-tools) \| [Back to Top](#)

### Integer Tools

Tools for working with `Integer` values.

`IntegerTools` methods include:

<dl>
  <dt><code>#pluralize(count, single, plural = nil)</code></dt>
  <dd>
    Returns the singular or the plural value, depending on the provided count.
  </dd>

  <dt><code>#romanize(int)</code></dt>
  <dd>
    Represents an integer between 1 and 4999 (inclusive) as a Roman numeral.
  </dd>
</dl>

For a full list of methods, see [Reference]({{site.baseurl}}/reference/sleeping-king-studios/tools/integer-tools).

[Back to Defined Tools](#defined-tools) \| [Back to Top](#)

### [Messages](./messages)

Utility for generating configured, user-readable output strings. See [Messages documentation](./messages).

`Messages` methods include:

<dl>
  <dt><code>#message(key, parameters: {}, scope: nil, **)</code></dt>
  <dd>
    Generates a message from the given key, scope, and parameters.
  </dd>
</dl>

For a full list of methods, see [Reference]({{site.baseurl}}/reference/sleeping-king-studios/tools/messages).

[Back to Defined Tools](#defined-tools) \| [Back to Top](#)

### Object Tools

Low-level tools for working with objects.

`ObjectTools` methods include:

<dl>
  <dt><code>#deep_dup(obj)</code></dt>
  <dd>
    Creates a deep copy of the object.
  </dd>

  <dt><code>#deep_freeze(obj)</code></dt>
  <dd>
    Performs a deep freeze of the object.
  </dd>

  <dt><code>#deep_freeze(obj)</code></dt>
  <dd>
    Performs a deep freeze of the object.
  </dd>

  <dt><code>#dig(obj, *method_names, indifferent_keys: false)</code></dt>
  <dd>
    Accesses deeply nested properties on an object.
  </dd>

  <dt><code>#fetch(obj, key_or_index, default = nil, indifferent_key: false, &block)</code></dt>
  <dd>
    Retrieves the value at the specified method, key, or index.
  </dd>
</dl>

For a full list of methods, see [Reference]({{site.baseurl}}/reference/sleeping-king-studios/tools/object-tools).

[Back to Defined Tools](#defined-tools) \| [Back to Top](#)

### String Tools

Tools for working with `String`s.

`StringTools` methods include:

<dl>
  <dt><code>#camelize(str)</code></dt>
  <dd>
    Converts a lowercase, underscore-separated string to CamelCase.
  </dd>

  <dt><code>#indent(str, count = 2)</code></dt>
  <dd>
    Adds the specified number of spaces to the start of each line.
  </dd>

  <dt><code>#pluralize(str)</code></dt>
  <dd>
    Takes a word in singular form and returns the plural form.
  </dd>

  <dt><code>#singularize(str)</code></dt>
  <dd>
    Takes a word in plural form and returns the singular form.
  </dd>

  <dt><code>#underscore(str)</code></dt>
  <dd>
    Converts a mixed-case string to a lowercase, underscore separated string.
  </dd>
</dl>

For a full list of methods, see [Reference]({{site.baseurl}}/reference/sleeping-king-studios/tools/string-tools).

[Back to Defined Tools](#defined-tools) \| [Back to Top](#)

{% include breadcrumbs.md %}
