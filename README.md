# Transproc

Functional transformations for Ruby. It's currently used as one of the data
mapping backends in [Ruby Object Mapper](http://rom-rb.org).

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
require 'transproc/hash'

# compose transformation functions
transformation = Transproc(:symbolize_keys) + Transproc(:map_hash, user_name: :name))

# call the function
transformation['user_name' => 'Jane']
# => {:name=>"Jane"}
```

## Credits

This project is inspired by the work of following people:

* [Markus Schirp](https://github.com/mbj) [morpher](https://github.com/mbj/morpher) project
* [Josep M. Bach](https://github.com/txus) and [kleisli](https://github.com/txus/kleisli) project

## Contributing

1. Fork it ( https://github.com/solnic/transproc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
