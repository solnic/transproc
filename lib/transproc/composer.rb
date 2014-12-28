module Transproc
  module Composer

    class Factory
      attr_reader :fns, :default

      def initialize(default = nil)
        @fns = []
        @default = default
      end

      def <<(other)
        fns.concat(Array(other).compact)
        self
      end

      def to_fn
        fns.reduce(:+) || default
      end
    end

    def t(*args)
      Transproc(*args)
    end

    def compose(default = nil)
      factory = Factory.new(default)
      yield(factory)
      factory.to_fn
    end

  end
end
