module Transproc
  class Function
    attr_reader :fn, :args

    def initialize(fn, options = {})
      @fn = fn
      @args = options.fetch(:args) { [] }
    end

    def name
      fn.name
    end

    def call(value)
      fn[value, *args]
    end
    alias_method :[], :call

    def compose(other)
      Composed.new(fn, args: args, right: other)
    end
    alias_method :+, :compose
    alias_method :>>, :compose

    class Composed < Function
      alias_method :left, :fn

      attr_reader :right

      def initialize(fn, options = {})
        super
        @right = options.fetch(:right)
      end

      def name
        [super, right.name]
      end

      def call(value)
        right[left[value, *args]]
      end
      alias_method :[], :call

      def compose(other)
        Composed.new(self, right: other)
      end
      alias_method :+, :compose
      alias_method :>>, :compose
    end
  end
end
