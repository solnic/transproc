require 'transproc/version'
require 'transproc/function'
require 'transproc/composer'

module Transproc
  module_function

  def register(*args, &block)
    name, fn = *args
    functions[name] = fn || block
  end

  def register_from(mod)
    (mod.public_methods - Module.public_methods).each do |meth|
      Transproc.register(meth, mod.method(meth))
    end
  end

  def [](name)
    functions.fetch(name)
  end

  def functions
    @_functions ||= {}
  end
end

def Transproc(fn, *args)
  case fn
  when Proc then Transproc::Function.new(fn, args)
  when Symbol then Transproc::Function.new(Transproc[fn], args)
  end
end
