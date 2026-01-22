# SleepingKingStudios::Tools

A library of utility services and concerns to expand the functionality of core classes without polluting the global namespace.

<blockquote>
  Read The
  <a href="https://www.sleepingkingstudios.com/sleeping_king_studios-tools" target="_blank">
    Documentation
  </a>
</blockquote>

## About

SleepingKingStudios::Tools is tested against MRI Ruby 3.2 through 4.0.

### Documentation

Method and class documentation is available courtesy of RubyDoc.

Documentation is generated using [YARD](https://yardoc.org/), and can be generated locally using the `yard` gem.

### License

SleepingKingStudios::Tools is released under the [MIT License](https://opensource.org/licenses/MIT).

### Contribute

The canonical repository for this gem is on [GitHub](https://github.com/sleepingkingstudios/sleeping_king_studios-tasks). Community contributions are welcome - please feel free to fork or submit issues, bug reports or pull requests.

### Code of Conduct

Please note that the `SleepingKingStudios::Tools` project is released with a [Contributor Code of Conduct](https://github.com/sleepingkingstudios/sleeping_king_studios-tools/blob/master/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

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
