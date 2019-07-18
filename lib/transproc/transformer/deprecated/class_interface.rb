# frozen_string_literal: true

module Transproc
  class Transformer
    module Deprecated
      # @api public
      module ClassInterface
        # @api public
        def new(*args)
          super(*args).tap do |transformer|
            transformer.instance_variable_set('@transproc', transproc) if transformations.any?
          end
        end

        # @api private
        def inherited(subclass)
          super

          if transformations.any?
            subclass.instance_variable_set('@transformations', transformations.dup)
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
          return transproc unless block_given?

          Class.new(Transformer[container]).tap { |klass| klass.instance_eval(&block) }.transproc
        end
        alias build define

        # @api private
        def method_missing(method, *args, &block)
          super unless container.contain?(method)
          func = block ? t(method, *args, define(&block)) : t(method, *args)
          transformations << func
          func
        end

        # @api private
        def respond_to_missing?(method, _include_private = false)
          super || container.contain?(method)
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
      end
    end
  end
end
