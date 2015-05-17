module Transproc
  # Transformation functions for Objects
  #
  # @example
  #   require 'transproc/object'
  #
  #   include Transproc::Helper
  #
  #   fn = t(:set_ivars, { name: 'Jane', age: 25 })
  #
  #   fn[Object.new]
  #   # => #<Object:0x007f73afe7d6f8 @name="Jane", @age=25>
  #
  # @api public
  module ObjectTransformations
    extend Functions

  end
end
