module Transproc
  # Transproc helper that adds `t` method as a shortcut for `Transproc` method
  #
  # @example
  #   include Transproc::Helper
  #
  #   t(:to_string)
  #
  # @api public
  module Helper
    # @see Transproc
    #
    # @api public
    def t(*args, &block)
      Transproc(*args, &block)
    end
  end

  # Helper extension handy for composing many functions in multiple steps
  #
  # @example
  #   include Transproc::Composer
  #
  #   fn = compose do |fns|
  #     fns << t(:map_array, t(:symbolize_keys))
  #     fns << t(:map_array, t(:nest, :address, [:city, :zipcode]))
  #   end
  #
  #   fn.call [{ 'city' => 'NYC', 'zipcode' => '123' }]
  #   # => [{ address: { city: 'NYC', zipcode: '123' }]
  #
  # @api public
  module Composer
    include Helper

    # @api private
    class Factory
      attr_reader :fns, :default

      # @api private
      def initialize(default = nil)
        @fns = []
        @default = default
      end

      # @api private
      def <<(other)
        fns.concat(Array(other).compact)
        self
      end

      # @api private
      def to_fn
        fns.reduce(:+) || default
      end
    end

    # Gather and compose functions and fall-back to a default one if provided
    #
    # @example
    #   include Transproc::Composer
    #
    #   fn = compose(-> v { v }) do |fns|
    #     fns << t(:to_string) if something
    #   end
    #
    #   fn[1] # => "1"
    #
    # @see Composer
    #
    # @api public
    def compose(default = nil)
      factory = Factory.new(default)
      yield(factory)
      factory.to_fn
    end
  end
end
