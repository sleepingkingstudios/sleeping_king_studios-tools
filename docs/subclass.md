---
breadcrumbs:
  - name: Documentation
    path: './'
---

# Subclass

The `Subclass` mixin is used to define subclasses with partially applied constructor parameters.

```ruby
class Character
  extend SleepingKingStudios::Tools::Toolbox::Subclass

  def initialize(*traits, **attributes)
    @attributes = @attributes
    @traits     = traits
  end

  attr_reader :attributes

  attr_reader :traits
end

Bard = Character.subclass(:charismatic, :musical)

aoife = Bard.new(:sorcerous)
aoife.traits
#=> [:charismatic, :musical, :sorcerous]
```

The class reference for `SleepingKingStudios::Tools::Toolbox::Subclass` can be found in [Reference]({{site.baseurl}}/reference/sleeping-king-studios/tools/toolbox/subclass).

## Contents

- [Custom Subclasses](#custom-subclasses)
  - [Constructor Arguments](#constructor-arguments)
  - [Constructor Keywords](#constructor-keywords)
  - [Constructor Block](#constructor-block)

## Custom Subclasses

Add `Subclass` mixin to a `Class` to enable defining custom subclasses.

```ruby
class Character
  extend SleepingKingStudios::Tools::Toolbox::Subclass

  def initialize(*traits)
    @traits = traits
  end

  attr_reader :traits
end
```

The `.subclass(*arguments, **keywords, &block)` class method defines a new subclass, and the given parameters will be applied when calling `.new` on the defined subclass.

```ruby
Bard = Character.subclass(:charismatic, :musical)
```

### Constructor Arguments

Arguments passed to `.subclass()` are prepended to the arguments array when instantiating the subclass.

```ruby
fighter = Character.new(:armored, :strong)
fighter.traits
#=> [:armored, :strong]

Bard = Character.subclass(:charismatic, :musical)
bard = Bard.new
bard.traits
#=> [:charismatic, :musical]

aoife = Bard.new(:sorcerous)
aoife.traits
#=> [:charismatic, :musical, :sorcerous]
```

In the above example, the arguments `:charismatic` and `:musical` are passed from the `Bard` subclass, after which `:sorcerous` is passed from `Bard.new`.

### Constructor Keywords

The keywords hash is merged into any keywords passed to `.subclass()` when instantiating the subclass.

```ruby
fighter = Character.new(might: 5, magic: 1, mind: 3)
fighter.attributes
#=> { might: 5, magic: 1, mind: 3 }

MageKnight  = Character.subclass(might: 4, magic: 3)
mage_knight = MageKnight.new(magic: 5, mind: 2)
mage_knight.attributes
#=> { might: 4, magic: 5, mind: 2 }
```

In the above example, the keywords `might: 4` and `magic: 3` are passed from the `MageKnight` subclass, while `magic: 5` and `mind: 2` are passed from `MageKnight.new`. The `magic: 5` passed directly to the constructor overrides the value from the subclass.

### Constructor Block

If a block is passed to `.subclass()`, that block will be passed when instantiating the subclass, unless another block is passed to `#initialize`.

```ruby
class Greeter
  def initialize(&block)
    @block = block
  end

  def greet
    @block.call
  end
end

Greeter.new { puts 'Greetings, programs!' }.greet
#=> writes "Greetings, programs!" to STDOUT

SpaceGreeter = Greeter.subclass { puts 'Greetings, starfighter!' }
SpaceGreeter.new.greet
#=> writes "Greetings, starfighter!" to STDOUT

SpaceGreeter.new { puts 'Greetings, programs!' }.greet
#=> writes "Greetings, programs!" to STDOUT
```

In the above example, the `SpaceGreeter` will print `"Greetings, starfighter!"` to STDOUT unless another block is passed to the constructor.

{% include breadcrumbs.md %}
