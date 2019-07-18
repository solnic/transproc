# frozen_string_literal: true

require 'transproc/compiler'

module Transproc
  class Transformer
    # @api public
    class DSL
      # @api private
      attr_reader :container

      # @api private
      attr_reader :ast

      # @api private
      def initialize(container, ast: [], &block)
        @container = container
        @ast = ast
        instance_eval(&block) if block
      end

      # @api private
      def dup
        self.class.new(container, ast: ast.dup)
      end

      # @api private
      def call(transformer)
        Compiler.new(container, transformer).(ast)
      end

      private

      # @api private
      def node(&block)
        [:t, self.class.new(container, &block).ast]
      end

      # @api private
      def respond_to_missing?(method, _include_private = false)
        super || container.contain?(method)
      end

      # @api private
      def method_missing(meth, *args, &block)
        arg_nodes = *args.map { |a| [:arg, a] }
        ast << [:fn, (block ? [meth, [*arg_nodes, node(&block)]] : [meth, arg_nodes])]
      end
    end

    # @api public
    module ClassInterface
      # @api private
      attr_reader :dsl

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

        subclass.instance_variable_set('@dsl', dsl.dup) if dsl
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

      # @api public
      def define!(&block)
        @dsl = DSL.new(container, &block)
        self
      end

      # @api public
      def new
        super.tap do |transformer|
          if dsl
            transformer.instance_variable_set('@transproc', dsl.(transformer))
          end
        end
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
