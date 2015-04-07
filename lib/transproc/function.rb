module Transproc
  class Function
    attr_reader :fn, :args

    def initialize(fn, args = [])
      @fn = fn
      @args = args
    end

    def call(value)
      fn[value, *args]
    end
    alias_method :[], :call

    def compose(other)
      self.class.new(-> *input { other[fn[*input]] }, args)
    end
    alias_method :+, :compose
    alias_method :>>, :compose
  end
end
