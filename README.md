[gem]: https://rubygems.org/gems/transproc
[travis]: https://travis-ci.org/solnic/transproc
[gemnasium]: https://gemnasium.com/solnic/transproc
[codeclimate]: https://codeclimate.com/github/solnic/transproc
[coveralls]: https://coveralls.io/r/solnic/transproc
[inchpages]: http://inch-ci.org/github/solnic/transproc

# Transproc

[![Gem Version](https://badge.fury.io/rb/transproc.svg)][gem]
[![Build Status](https://travis-ci.org/solnic/transproc.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/solnic/transproc.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/solnic/transproc/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/solnic/transproc/badges/coverage.svg)][codeclimate]
[![Inline docs](http://inch-ci.org/github/solnic/transproc.svg?branch=master)][inchpages]

Transproc is a small library that allows you to compose procs into a functional pipeline using left-to-right function composition.

The approach came from Functional Programming, where simple functions are composed into more complex functions in order to transform some data. It works like `|>` in Elixir
or `>>` in F#.

`transproc` provides a mechanism to define and compose transformations,
along with a number of built-in transformations.

It's currently used as the data mapping backend in [Ruby Object Mapper](http://rom-rb.org).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'transproc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install transproc

## Basics

Simple transformations are defined as easy as:

```ruby
increament = Transproc::Function.new(-> (data) { data + 1 })
increament[1] # => 2
```

It's easy to compose transformations:

```ruby
to_string = Transproc::Function.new(:to_s.to_proc)
(increament >> to_string)[1] => '2'
```

It's easy to pass additional arguments to transformations:

```ruby
append = Transproc::Function.new(-> (value, suffix) { value + suffix })
append_bar = append.with('_bar')
append_bar['foo'] # => foo_bar
```

Or even accept another transformation as an argument:

```ruby
map_array = Transproc::Function.new(-> (array, fn) { array.map(&fn) })
map_array.with(to_string).call([1, 2, 3]) # => ['1', '2', '3']
```

To improve this low-level definition, you can use class methods
with `Transproc::Registry`:

```ruby
M = Module.new do
  extend Transproc::Registry

  def self.to_string(value)
    value.to_s
  end

  def self.map_array(array, fn)
    array.map(&fn)
  end
end
M[:map_array, M[:to_string]].([1, 2, 3]) # => ['1', '2', '3']
```

### Built-in transformations

`transproc` comes with a lot of built-in functions. They come in the form of
modules with class methods, which you can import into a registry:

* [Coercions](http://www.rubydoc.info/gems/transproc/Transproc/Coercions)
* [Array transformations](http://www.rubydoc.info/gems/transproc/Transproc/ArrayTransformations)
* [Hash transformations](http://www.rubydoc.info/gems/transproc/Transproc/HashTransformations)
* [Class transformations](http://www.rubydoc.info/gems/transproc/Transproc/ClassTransformations)
* [Proc transformations](http://www.rubydoc.info/gems/transproc/Transproc/ProcTransformations)
* [Conditional](http://www.rubydoc.info/gems/transproc/Transproc/Conditional)
* [Recursion](http://www.rubydoc.info/gems/transproc/Transproc/Recursion)

You can import everything with:

```ruby
module T
  extend Transproc::Registry

  import Transproc::Coercions
  import Transproc::ArrayTransformations
  import Transproc::HashTransformations
  import Transproc::ClassTransformations
  import Transproc::ProcTransformations
  import Transproc::Conditional
  import Transproc::Recursion
end
T[:to_string].call(:abc) # => 'abc'
```

Or import selectively with:

```ruby
module T
  extend Transproc::Registry

  import :to_string, from: Transproc::Coercions, as: :stringify
end
T[:stringify].call(:abc) # => 'abc'
T[:to_string].call(:abc)
# => Transproc::FunctionNotFoundError: No registered function T[:to_string]
```

### Transformer

Transformer is a class-level DSL for composing transformation pipelines,
for example:

```ruby
T = Class.new(Transproc::Transformer) do
  map_array do
    symbolize_keys
    rename_keys user_name: :name
    nest :address, [:city, :street, :zipcode]
  end
end

T.new.call(
  [
    { 'user_name' => 'Jane',
      'city' => 'NYC',
      'street' => 'Street 1',
      'zipcode' => '123'
    }
  ]
)
# => [{:name=>"Jane", :address=>{:city=>"NYC", :street=>"Street 1", :zipcode=>"123"}}]
```

It converts every method call to its corresponding transformation, and joins
these transformations into a transformation pipeline (a transproc).

## Transproc Example Usage

``` ruby
require 'json'
require 'transproc/all'

# create your own local registry for transformation functions
module Functions
  extend Transproc::Registry
end

# import necessary functions from other transprocs...
module Functions
  # import all singleton methods from a module/class
  import Transproc::HashTransformations
  import Transproc::ArrayTransformations
end

# ...or from any external library
require 'inflecto'
module Functions
  # import only necessary singleton methods from a module/class
  # and rename them locally
  import :camelize, from: Inflecto, as: :camel_case
end

def t(*args)
  Functions[*args]
end

# use imported transformation
transformation = t(:camel_case)

transformation.call 'i_am_a_camel'
# => "IAmACamel"

transformation = t(:map_array, t(:symbolize_keys)
 .>> t(:rename_keys, user_name: :user))
 .>> t(:wrap, :address, [:city, :street, :zipcode])

transformation.call(
  [
    { 'user_name' => 'Jane',
      'city' => 'NYC',
      'street' => 'Street 1',
      'zipcode' => '123' }
  ]
)
# => [{:user=>"Jane", :address=>{:city=>"NYC", :street=>"Street 1", :zipcode=>"123"}}]

# define your own composable transformation easily
transformation = t(-> v { JSON.dump(v) })

transformation.call(name: 'Jane')
# => "{\"name\":\"Jane\"}"

# ...or add it to registered functions via singleton method of the registry
module Functions
  # ...

  def self.load_json(v)
    JSON.load(v)
  end
end

# ...or add it to registered functions via .register method
Functions.register(:load_json) { |v| JSON.load(v) }

transformation = t(:load_json) >> t(:map_array, t(:symbolize_keys))

transformation.call('[{"name":"Jane"}]')
# => [{ :name => "Jane" }]
```

## Credits

This project is inspired by the work of following people:

* [Markus Schirp](https://github.com/mbj) and [morpher](https://github.com/mbj/morpher) project
* [Josep M. Bach](https://github.com/txus) and [kleisli](https://github.com/txus/kleisli) project

## Contributing

1. Fork it ( https://github.com/solnic/transproc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
