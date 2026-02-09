---
breadcrumbs:
  - name: Documentation
    path: './'
---

# Constant Maps

A `ConstantMap` provides an enumerable interface for defining a group of constants.

```ruby
UserRoles = ConstantMap.new(
  GUEST: 'guest',
  USER:  'user',
  ADMIN: 'admin'
).freeze

UserRoles::GUEST
#=> 'guest'

UserRoles.user
#=> 'user'

UserRoles.all
#=> { GUEST: 'guest', USER: 'user', ADMIN: 'admin' }
```

The class reference for `SleepingKingStudios::Tools::Toolbox::ConstantMap` can be found in [Reference](./reference/sleeping-king-studios/tools/toolbox/constant-map).

## Contents

- [Accessing Values](#accessing-values)
- [Delegated Methods](#delegated-methods)

## Accessing Values

The defined values can be accessed a few different ways:

- As a nested constant:

  ```ruby
  UserRoles::GUEST
  #=> 'guest'
  ```

- As a reader method:

  ```ruby
  UserRoles.user
  #=> 'user'
  ```

- As a Hash:

  ```ruby
  UserRoles.all
  #=> { GUEST: 'guest', USER: 'user', ADMIN: 'admin' }
  ```

- Using Hash methods:

  ```ruby
  UserRoles.values
  #=> ['guest', 'user', 'admin']
  ```

## Delegated Methods

Each `ConstantMap` defines the following `Hash` methods:

- `#each`
- `#each_key`
- `#each_pair`
- `#each_value`
- `#keys`
- `#values`

The data can also be accessed as a read-only `Hash` using `#to_h`.

{% include breadcrumbs.md %}
