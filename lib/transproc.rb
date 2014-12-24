require "transproc/version"

class Transproc
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

def Transproc(fn)
  Transproc.new(fn)
end
