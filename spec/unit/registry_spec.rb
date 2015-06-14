require 'spec_helper'

describe Transproc::Registry do
  before do
    module FooModule
      extend Transproc::Registry

      def foo(value, prefix)
        [prefix, '_', value].join
      end
    end

    module BarModule
      include FooModule

      def bar(*args)
        foo(*args).upcase
      end
    end

    module BazModule
      extend Transproc::Registry
    end
  end

  describe '.[]' do
    it 'builds function from the method' do
      fn = ::FooModule[:foo, 'baz']

      expect(fn['qux']).to eql 'baz_qux'
    end

    it 'builds function from the proc' do
      fun = -> value, prefix { [prefix, '_', value].join }
      fn  = ::FooModule[fun, 'baz']

      expect(fn['qux']).to eql 'baz_qux'
    end

    it 'builds function using methods from included modules' do
      fn = ::BarModule[:bar, 'baz']

      expect(fn['qux']).to eql 'BAZ_QUX'
    end

    it 'can access methods from included modules directly' do
      fn = ::BarModule[:foo, 'baz']

      expect(fn['qux']).to eql 'baz_qux'
    end

    it 'cannot access undefined methods' do
      module ::BarModule
        undef_method :foo
      end

      expect { ::BarModule[:foo, 'baz'] }.to raise_error
    end
  end

  describe '.uses' do
    it 'forwards methods to another module directly' do
      expect { ::BazModule[:baz, 'baz'] }.to raise_error

      module BazModule
        uses :foo, as: :ffoo, from: FooModule
        uses :bar, from: BarModule
      end

      ffoo = ::BazModule[:ffoo, 'baz']
      bar  = ::BazModule[:bar, 'baz']

      expect(ffoo['qux']).to eql 'baz_qux'
      expect(bar['qux']).to eql 'BAZ_QUX'
    end
  end

  describe '#t' do
    it 'is an alias for .[]' do
      module FooModule
        def qux(value, *args)
          t(:foo, *args)[value]
        end
      end

      fn = ::FooModule[:foo, 'baz']

      expect(fn['qux']).to eql 'baz_qux'
    end
  end

  after { Object.send :remove_const, :BazModule }
  after { Object.send :remove_const, :BarModule }
  after { Object.send :remove_const, :FooModule }
end
