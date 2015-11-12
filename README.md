[gem]: https://rubygems.org/gems/transproc
[travis]: https://travis-ci.org/solnic/transproc
[gemnasium]: https://gemnasium.com/solnic/transproc
[codeclimate]: https://codeclimate.com/github/solnic/transproc
[coveralls]: https://coveralls.io/r/solnic/transproc
[inchpages]: http://inch-ci.org/github/solnic/transproc

# Transproc [![Join the chat at https://gitter.im/solnic/transproc](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/solnic/transproc)

[![Gem Version](https://badge.fury.io/rb/transproc.svg)][gem]
[![Build Status](https://travis-ci.org/solnic/transproc.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/solnic/transproc.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/solnic/transproc/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/solnic/transproc/badges/coverage.svg)][codeclimate]
[![Inline docs](http://inch-ci.org/github/solnic/transproc.svg?branch=master)][inchpages]

Transproc is a small library that allows you to compose methods into a functional pipeline using left-to-right function composition. It works like `|>` in Elixir or `>>` in F#.

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

## Usage

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
