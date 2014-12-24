require "transproc/version"

module Transproc
  def self.register(*args, &block)
    name, fn = *args
    functions[name] = fn || block
  end

  def self.functions
    @_functions ||= {}
  end

  def self.[](name)
    functions.fetch(name)
  end

  class Function
    attr_reader :fn

    def initialize(fn)
      @fn = fn
    end

    def call(value)
      fn[value]
    end
    alias_method :[], :call

    def compose(other)
      self.class.new(-> value { other[fn[value]] })
    end
    alias_method :+, :compose
  end
end

def Transproc(fn)
  case fn
  when Proc then Transproc::Function.new(fn)
  when Symbol then Transproc::Function.new(Transproc[fn])
  end
end
