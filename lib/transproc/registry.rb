module Transproc
  # Container to define transproc functions in, and access them via `[]` method
  # from the outside of the module
  #
  # @example
  #   module FooMethods
  #     extend Transproc::Registry
  #
  #     def foo(name, prefix)
  #       [prefix, '_', name].join
  #     end
  #   end
  #
  #   fn = FooMethods[:foo, 'baz']
  #   fn['qux'] # => 'qux_baz'
  #
  #   module BarMethods
  #     # extend Transproc::Registry
  #     include FooMethods
  #
  #     def bar(*args)
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
  # @api private
  #
  module Registry
    # Builds the transproc function either from a Proc, or from the module method
    #
    # @param [Proc, Symbol] fn
    #   Either a proc, or a name of the module's function to be wrapped to transproc
    # @param [Object, Array] args
    #   Args to be carried by the transproc
    #
    # @return [Transproc::Function]
    #
    # @alias :t
    #
    # @api public
    #
    def [](fn, *args)
      fun = fn.is_a?(Proc) ? fn : method(fn).to_proc
      Transproc::Function.new(fun, args: args)
    end
    alias_method :t, :[]

    # Forwards the named method (transproc) to another module
    #
    # Allows using transprocs from other modules without including those
    # modules as a whole
    #
    # @example
    #   module Foo
    #     extend Transproc::Registry
    #
    #     def foo(value)
    #       value.upcase
    #     end
    #
    #     def bar(value)
    #       value.downcase
    #     end
    #  end
    #
    #  module Bar
    #     extend Transproc::Registry
    #
    #     uses :foo, from: Foo, as: :baz
    #     uses :bar, from: Foo
    #  end
    #
    #  Bar[:baz]['Qux'] # => 'QUX'
    #  Bar[:bar]['Qux'] # => 'qux'
    #
    # @param [String, Symbol] name
    # @option [Class] :from The module to take the method from
    # @option [String, Symbol] :as
    #   The name of imported transproc inside the current module
    #
    # @return [undefined]
    #
    def uses(name, options = {})
      source   = options.fetch(:from)
      new_name = options.fetch(:as, name)
      define_method(new_name) { |*args| source.__send__(name, *args) }
    end

    # @api private
    def self.extended(target)
      target.extend(ClassMethods)
    end

    # @api private
    module ClassMethods
      # Makes `[]` and all functions defined in the included modules
      # accessible in their receiver
      #
      def included(other)
        other.extend(Transproc::Registry, self)
      end

      # Makes newly module-defined functions accessible via `[]` method
      # by adding it to the module's eigenclass
      #
      def method_added(name)
        module_function(name)
      end

      # Makes undefined methods inaccessible via `[]` method by
      # undefining it from the module's eigenclass
      #
      def method_undefined(name)
        singleton_class.__send__(:undef_method, name)
      end
    end
  end
end
