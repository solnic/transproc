require 'transproc/version'
require 'transproc/function'

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
end

def Transproc(fn, *args)
  case fn
  when Proc then Transproc::Function.new(fn, args)
  when Symbol then Transproc::Function.new(Transproc[fn], args)
  end
end
