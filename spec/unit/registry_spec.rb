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

  describe '.contain?' do
    context 'with absent function' do
      it { expect(foo.contain?(:something)).to be false }
    end

    context 'with class method' do
      it { expect(foo.contain?(:prefix)).to be true }
    end

    context 'with imported methods' do
      before { bar.import foo }

      it { expect(bar.contain?(:prefix)).to be true }
    end
  end

  describe '.register' do
    it { expect(foo).not_to be_contain(:increment) }

    it { expect(foo).to be_contain(:prefix) }

    def do_register
      foo.register(:increment, ->(v) { v + 1 })
    end

    it 'returns self' do
      expect(do_register).to eq foo
    end

    it 'registers function' do
      do_register
      expect(foo).to be_contain(:increment)
    end

    it 'preserves previous functions' do
      do_register
      expect(foo).to be_contain(:prefix)
    end

    it 'makes function available' do
      do_register
      expect(foo[:increment][2]).to eq 3
    end

    it 'rejects to overwrite existing' do
      expect { foo.register(:prefix) {} }
        .to raise_error(Transproc::FunctionAlreadyRegisteredError)
    end

    it 'registers and fetches transproc function' do
      function = foo[:prefix, '1']
      foo.register(:prefix_one, function)

      expect(foo[:prefix_one]).to eq function
    end

    it 'registers and fetches composite' do
      composite = foo[:prefix, '1'] + foo[:prefix, '2']
      foo.register(:double_prefix, composite)

      expect(foo[:double_prefix]).to eq composite
    end

    context 'with block argument' do
      def do_register
        foo.register(:increment) { |v| v + 1 }
      end

      it 'registers function' do
        do_register
        expect(foo).to be_contain(:increment)
      end

      it 'makes function available' do
        do_register
        expect(foo[:increment][2]).to eq 3
      end
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

    context 'a list of methods' do
      before { bar.import :prefix, from: foo }
      before { bar.import :prefix, from: foo, as: :affix }
      before { baz.import :prefix, :affix, from: bar }

      it 'registers a transproc' do
        expect(baz[:prefix, 'bar']['baz']).to eql 'bar_baz'
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
