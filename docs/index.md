---
---

# SleepingKingStudios::Tools

A library of utility services and concerns to expand the functionality of core classes without polluting the global namespace.

## Documentation

This is the documentation for the [current development build](https://github.com/sleepingkingstudios/sleeping_king_studios-tools) of SleepingKingStudios::Tools.

- For the most recent release, see [Version 1.2]({{site.baseurl}}/versions/1.2).
- For previous releases, see the [Versions]({{site.baseurl}}/versions) page.

## Getting Started

Add the gem to your `Gemfile` or `gemspec`:

```ruby
gem 'sleeping_king_studios-tools'
```

Require `SleepingKingStudios::Tools` in your code:

```ruby
require 'sleeping_king_studios/tools'
```

To ensure that [message definitions]({{site.baseurl}}/tools/messages) are loaded, call the `SleepingKingStudios::Tools` initializer:

- In the [initializer]({{site.baseurl}}/initializers) for your project:

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
    <strong><a href="{{site.baseurl}}/tools">Toolbelt</a></strong>
    <br>
    Functional tools for operating on Ruby objects, grouped by object type.
    <ul>
      <li>
        <strong><a href="{{site.baseurl}}/tools/assertions">Assertions</a></strong>
        <br>
        Methods for asserting on the type or content of values.
      </li>
      <li>
        <strong><a href="{{site.baseurl}}/tools/messages">Messages</a></strong>
        <br>
        Tool for defining and generating human-readable messages.
      </li>
    </ul>
  </li>
</ul>

It also provides a set of utility classes:

- **[Constant Maps]({{site.baseurl}}/constant-maps)**
  <br>
  Provides an enumerable interface for defining a group of constants.
- **[Initializers]({{site.baseurl}}/initializers)**
  <br>
  Utility class for initializing a library or project and its dependencies.

For a full list of defined classes and objects, see [Reference]({{site.baseurl}}/reference).
