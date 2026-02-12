---
breadcrumbs:
  - name: Documentation
    path: './'
---

# Mixins

A `Mixin` implements recursive inheritance of both class and instance methods.

```ruby
require 'sleeping_king_studios/tools/toolbox/mixin'

module Widgets
  extend SleepingKingStudios::Tools::Toolbox::Mixin

  module ClassMethods
    def widget_types
      %w[gadget doohickey thingamabob]
    end
  end

  def widget?(widget_type)
    self.class.widget_types.include?(widget_type)
  end
end
```

The class reference for `SleepingKingStudios::Tools::Toolbox::Mixin` can be found in [Reference]({{site.baseurl}}/reference/sleeping-king-studios/tools/toolbox/mixin).

## Contents

- [Defining Mixins](#defining-mixins)
  - [Defining Instance Methods](#defining-instance-methods)
- [Including Mixins](#including-mixins)
- [Composing Mixins](#composing-mixins)

## Defining Mixins

To define a mixin, create a new `Module` and extend it with `Mixin`:

```ruby
module Widgets
  extend SleepingKingStudios::Tools::Toolbox::Mixin
end
```

### Defining Instance Methods

Because our mixin starts with a `Module`, we don't need to do anything special to define instance methods.

```ruby
module Widgets
  extend SleepingKingStudios::Tools::Toolbox::Mixin

  def widget?(widget_type)
    self.class.widget_types.include?(widget_type)
  end
end
```

In the above example, our `#widget?` instance method will be automatically available to any class in which we have included our `Widget` mixin.

### Defining Class Methods

Defining class methods requires an additional step, defining a `ClassMethods` module inside the mixin.

```ruby
module Widgets
  extend SleepingKingStudios::Tools::Toolbox::Mixin

  module ClassMethods
    def widget_types
      %w[gadget doohickey thingamabob]
    end
  end
end
```

When we include `Widgets` in a class or module, then `Widgets::ClassMethods` will be included in that class or module's singleton class, allowing us to use the `.widget_types` class method.

## Including Mixins

Once the mixin is defined, simply `include` it in a Class or Module like any other module.

```ruby
class StemBolt
  include Widgets
end

StemBolt.widget_types
#=> ['gadget', 'doohickey', 'thingamabob']

StemBolt.new.widget?('gadget')
#=>  true
```

As you can see, our instance methods are inherited from `Widget`, and our class methods are inherited from `Widget::ClassMethods`.

`Mixin` also supports inheritance using `Module.prepend`.

## Composing Mixins

Mixins can also be composed together, and `Mixin` defines special behavior when included in another `Mixin`. When you include a `Mixin` in another `Mixin`, instead of defining the class methods on the intermediate mixin, the class method are merged together and will be extended onto the final class or module.

```ruby
module WidgetBuilding
  extend  SleepingKingStudios::Tools::Toolbox::Mixin
  include Widgets

  module ClassMethods
    def build(widget_type)
      { widget_type: }
    end
  end
end

class GadgetFactory
  include WidgetBuilding
end

GadgetFactory.build('gadget')
#=> { widget_type: 'gadget' }

GadgetFactory.widget_types
#=> ['gadget', 'doohickey', 'thingamabob']

GadgetFactory.new.widget?('doohickey')
#=> true
```

In our above example, our `.widget_types` class method is extended onto `GadgetFactory`, not the intermediate mixin `WidgetBuilding`.

> *Warning:* This feature can cause unexpected behavior. When you need to extend class methods *onto a `Mixin` module*, use a traditional `.included` hook instead of another `Mixin`.

{% include breadcrumbs.md %}
