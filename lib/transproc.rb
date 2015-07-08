require 'transproc/version'
require 'transproc/function'
require 'transproc/functions'
require 'transproc/composer'
require 'transproc/error'
require 'transproc/store'
require 'transproc/registry'

module Transproc
  # Function registry
  #
  # @api private
  def self.functions
    @_functions ||= {}
  end

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
  def self.register(*args, &block)
    name, fn = *args
    if functions.include? name
      raise FunctionAlreadyRegisteredError, "Function #{name} is already defined"
    end
    functions[name] = fn || block
  end

  # Get registered function with provided name
  #
  # @param [Symbol] name The name of the registered function
  #
  # @api private
  def self.[](name, *args)
    fn = functions.fetch(name) { raise FunctionNotFoundError.new(name) }

    if args.any?
      fn.with(*args)
    else
      fn
    end
  end
end

require 'transproc/array'
require 'transproc/hash'

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
    fun = Transproc[fn, *args]
    case fun
    when Transproc::Function, Transproc::Composite then fun
    else Transproc::Function.new(fun, args: args)
    end
  end
end
