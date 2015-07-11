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
    # @example
    #   module Foo
    #     def self.foo(value)
    #       value.upcase
    #     end
    #
    #     def self.bar(value)
    #       value.downcase
    #     end
    #  end
    #
    #  module Qux
    #    def self.qux(value)
    #      value.reverse
    #    end
    #  end
    #
    #  module Bar
    #     extend Transproc::Registry
    #
    #     import :foo, from: Foo, as: :baz
    #     import :bar, from: Foo
    #     import Qux
    #  end
    #
    #  Bar[:baz]['Qux'] # => 'QUX'
    #  Bar[:bar]['Qux'] # => 'qux'
    #  Bar[:qux]['Qux'] # => 'xuQ'
    #
    # @param [Module, #to_sym] name
    # @option [Module] :from The module to take the method from
    # @option [#to_sym] :as
    #   The name of imported transproc inside the current module
    #
    # @return [itself] self
    #
    # @alias :import
    #
    def import(source, options = nil)
      @store = store.import(source, options)
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
