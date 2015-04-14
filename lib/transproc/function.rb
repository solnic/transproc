module Transproc
  # Transformation proc wrapper allowing composition of multiple procs into
  # a data-transformation pipeline.
  #
  # This is used by Transproc to wrap registered methods.
  #
  # @api private
  class Function
    # Wrapped proc or another composite function
    #
    # @return [Proc,Composed]
    #
    # @api private
    attr_reader :fn

    # Additional arguments that will be passed to the wrapped proc
    #
    # @return [Array]
    #
    # @api private
    attr_reader :args

    # @api private
    def initialize(fn, options = {})
      @fn = fn
      @args = options.fetch(:args) { [] }
    end

    # Call the wrapped proc
    #
    # @param [Object] value The input value
    #
    # @alias []
    #
    # @api public
    def call(value)
      fn[value, *args]
    end
    alias_method :[], :call

    # Compose this function with another function or a proc
    #
    # @param [Proc,Function]
    #
    # @return [Composite]
    #
    # @alias :>>
    #
    # @api public
    def compose(other)
      Composite.new(fn, args: args, right: other)
    end
    alias_method :+, :compose
    alias_method :>>, :compose

    # @api public
    def name
      fn.name
    end

    # Composition of two functions
    #
    # @api private
    class Composite < Function
      alias_method :left, :fn

      # @return [Proc]
      #
      # @api private
      attr_reader :right

      # @api private
      def initialize(fn, options = {})
        super
        @right = options.fetch(:right)
      end

      # Call right side with the result from the left side
      #
      # @param [Object] value The input value
      #
      # @return [Object]
      #
      # @api public
      def call(value)
        right[left[value, *args]]
      end
      alias_method :[], :call

      # @see Function#compose
      #
      # @api public
      def compose(other)
        Composite.new(self, right: other)
      end
      alias_method :+, :compose
      alias_method :>>, :compose

      def name
        [super, right.name]
      end
    end
  end
end
