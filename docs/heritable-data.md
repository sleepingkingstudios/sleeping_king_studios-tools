---
breadcrumbs:
  - name: Documentation
    path: './'
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
#=> Data
UserEvent.members
#=> [:type, :user]

user  = { name: 'Alan Bradley', role: 'user' }
event = UserEvent.new(type: 'events.user.log_in', user:)
event.event_type
#+> 'events.user.log_in'
event.admin?
#=> false
```

By calling `Event.define()`, we define a new `Data` subclass that also includes the properties and methods defined for `Event`. Our `UserEvent` class includes the `:type` property from `Event` as well as the newly added `:user` property. It also includes the `#event_type` helper method from `Event`.

We can continue defining subclasses on `UserEvent` as well by calling `UserEvent.define`:

```ruby
LoginEvent = UserEvent.define(:timestamp)

LoginEvent.superclass
#=> Data
LoginEvent.members
#=> [:type, :user, :timestamp]
```

Our `LoginEvent` includes the `:type` property from `Event`, the `:user` property from `UserEvent`, and the newly added `:timestamp` property.

[Back To Top](#)

## Reflection And Comparison

`Data` subclasses defined using `HeritableData.define` will always have `Data` as their superclass. However, `HeritableData` extends Ruby methods used for reflecting on and comparing objects to simulate the defined class hierarchy.

This means you can use `#is_a?` to check a data object's ancestors, compare data class inheritance using `.<=>` and its siblings, and you can use data objects in `case` statements that compare the object to its parent `Data` classes.

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

The easiest way to define class methods is by redefining the `included` hook:

```ruby
module Events
  module ClassMethods
    def metadata = { name: }
  end
end

Event = SleepingKingStudios::Tools::Toolbox::HeritableData.define(:type) do
  class << self
    private

    def included(other)
      super

      other.extend(Events::ClassMethods)
    end
  end
end

UserEvent = Event.define(:user)

Event.metadata
#=> { name: 'Event' }

UserEvent.metadata
#=> { name: 'UserEvent' }
```

In the above example, we redefine the `included` hook to also extend the `Events::ClassMethods` onto `Event` and each `Event` subclass.

One potential pitfall to be aware of: a `Data.define` block doesn't create a new Ruby *namespace*, meaning that constants defined inside the block will actually be defined on the parent namespace. That means that defining `ClassMethods` inside of the `define` block won't work correctly unless done using the `const_set` method (in which case, watch out for block precedence). Defining the module ahead of time (as we do in the above example) is the safest approach.

[Back To Top](#)

{% include breadcrumbs.md %}
