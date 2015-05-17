module Transproc
  # Transformation functions for Classes
  #
  # @example
  #   require 'transproc/class'
  #
  #   include Transproc::Helper
  #
  #   fn = t(:constructor_inject, 'User', :name, :age)
  #
  #   fn[Struct]
  #   # => Struct::User
  #
  # @api public
  module ClassTransformations
    extend Functions

    # Inject given arguments into the constructor of the class
    #
    # @example
    #   Transproct(:constructor_inject, 'User', :name, :age)[Struct]
    #   # => Struct::User
    #
    # @param [Class]
    #
    # @return [Mixed]
    #
    # @api public
    def constructor_inject(*args, klass)
      klass.new(*args)
    end
  end
end
