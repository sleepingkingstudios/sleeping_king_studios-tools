---
breadcrumbs:
  - name: Documentation
    path: './'
---

# Initializers

`SleepingKingStudios::Tools` defines the `Initializer` utility class for initializing a library or project and its dependencies.

An initializer is used to set up the project, including loading configuration, setting initial data or states, and initializing dependencies.

Using an initializer provides several advantages:

- Potentially-expensive setup code is run on your own schedule, not when the module is first loaded.
- The setup code will only run once, even if the initializer is called multiple times or from multiple places.
- The setup code will only run once, even in a multi-threaded environment.

The class reference for `SleepingKingStudios::Tools::Toolbox::Initializer` can be found in [Reference](./reference/sleeping-king-studios/tools/toolbox/initializer).

## Contents

- [Defining An Initializer](#defining-an-initializer)
- [Calling The Initializer](#calling-the-initializer)

## Defining An Initializer

In order to ensure the initializer runs only once, it must be defined statically when the library or project is defined.

```ruby
module Space
  @initializer = SleepingKingStudios::Tools::Toolbox::Initializer.new do
    # Initialize the project's dependencies.
    Planets.initializer.call

    # Set up the project environment.
    Space.load_configuration
    Space.launch_sites = %w[KSC]

    # Load human-readable message definitions for the project namespace.
    SleepingKingStudios::Tools.initializer.call
    SleepingKingStudios::Tools::Messages::Registry
      .global
      .register(file: 'config/messages.yml' scope: 'space')
  end

  def self.initializer = @initializer
end
```

First, we define the initializer itself as an instance variable in the Module definition (which sets `@initializer` an instance variable on the singleton class). This ensures that the initializer is defined when the code is first loaded.

The `Initializer.new` method takes a block, which is run when the initializer is called for the first time. In our initializer, we're doing a different things:

- We're calling a dependency's own initializer: `Planets.initializer.call`. This ensures that whatever setup the `Planets` module needs is completed before setting up `Space`.
- We call `Space.load_configuration` and do some manual data setup on `Space.launch_sites`.
- Finally, we ensure that `SleepingKingStudios::Tools` itself is initialized, and register a message strategy for messages with the `space` namespace, matching our library name. See [Messages](./tools/messages) for more details.

Next, we define a class method that returns the initializer. This allows our initializer to be called from outside of our module.

**Important Note:** Do not define the `@initializer` inside the method - this will allow the initializer to be called multiple times in a multi-threaded application. Always define the initializer in the Module body, then define the method to access it.

## Calling The Initializer

Once the initializer is defined, update the entry point for your project to call the initializer.

Projects that rely on a library with an initializer should call that initializer, ideally in an initializer of their own. For example, imagine that the `Space::Game` project relies on the `Space::Orbits` and `Space::Rockets` libraries, each of which relies on `Space::Physics`. In that example:

- The initializer for `Space::Game` should call the initializer for `Space::Orbits` and `Space::Rockets`.
- The initializer for `Space::Orbits` should call the initializer for `Space::Physics`.
- The initializer for `Space::Rockets` should also call the initializer for `Space::Physics`.

Even if multiple libraries call the same initializer, the code will run only once - in the above example, the initializer for `Space::Physics` will only run once, even though multiple libraries rely on it. This allows each library to safely manage its own dependencies.

You can also call the initializer directly. In a script:

```ruby
# bin/launch

require 'space'

Space.initializer.call

Space.launch_rocket(ARGV[0])
```

In your test suite:

```ruby
# spec/spec_helper.rb

require 'space'

Space.initializer.call

RSpec.configure do
  # Test configuration here.
end
```

{% include breadcrumbs.md %}
