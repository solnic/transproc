module Transproc
  class Transformer
    # @api private
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
        klass = Class.new(Transformer)
        klass.container(container)
        klass
      end

      # @api private
      def inherited(subclass)
        subclass.container(container)
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
          @container
        else
          @container = container
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

      # @api private
      def method_missing(method, *args, &block)
        if container.contain?(method)
          if block_given?
            transformations << t(
              method,
              *args,
              create(container, &block).transproc
            )
          else
            transformations << t(method, *args)
          end
        else
          super
        end
      end

      # @api private
      def respond_to_missing?(method, _include_private = false)
        container.contain?(method) || super
      end

      # @api private
      def transproc
        transformations.reduce(:>>)
      end

      private
      # An array containing the transformation pipeline
      #
      # @api private
      def transformations
        @transformations ||= []
      end

      # Create and return a new instance of Transproc::Transformer
      # evaluating the block argument as the class body
      #
      # @api private
      def create(container, &block)
        klass = self[container]
        klass.instance_eval(&block)
        klass
      end
    end
  end
end
