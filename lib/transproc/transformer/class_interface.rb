# frozen_string_literal: true

require 'transproc/transformer/dsl'

module Transproc
  class Transformer
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
      def container(container = Undefined)
        if container.equal?(Undefined)
          @container ||= Module.new.extend(Transproc::Registry)
        else
          @container = container
        end
      end

      # @api public
      def import(*args)
        container.import(*args)
      end

      # @api public
      def define!(&block)
        @dsl = DSL.new(container, &block)
        self
      end

      # @api public
      def new
        super.tap do |transformer|
          transformer.instance_variable_set('@transproc', dsl.(transformer)) if dsl
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
    end
  end
end
