---
---

# SleepingKingStudios::Tools

A library of utility services and concerns to expand the functionality of core classes without polluting the global namespace.

## Documentation

{% include pages/index-versions.md %}

## Getting Started

Add the gem to your `Gemfile` or `gemspec`:

```ruby
gem 'sleeping_king_studios-tools'
```

Require `SleepingKingStudios::Tools` in your code:

```ruby
require 'sleeping_king_studios/tools'
```

To ensure that [message definitions](./tools/messages) are loaded, call the `SleepingKingStudios::Tools` initializer:

- In the [initializer](./initializer) for your project:

  ```ruby
  module Space
    @initializer = SleepingKingStudios::Tools::Toolbox::Initializer.new do
      SleepingKingStudios::Tools::Toolbox.initializer.call
    end
  end
  ```

- Or, in the entry points of your application (such as a `bin` script or `spec_helper.rb`).

## Reference

SleepingKingStudios::Tools defines the following tools:

<ul>
  <li>
    <strong><a href="./tools">Toolbelt</a></strong>
    <br>
    Functional tools for operating on Ruby objects, grouped by object type.
  </li>
  <li>
    <strong><a href="./tools/assertions">Assertions</a></strong>
    <br>
    Methods for asserting on the type or content of values.
  </li>
  <li>
    <strong><a href="./tools/messages">Messages</a></strong>
    <br>
    Tool for defining and generating human-readable messages.
  </li>
</ul>

It also provides a set of utility classes:

- **[Constant Map](./constant-maps)**
  <br>
  Provides an enumerable interface for defining a group of constants.
- **[Heritable Data](./heritable-data)**
  <br>
  Define `Data` subclasses with inheritable members and methods.
- **[Initializer](./initializer)**
  <br>
  Utility class for initializing a library or project and its dependencies.
- **[Mixin](./mixin)**
  <br>
  Implements recursive inheritance of both class and instance methods.
- **[Subclass](./subclass)**
  <br>
  Define subclasses with partially applied constructor parameters.

For a full list of defined classes and objects, see [Reference](./reference).
