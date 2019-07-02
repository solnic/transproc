# frozen_string_literal: true

require 'transproc/compiler'

module Transproc
  class Transformer
    # @api public
    module ClassInterface
      # Return a base Transproc::Transformer class with the
      # container configured to the passed argument.
      #
      # @example
      #
      #   class MyTransformer < Transproc::Transformer[Transproc]
      #   end
      #
      # @param [Transproc::Registry] container
      #   The container to resolve transprocs from
      #
      # @return [subclass of Transproc::Transformer]
      #
      # @api public
      def [](container)
        klass = Class.new(self)
        klass.container(container)
        klass
      end

      # @api private
      def inherited(subclass)
        super

        subclass.container(@container) if defined?(@container)

        subclass.instance_variable_set('@ast', ast.dup) if ast.any?
      end

      # Get or set the container to resolve transprocs from.
      #
      # @example
      #
      #   # Setter
      #   Transproc::Transformer.container(Transproc)
      #   # => Transproc
      #
      #   # Getter
      #   Transproc::Transformer.container
      #   # => Transproc
      #
      # @param [Transproc::Registry] container
      #   The container to resolve transprocs from
      #
      # @return [Transproc::Registry]
      #
      # @api private
      def container(container = ::Transproc::Undefined)
        if container == ::Transproc::Undefined
          ensure_container_presence!
          @container
        else
          @container = container
        end
      end

      # Define an anonymous transproc derived from given Transformer
      # Evaluates block with transformations and returns initialized transproc.
      # Does not mutate original Transformer
      #
      # @example
      #
      #   class MyTransformer < Transproc::Transformer[MyContainer]
      #   end
      #
      #   transproc = MyTransformer.define do
      #     map_values t(:to_string)
      #   end
      #   transproc.call(a: 1, b: 2)
      #   # => {a: '1', b: '2'}
      #
      # @yield Block allowing to define transformations. The same as class level DSL
      #
      # @return [Function] Composed transproc
      #
      # @api public
      def define(&block)
        Class.new(self[container], &block).transproc
      end
      alias build define

      # @api private
      def transproc
        compiler.(ast)
      end

      # @api public
      def new
        super.tap do |transformer|
          transformer.instance_variable_set('@transproc', compiler(transformer).call(ast))
        end
      end

      # @api private
      def compiler(transformer = nil)
        Compiler.new(container, transformer)
      end

      # @api private
      def node(&block)
        [:t, Class.new(Transformer[container], &block).ast]
      end

      # Get a transformation from the container,
      # without adding it to the transformation pipeline
      #
      # @example
      #
      #   class Stringify < Transproc::Transformer
      #     map_values t(:to_string)
      #   end
      #
      #   Stringify.new.call(a: 1, b: 2)
      #   # => {a: '1', b: '2'}
      #
      # @param [Proc, Symbol] fn
      #   A proc, a name of the module's own function, or a name of imported
      #   procedure from another module
      # @param [Object, Array] args
      #   Args to be carried by the transproc
      #
      # @return [Transproc::Function]
      #
      # @api public
      def t(fn, *args)
        container[fn, *args]
      end

      # @api private
      def method_missing(meth, *args, &block)
        arg_nodes = *args.map { |a| [:arg, a] }
        ast << [:fn, (block ? [meth, [*arg_nodes, node(&block)]] : [meth, arg_nodes])]
      end

      # @api private
      def respond_to_missing?(method, _include_private = false)
        super || container.contain?(method)
      end

      # An array containing the transformation pipeline
      #
      # @api private
      def ast
        @ast ||= []
      end

      private

      # @api private
      def ensure_container_presence!
        return if defined?(@container)
        raise ArgumentError, 'Transformer function registry is empty. '\
                             'Provide your registry via Transproc::Transformer[YourRegistry]'
      end
    end
  end
end
