---
breadcrumbs:
  - name: Documentation
    path: '/'
---

# HeritableData

The `HeritableData` tool allows defining `Data` subclasses that can pass down their members and methods to descendents.

```ruby
require 'sleeping_king_studios/tools/toolbox/heritable_data'

Event = SleepingKingStudios::Tools::Toolbox::HeritableData.define(:type) do
  def event_type = type
end

UserEvent = Event.define(:user) do
  def admin? = user&.[:role] == 'admin'
end

user  = { name: 'Alan Bradley', role: 'user' }
event = UserEvent.new(type: 'events.user.log_in', user:)

event.is_a?(Event)
#=> true
event.type
#=> 'events.user.log_in'
event.event_type
#=> 'events.user.log_in'
event.admin?
#=> false
```

The class reference for `SleepingKingStudios::Tools::Toolbox::HeritableData` can be found in [Reference](./reference/sleeping-king-studios/tools/toolbox/heritable-data).

## Contents

- [Defining Heritable Data](#defining-heritable-data)
- [Subclassing Heritable Data](#subclassing-heritable-data)
- [Reflection And Comparison](#reflection-and-comparison)
- [Defining Class Methods](#defining-class-methods)
- [Documenting Data Classes](#documenting-data-classes)

## Defining Heritable Data

To define a heritable `Data` class, use the `HeritableData.define` method.

```ruby
Event = SleepingKingStudios::Tools::Toolbox::HeritableData.define(:type) do
  def event_type = type
end

Event.superclass
#=> Data
Event.members
#=> [:type]

event = Event.new(type: 'events.generic_event')
event.event_type
#=> 'events.generic_event'
```

`HeritableEvent.define` returns a newly created `Data` subclass.

Just like when calling `Data.define`, you can pass the desired member names and an optional block defining additional methods or other functionality. In the above example, we define a new `Data` subclass with the `:type` property, and define an additional `#event_type` method.

[Back To Top](#)

## Subclassing Heritable Data

So far, we've defined our top-level heritable `Data` class. Next, we want to define child classes that inherit the members and methods from our top-level `Event` class. To do so, `HeritableData` extends the `.define()` class method to apply to our `Event` class as well:

```ruby
UserEvent = Event.define(:user) do
  def admin? = user&.[:role] == 'admin'
end

UserEvent.superclass
#=> Event
UserEvent.members
#=> [:type, :user]

user  = { name: 'Alan Bradley', role: 'user' }
event = UserEvent.new(type: 'events.user.log_in', user:)
event.event_type
#+> 'events.user.log_in'
event.admin?
#=> false
```

By calling `Event.define()`, we define a new `Event` subclass. In addition to the properties and methods defined for `Event`, our `UserEvent` class includes the newly added `:user` property and the `#admin?` method.

We can continue defining subclasses on `UserEvent` as well by calling `UserEvent.define`:

```ruby
LoginEvent = UserEvent.define(:timestamp)

LoginEvent.superclass
#=> UserEvent
LoginEvent.members
#=> [:type, :user, :timestamp]
```

Our `LoginEvent` includes the `:type` property from `Event`, the `:user` property from `UserEvent`, and the newly added `:timestamp` property.

[Back To Top](#)

## Reflection And Comparison

`Data` subclasses defined using `HeritableData.define` use proper Ruby inheritance. This means you can compare data classes just like any other Ruby class hierarchy, and you can use methods like `#is_a?` and the case comparison operator `#===` to check whether an object is an instance of a `Data` subclass or any of its ancestors.

```ruby
Event = SleepingKingStudios::Tools::Toolbox::HeritableData.define(:type) do
  def event_type = type
end

UserEvent = Event.define(:user) do
  def admin? = user&.[:role] == 'admin'
end

LoginEvent = UserEvent.define(:timestamp)

user  = { name: 'Alan Bradley', role: 'user' }
event = UserEvent.new(type: 'events.user.log_in', user:)
```

You can use the `.<=>(other)` method and its siblings to compare `Data` classes.

```ruby
LoginEvent < Data
#=> true
LoginEvent < Event
#=> true
LoginEvent < UserEvent
#=> true
LoginEvent < String
#=> nil
```

You can use the `#is_a?(type)` method (or `#kind_of?`) to check if an object is an instance of a `Data` type or any of its parents.

```
event.is_a?(Data)
#=> true
event.is_a?(Event)
#=> true
event.is_a?(UserEvent)
#=> true
event.is_a?(LoginEvent)
#=> false
```

Finally, you can use the `.===(other)` case comparison operator to match on `Data` instances.

```ruby
message =
  case event
  when LoginEvent
    'A user logged in.'
  when UserEvent
    'A user did something.'
  when Event
    'Something happened.'
message
#=> 'A user did something.'
```

[Back To Top](#)

## Defining Class Methods

The block passed to `HeritableData.define` is a class body, just like `Data.define`. This means you can `include` Modules or define class methods directly in the block, and it works the same way as any other class declaration.

```ruby
PriorityEvent = SleepingKingStudios::Tools::Toolbox::HeritableData.define(:type, :priority) do
  include Comparable

  class << self
    def metadata = { name: }
  end

  def <=>(other)
    priority <=> other.priority
  end
end

PriorityEvent.metadata
#=> { name: 'PriorityEvent' }

dust_event    = PriorityEvent.new(type: 'dust_console',  priority: 1)
coolant_event = PriorityEvent.new(type: 'check_coolant', priority: 10)

dust_event < coolant_event
#=> true
```

[Back To Top](#)

## Documenting Data Classes

`Data` classes are not well supported in <a href="https://yardoc.org/" target="_blank">YARD</a>. The recommended approach for a codebase documented using `YARD` is to define the class in two steps:

```ruby
Event = SleepingKingStudios::Tools::Toolbox::HeritableData.define(:type)

# A domain event with specified type.
#
# @!attribute [r] type
#   @return [String] the event type.
class Event < Data
  # An alternative method for accessing the event type.
  def event_type = type
end
```

In the above example, we use `HeritableData.define` to define the `Event` class and its members, in this case `:type`.

We then use a `class Event` statement to declare the `Event` class in a way that is recognizable by `YARD`. Because the class members are set in the `define` call, `YARD` cannot automatically generate method documentation for them. Therefore, we use the `@!attribute` directive to document the class members (remember, a `Data` object's members are always read-only).

Similarly, we can use the same process to document a `Data` subclass:

```ruby
UserEvent = Event.define(:user)

# An event performed by a specific user.
#
# @!attribute [r] user
#   @return [User] the user who performed the event.
class UserEvent < Event
  # @return [true, false] true if the user is an admin, otherwise false.
  def admin? = user&.[:role] == 'admin'
end
```

Because we use a traditional class declaration, `YARD` can detect that `UserEvent` is a subclass of `Event` and inherits its attributes and methods.

[Back To Top](#)
