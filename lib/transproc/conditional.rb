module Transproc
  # Conditional transformation functions
  #
  # @example
  #   require 'transproc/conditional'
  #
  #   include Transproc::Helper
  #
  #   fn = t(:guard, -> s { s.is_a?(::String) }, -> s { s.to_sym })
  #
  #   [fn[2], fn['Jane']]
  #   # => [2, :Jane]
  #
  # @api public
  module Conditional
    extend Functions

    # Does nothing and returns a value
    #
    # @example
    #   fn = t(:itself)
    #   fn[:foo] # => :foo
    #
    # @param [Object] value
    #
    # @return [Object]
    #
    # @api public
    def itself(value)
      value
    end

    # Negates the result of transformation
    #
    # @example
    #   fn = t(:not, -> value { value.is_a? ::String })
    #   fn[:foo]  # => true
    #   fn["foo"] # => false
    #
    # @param [Object] value
    # @param [Proc] fn
    #
    # @return [Boolean]
    #
    # @api public
    def not(value, fn)
      !fn[value]
    end

    # Applies on of transformations depending on whether predicate returns true
    #
    # @example
    #   fn = t(:iif, -> v { v[/\a/] }, -> v { v.downcase }, -> v { v.upcase })
    #   fn["Foo"] # => "FOO"
    #   fn["Bar"] # => "bar"
    #
    # @param [Object] value
    # @param [Proc] predicate
    # @param [Proc] on_success
    # @param [Proc] on_fail
    #
    # @return [Object]
    #
    # @api public
    def iif(value, predicate, on_success, on_fail)
      predicate[value] ? on_success[value] : on_fail[value]
    end

    # Apply the transformation function to subject if the predicate returns true, or return un-modified
    #
    # @example
    #   [2, 'Jane'].map do |subject|
    #     Transproc(:guard, -> s { s.is_a?(::String) }, -> s { s.to_sym })[subject]
    #   end
    #   # => [2, :Jane]
    #
    # @param [Mixed]
    #
    # @return [Mixed]
    #
    # @api public
    def guard(value, predicate, fn)
      iif(value, predicate, fn, Transproc(:itself))
    end

    # Calls a function when type-check passes
    #
    # @example
    #   fn = Transproc(:is, Array, -> arr { arr.map(&:upcase) })
    #   fn.call(['a', 'b', 'c']) # => ['A', 'B', 'C']
    #
    #   fn = Transproc(:is, Array, -> arr { arr.map(&:upcase) })
    #   fn.call('foo') # => "foo"
    #
    # @param [Object]
    # @param [Class]
    # @param [Proc]
    #
    # @return [Object]
    #
    # @api public
    def is(value, type, fn)
      guard(value, -> val { val.is_a?(type) }, fn)
    end
  end
end
