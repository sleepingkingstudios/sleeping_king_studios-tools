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

To ensure that [message definitions](./tools/messages) are loaded, call the `SleepingKingStudios::Tools` initializer:

- In the [initializer](./initializers) for your project:

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

- **[Initializers](./initializers)**
  <br>
  Utility class for initializing a library or project and its dependencies.

For a full list of defined classes and objects, see [Reference](./reference).
