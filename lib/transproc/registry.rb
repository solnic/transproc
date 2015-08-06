# encoding: utf-8

module Transproc
  # Container to define transproc functions in, and access them via `[]` method
  # from the outside of the module
  #
  # @example
  #   module FooMethods
  #     extend Transproc::Registry
  #
  #     def self.foo(name, prefix)
  #       [prefix, '_', name].join
  #     end
  #   end
  #
  #   fn = FooMethods[:foo, 'baz']
  #   fn['qux'] # => 'qux_baz'
  #
  #   module BarMethods
  #     extend FooMethods
  #
  #     def self.bar(*args)
  #       foo(*args).upcase
  #     end
  #   end
  #
  #   fn = BarMethods[:foo, 'baz']
  #   fn['qux'] # => 'qux_baz'
  #
  #   fn = BarMethods[:bar, 'baz']
  #   fn['qux'] # => 'QUX_BAZ'
  #
  # @api public
  module Registry
    # Builds the transformation
    #
    # @param [Proc, Symbol] fn
    #   A proc, a name of the module's own function, or a name of imported
    #   procedure from another module
    # @param [Object, Array] args
    #   Args to be carried by the transproc
    #
    # @return [Transproc::Function]
    #
    # @alias :t
    #
    def [](fn, *args)
      Function.new(fetch(fn), args: args, name: fn)
    end
    alias_method :t, :[]

    # Imports either a method (converted to a proc) from another module, or
    # all methods from that module.
    #
    # If the external module is a registry, looks for its imports too.
    #
    # @overload import(source)
    #   Loads all methods from the source object
    #
    #   @param [Object] source
    #
    # @overload import(*names, **options)
    #   Loads selected methods from the source object
    #
    #   @param [Array<Symbol>] names
    #   @param [Hash] options
    #   @options options [Object] :from The source object
    #
    # @overload import(name, **options)
    #   Loads selected methods from the source object
    #
    #   @param [Symbol] name
    #   @param [Hash] options
    #   @options options [Object] :from The source object
    #   @options options [Object] :as The new name for the transformation
    #
    # @return [itself] self
    #
    # @alias :import
    #
    def import(*args)
      @store = store.import(*args)
      self
    end
    alias_method :uses, :import

    # The store of procedures imported from external modules
    #
    # @return [Transproc::Store]
    #
    def store
      @store ||= Store.new
    end

    # Gets the procedure for creating a transproc
    #
    # @param [#call, Symbol] fn
    #   Either the procedure, or the name of the method of the current module,
    #   or the registered key of imported procedure in a store.
    #
    # @return [#call]
    #
    def fetch(fn)
      return fn unless fn.instance_of? Symbol
      respond_to?(fn) ? method(fn) : store.fetch(fn)
    rescue
      raise FunctionNotFoundError.new(fn, self)
    end
  end
end