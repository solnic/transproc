# Transproc

Experimental functional transformations for Ruby.

![I have no idea what I'm doing](http://thumbpress.com/wp-content/uploads/2013/05/I-Have-No-Idea-What-Im-Doing-1.jpg)

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
transformation = Transproc(:symbolize_keys) + Transproc(:map, user_name: :name))

# call the function
transformation['user_name' => 'Jane']
# => {:name=>"Jane"}
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/transproc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
