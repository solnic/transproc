require 'spec_helper'

describe Transproc::Registry do
  before { module Transproc::Test; end         }
  after  { Transproc.send :remove_const, :Test }

  let(:foo) do
    Transproc::Test::Foo = Module.new do
      extend Transproc::Registry

      def self.prefix(value, prefix)
        "#{prefix}_#{value}"
      end
    end
  end
  let(:bar) { Transproc::Test::Bar = Module.new { extend Transproc::Registry } }
  let(:baz) { Transproc::Test::Baz = Module.new { extend Transproc::Registry } }

  describe '.[]' do
    subject(:transproc) { foo[fn, 'baz'] }

    context 'from a method' do
      let(:fn) { :prefix }

      it 'builds a function from a method' do
        expect(transproc['qux']).to eql 'baz_qux'
      end
    end

    context 'from a closure' do
      let(:fn) { -> value, prefix { [prefix, '_', value].join } }

      it 'builds a function from a method' do
        expect(transproc['qux']).to eql 'baz_qux'
      end
    end
  end

  describe '.t' do
    subject(:transproc) { foo.t(:prefix, 'baz') }

    it 'is an alias for .[]' do
      expect(transproc['qux']).to eql 'baz_qux'
    end
  end

  describe '.import' do
    context 'a module' do
      subject(:import) { bar.import foo }

      it 'registers all its methods' do
        import
        expect(bar[:prefix, 'baz']['qux']).to eql 'baz_qux'
      end

      it 'returns itself' do
        expect(import).to eq bar
      end
    end

    context 'a method' do
      before { bar.import :prefix, from: foo }

      it 'registers a transproc' do
        expect(bar[:prefix, 'bar']['baz']).to eql 'bar_baz'
      end
    end

    context 'an imported method' do
      before do
        bar.import :prefix, from: foo, as: :affix
        baz.import :affix, from: bar
      end

      it 'registers a transproc' do
        expect(baz[:affix, 'bar']['baz']).to eql 'bar_baz'
      end
    end

    context 'a renamed method' do
      before { bar.import :prefix, from: foo, as: :affix }

      it 'registers a transproc under the new name' do
        expect(bar[:affix, 'bar']['baz']).to eql 'bar_baz'
      end
    end

    context 'an unknown method' do
      it 'fails' do
        expect { bar.import :suffix, from: foo }.to raise_error do |error|
          expect(error).to be_kind_of Transproc::FunctionNotFoundError
          expect(error.message).to include 'Foo[:suffix]'
        end
      end
    end
  end

  describe '.uses' do
    before { bar.uses foo }

    it 'is an alias for .import' do
      expect(bar[:prefix, 'baz']['qux']).to eql 'baz_qux'
    end
  end
end
