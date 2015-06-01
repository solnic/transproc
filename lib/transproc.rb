require 'transproc/version'
require 'transproc/function'
require 'transproc/functions'
require 'transproc/composer'
require 'transproc/error'

module Transproc
  module_function

  # Register a new function
  #
  # @example
  #   Transproc.register(:to_json, -> v { v.to_json })
  #
  #   Transproc(:map_array, Transproc(:to_json))
  #
  #
  # @return [Function]
  #
  # @api public
  def register(*args, &block)
    name, fn = *args
    if functions.include?(name)
      raise FunctionAlreadyRegisteredError, "function #{name} is already defined"
    end
    functions[name] = fn || block
  end

  # Get registered function with provided name
  #
  # @param [Symbol] name The name of the registered function
  #
  # @api private
  def [](name)
    functions.fetch(name) {
      raise FunctionNotFoundError, "no registered function for #{name}"
    }
  end

  # Function registry
  #
  # @api private
  def functions
    @_functions ||= {}
  end
end

# Access registered functions
#
# @example
#   Transproc(:map_array, Transproc(:to_string))
#
#   Transproc(:to_string) >> Transproc(-> v { v.upcase })
#
# @param [Symbol,Proc] fn The name of the registered function or an anonymous proc
# @param [Array] args Optional addition args that a given function may need
#
# @return [Function]
#
# @api public
def Transproc(fn, *args)
  case fn
  when Proc then Transproc::Function.new(fn, args: args)
  when Symbol
    fun = Transproc[fn]
    case fun
    when Transproc::Function, Transproc::Composite then fun
    else Transproc::Function.new(fun, args: args)
    end
  end
end
