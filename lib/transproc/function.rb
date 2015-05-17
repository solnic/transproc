require 'transproc/composite'

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
    def call(*value)
      fn[*value, *args]
    rescue => ex
      raise MalformedInputError.new(@fn, value, ex)
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
      Composite.new(self, other)
    end
    alias_method :+, :compose
    alias_method :>>, :compose

    # Return a simple AST representation of this function
    #
    # @return [Array]
    #
    # @api public
    def to_ast
      identifier = fn.is_a?(::Proc) ? fn : fn.name
      [identifier, args]
    end
  end
end
