---
breadcrumbs:
  - name: Documentation
    path: '../'
  - name: Tools
    path: './'
---

# Messages

The `Messages` tool is used for defining and generating human-readable messages.

For a full list of available methods, see the [Reference documentation](../reference/sleeping-king-studios/tools/messages).

## Contents

- [Generating Messages](#generating-messages)
  - [Missing Messages](#missing-messages)
  - [Parameterized Messages](#parameterized-messages)
  - [Default Values](#default-values)
- [Registering Messages](#registering-messages)
  - [Message Strategies](#message-strategies)
    - [File Strategies](#file-strategies)
    - [Hash Strategies](#hash-strategies)
  - [Message Registries](#message-registries)
    - [Global Registry](#global-registry)
    - [Custom Registries](#custom-registries)
- [Initializing Messages](#initializing-messages)
- [Registered Messages](#registered-messages)
  - [Message Templates](#message-templates)

## Generating Messages

To generate a human-readable message, use the `#message` method:

```ruby
tools = SleepingKingStudios::Tools::Toolbelt.instance

tools.messages.message('sleeping_king_studios.tools.assertions.name')
#=> "is not a String or a Symbol"
```

Each defined message has a **scope** and a **key**, separated by a period (`.`).

- The message **scope** is a `String` or a `Symbol` in `underscore_format`. If the scope has multiple parts, each part is separated by periods (`.`). In the above example, the scope is `'sleeping_king_studios.tools.assertions'`.
- The message **key** is a `String` or a `Symbol` in `underscore_format`. In the above example, the key is `'name'`.

Generally speaking, a message's scope should match the structure of the relevant code. The scope should **always** start with the name of the gem, application, or project.

Alternatively, you can pass the `scope` separately when calling `#message`:

```ruby
tools = SleepingKingStudios::Tools::Toolbelt.instance
scope = 'sleeping_king_studios.tools.assertions'
key   = :name

tools.messages.message(key, scope:)
#=> "is not a String or a Symbol"
```

This can be useful when generating multiple human-readable messages with the same base scope.

[Back to Top](#)

### Missing Messages

If a requested message is not defined, `#message` returns an error string with the scoped key:

```ruby
tools = SleepingKingStudios::Tools::Toolbelt.instance

tools.messages.message('sleeping_king_studios.tools.assertions.undefined_message')
#=> "Message missing: sleeping_king_studios.tools.assertions.undefined_message"
```

To define your own message definitions, see [Registering Messages](#registering-messages), below.

[Back to Top](#)

### Parameterized Messages

Messages can also have named parameters.

```ruby
tools = SleepingKingStudios::Tools::Toolbelt.instance

tools.messages.message(
  'sleeping_king_studios.tools.assertions.instance_of',
  parameters: { expected: 'String' }
)
#=> "is not an instance of String"
```

If a message requires parameters but a parameter is missing, `#message` returns an error string:

```ruby
tools = SleepingKingStudios::Tools::Toolbelt.instance

tools.messages.message('sleeping_king_studios.tools.assertions.instance_of')
#=> "Message missing parameters: sleeping_king_studios.tools.assertions.instance_of key<expected> not found"
```

You can force an exception to be raised for missing parameters by passing the `:reraise_exceptions` flag:

```ruby
tools = SleepingKingStudios::Tools::Toolbelt.instance

tools.messages.message('sleeping_king_studios.tools.assertions.instance_of', reraise_exceptions: true)
#=> raises a KeyError with message "key<expected> not found"
```

[Back to Top](#)

### Default Values

You can also provide a default value or `Proc` in case the requested message is not defined.

If you pass an object as the `default:` keyword, that default value will be returned if the requested message is not defined.

```ruby
tools = SleepingKingStudios::Tools::Toolbelt.instance

tools.messages.message(
  'example.messages.undefined_message',
  default: 'message not found'
)
#=> "message not found"
```

If you pass a `Proc` as the `default:` keyword, the proc will be called with the scoped message key and any additional parameters passed to `#message`.

```ruby
tools = SleepingKingStudios::Tools::Toolbelt.instance

tools.messages.message(
  'example.messages.undefined_message',
  default: lambda do |key, locale: 'en', **|
    "message not found with key #{key} and locale #{locale}"
  end,
  locale:  'es'
)
#=> "message not found with key example.messages.undefined_message and locale es"
```

[Back to Top](#)

## Registering Messages

Registering messages for use in the `#messages` tool takes two steps.

- First, define a [Messages strategy](#message-strategies), which maps keys for a given scope to a message definition.
- Second, add the strategy to the [Messages registry](#message-registries), which exposes that strategy to the tool.

[Back to Top](#)

### Message Strategies

Each message strategy must define a `#call` method that takes a `key` argument and optional `parameters:` and `scope:` keywords and returns the matching generated message. The strategy must ignore unexpected keyword parameters.

`SleepingKingStudios::Tools` provides two pre-defined strategy implementations:

- A [FileStrategy](#file-strategies) loads message definitions from a file, similar to tools such as `I18n`.
- A [HashStrategy](#hash-strategies) takes message definitions as a pre-defined `Hash`.

You can also define a custom strategy class. This allows you to retrieve messages from an external tool, or specify additional filters for matching the message definition (such as a `locale:` keyword).

[Back to Top](#)

#### File Strategies

A FileStrategy loads message definitions from a file.

```yaml
# In config/messages.yml
---
space:
  messages:
    errors:
      failure: 'not going to space'
    rockets:
      launch_status: 'rocket %<name>s is ready to launch'
  module_name: 'Console Space Program'
```

```ruby
file_name = 'config/messages.yml'
strategy  =
  SleepingKingStudios::Tools::Messages::Strategies::FileStrategy
  .new(file_name)

strategy.call('space.module_name')
#=> "Console Space Program"
strategy.call(:launch_status, parameters: { name: 'Imp VI' }, scope: 'space.messages.rockets')
#=> "rocket Imp VI is ready to launch"
```

The `FileStrategy` is initialized with the path to a definitions file.

- The file must have extname of `.json` (for a JSON file), or either `.yaml` or `.yml` (for a YAML file). To support other file types, subclass `FileStrategy`.
- The file data must map to a Ruby `Hash`, and each key must either be a message `String` or a nested `Hash`.

Nested scopes will be automatically flattened when the file is read. For example, the above file defines the scoped key `'space.messages.errors.failure'` to be `'not going to space'`.

Each message defined in a `FileStrategy` must be a `String`. Parameterized messages are supported using [Kernel#format](https://ruby-doc.org/current/format_specifications_rdoc.html). For example, the `'space.messages.rockets.launch_status` definition takes a `name` parameter.

You can also register a file strategy using the following shorthand:

```ruby
registry.register(scope: 'space', file: file_name)
```

[Back to Top](#)

##### Template Parsing

By default, a `FileStrategy` will flatten the parsed templates for efficient lookup - a nested `Hash` of `{ foo: { bar: { baz: 'template' } } }` is stored as a flat `Hash` with contents `{ 'foo.bar.baz' => 'template' }`. This makes lookup of scoped keys more efficient but prevents retrieving non-leaf nodes (such as `"foo"` or `"foo.bar"` in the above `Hash`). If you need to retrieve `Hash` values, initialize the strategy with `flatten_templates: false`.

```ruby
file_name = 'config/messages.yml'
strategy  =
  SleepingKingStudios::Tools::Messages::Strategies::FileStrategy
  .new(file_name, flatten_templates: false)

strategy.get('space.messages.errors')
#=> { 'failure' => 'not going to space' }
```

[Back to Top](#)

##### Template Validation

By default, a `FileStrategy` will allow parsing a template that maps to `String` values only - any other value type will raise a `ParseError` when the file is processed. You can skip this validation by initializing the strategy with `validate_values: false`, allowing you to load a file with templates of any value parseable from the serialized file.

```ruby
strategy =
  SleepingKingStudios::Tools::Messages::Strategies::FileStrategy
  .new(file_name, validate_values: false)

strategy.get('config.cheats.enabled')
#=> true
```

Alternatively, you can pass a `Proc` to `validate_values` to define a custom validation schema for the strategy. When loading the file, the `Proc` will be called with each template value. If the `Proc` returns an error message, the strategy will raise a `ParseError` with the given message. If the `Proc` returns `nil`, then that value is a valid template for the strategy.

```ruby
validate_values = lambda do |value|
  next true if value == true || value == false || value == nil
  next true if value.is_a?(String) || value.is_a?(Numeric)

  'value must be nil, false, true, a number, or a string'
end
strategy =
  SleepingKingStudios::Tools::Messages::Strategies::FileStrategy
  .new(file_name, validate_values:)

strategy.get('config.units.max_life')
#=> 9999
```

[Back to Top](#)

#### Hash Strategies

A HashStrategy takes message definitions as a pre-defined `Hash`.

```ruby
launch_status = lambda do |parameters: {}, ready: false, **|
  str = +'rocket'
  str << ' ' << parameters[:name] if parameters.key?(:name)
  str << (ready ? ' is' : ' is not')
  str << ' ready to launch'
  str.freeze
end
definitions = {
  'space' => {
    'messages'    => {
      'errors'  => {
        'failure' => 'not going to space'
      },
      'rockets' => {
        'launch_status' => launch_status
      }
    }
    'module_name' => 'Console Space Program'
  }
}
strategy =
  SleepingKingStudios::Tools::Messages::Strategies::HashStrategy
  .new(definitions)

strategy.call('space.module_name')
#=> "Console Space Program"

strategy.call(:launch_status, ready: true, scope: 'space.messages.rockets')
#=> "rocket is ready to launch"
```

The `HashStrategy` is initialized with a `Hash` of message definitions. Hash strategies support two types of message definition:

- If the message is a `String`, that string will be formatted using `Kernel#format` and the given parameters.
- If the message is a `Proc`, the proc will be called with the given parameters and any additional keywords passed to `#message`. This provides more fine-grained control over generated messages. In the above example, the `'space.messages.rockets.launch_status'` message is defined as a `Proc`, which takes an optional `ready:` flag when generating the message.

Nested scopes will be automatically flattened when the file is read. For example, the above definitions define the scoped key `'space.messages.errors.failure'` to be `'not going to space'`.

You can also register a hash strategy using the following shorthand:

```ruby
registry.register(scope: 'space', hash: definitions)
```

[Back to Top](#)

##### Template Parsing

By default, a `HashStrategy` will flatten the parsed templates for efficient lookup - a nested `Hash` of `{ foo: { bar: { baz: 'template' } } }` is stored as a flat `Hash` with contents `{ 'foo.bar.baz' => 'template' }`. This makes lookup of scoped keys more efficient but prevents retrieving non-leaf nodes (such as `"foo"` or `"foo.bar"` in the above `Hash`). If you need to retrieve `Hash` values, initialize the strategy with `flatten_templates: false`.

```ruby
strategy  =
  SleepingKingStudios::Tools::Messages::Strategies::FileStrategy
  .new(definitions, flatten_templates: false)

strategy.get('space.messages.errors')
#=> { 'failure' => 'not going to space' }
```

[Back to Top](#)

##### Template Validation

By default, a `HashStrategy` will allow parsing a template that maps to `Proc` or `String` values only - any other value type will raise a `ParseError` when the file is processed. You can skip this validation by initializing the strategy with `validate_values: false`, allowing you to load a file with templates of any value parseable from the serialized file.

```ruby
definitions = {
  'config' => {
    'cheats' => {
      'enabled' => true
    },
    'units' => {
      'max_life' => 9_999
    }
  }
}
strategy =
  SleepingKingStudios::Tools::Messages::Strategies::HashStrategy
  .new(definitions, validate_values: false)

strategy.get('config.cheats.enabled')
#=> true
```

Alternatively, you can pass a `Proc` to `validate_values` to define a custom validation schema for the strategy. When loading the file, the `Proc` will be called with each template value. If the `Proc` returns an error message, the strategy will raise a `ParseError` with the given message. If the `Proc` returns `nil`, then that value is a valid template for the strategy.

```ruby
validate_values = lambda do |value|
  next true if value == true || value == false || value == nil
  next true if value.is_a?(String) || value.is_a?(Numeric)

  'value must be nil, false, true, a number, or a string'
end
strategy =
  SleepingKingStudios::Tools::Messages::Strategies::HashStrategy
  .new(definitions, validate_values:)

strategy.get('config.units.max_life')
#=> 9999
```

[Back to Top](#)

### Message Registries

Once your messages have been defined using a [Messages strategy](#message-strategies), the strategy must be added to a registry. By default, the `Messages` tool uses a shared global registry.

```ruby
registry = SleepingKingStudios::Tools::Messages::Registry.global
strategy = SleepingKingStudios::Tools::Messages::Strategies::HashStrategy.new

registry.register(scope: 'space', strategy:)

registry.get('space')
#=> strategy
```

When `#message` is called with a `scope:` or a scoped key starting with `'space.'`, the registry will resolve the message definition to the registed strategy with matching scope. That strategy is then called with the key, scope, and parameters to generate the message.

Registed strategies can be nested, in which case the registry will use the most specific strategy matching the message scope. For example, one strategy might be registered with scope `'space'`, and another strategy with scope `'space.planets'`. A message with scope `'space.stars'` would be resolved using the `'space'` strategy, but a message with scope `'space.planets.names'` would be resolved using the `'space.planets'` strategy.

[Back to Top](#)

#### Global Registry

The global registry provides a single entry point for defining and accessing message definitions across an application and its dependencies. Using the global registry has several advantages:

- Message strategies can be defined in any order, even after the toolbelt is initialized.
- The global registry is designed to be thread-safe, ensuring there is a single registry even in a multi-threaded environment.

The default `Toolbelt.instance` is already configured to use the global registry.

[Back to Top](#)

#### Custom Registries

A custom registry can be defined by instantiating a new copy of `Messages::Registry` or a subclass thereof. The registry can then be used by passing it a custom toolbelt.

```ruby
definitions = {
  'spec.test_cases.going_to_space' = 'Is the rocket going to space?'
}

registry = SleepingKingStudios::Tools::Messages::Registry.new
registry.register(scope: 'spec', hash: definitions)

toolbelt = SleepingKingStudios::Tools::Toolbelt.new(messages_registry: registry)
toolbelt.messages.message(:going_to_space, scope: 'spec.test_cases')
#=> "Is the rocket going to space?"
```

[Back to Top](#)

## Initializing Messages

The recommended way to register messages for your application or project is using a [project initializer](../initializer).

```ruby
module Space
  @initializer = SleepingKingStudios::Tools::Toolbox::Initializer.new do
    # Load human-readable message definitions for the project namespace.
    SleepingKingStudios::Tools.initializer.call
    SleepingKingStudios::Tools::Messages::Registry
      .global
      .register(file: 'config/messages.yml' scope: 'space')
  end

  def self.initializer = @initializer
end
```

Once the initializer is defined, update the entry point for your project to call the initializer.

[Back to Top](#)

## Registered Messages

In addition to retrieving messages from `tools.messages`, you can also generate messages directly from a registry. This allows defining multiple registries for different scopes or purposes, or using dependency injection to define different registries for development, test, and production environments.

```ruby
# Access the registry instance.
registry = SleepingKingStudios::Tools::Messages::Registry.global

strategy = registry.get('example.message_key')
message  = strategy&.call('example.message_key', default: nil)
```

First, we retrieve the strategy that defines messages for the requested key. If there is no matching strategy, `registry.get` will return `nil`.

Second, if we have a matching strategy, we then ask the strategy to generate the message using `strategy.call`. We also pass `default: nil` to ensure that `message` will be `nil` when either the strategy or the message template is not defined. (When called via `tools.messages`, this is automatically handled to generate an error message).

[Back to Top](#)

### Message Templates

For some use cases, you may need to access the raw message templates rather than the formatted values. For example, you may have custom message formatting logic, or you may store messages in a custom format, such as a Hash with optional properties. The `Strategy#get` and `Strategy#fetch` methods allow you to do just that.

```ruby
# Returns nil if the strategy does not define the message.
strategy.get('example.message_key')

# Returns 'Missing template "example.message_key"' if the strategy does not
# define the message.
strategy.fetch('example.message_key', 'Missing template "example.message_key"')

# Returns 'Missing template "example.message_key"' if the strategy does not
# define the message.
strategy.fetch('example.message_key') do |scoped_key, **options|
  message = 'Missing template "example.message_key"'
  message += " with options #{options.inspect}" unless options.empty?
  message
end
```

[Back to Top](#)

{% include breadcrumbs.md %}
