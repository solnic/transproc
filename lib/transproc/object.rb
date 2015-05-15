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

    # Set instance variables from the hash argument (key/value pairs) on the object
    #
    # @example
    #   Transproc(:set_ivars, { name: 'Jane', age: 25 })[Object.new]
    #   # => #<Object:0x007f411d06a210 @name="Jane", @age=25>
    #
    # @param [Object]
    #
    # @return [Object]
    #
    # @api public
    def set_ivars(object, ivar_hash)
      set_ivars!(object.dup, ivar_hash)
    end

    # Same as `:set_ivars` but mutates the object
    #
    # @see ObjectTransformations.set_ivars
    #
    # @api public
    def set_ivars!(object, ivar_hash)
      ivar_hash.each_with_object(object) do |(ivar_name, ivar_value), obj|
        obj.instance_variable_set("@#{ivar_name}", ivar_value)
      end
    end
  end
end
