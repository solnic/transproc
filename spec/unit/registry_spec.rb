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

  describe '.[]' do
    subject { foo[fn, 'baz'] }

    context 'from a method' do
      let(:fn) { :prefix }

      it 'builds a function from a method' do
        expect(subject['qux']).to eql 'baz_qux'
      end
    end

    context 'from a closure' do
      let(:fn) { -> value, prefix { [prefix, '_', value].join } }

      it 'builds a function from a method' do
        expect(subject['qux']).to eql 'baz_qux'
      end
    end
  end

  describe '.t' do
    subject { foo.t(:prefix, 'baz') }

    it 'is an alias for .[]' do
      expect(subject['qux']).to eql 'baz_qux'
    end
  end

  describe '.import' do
    context 'a module' do
      subject { bar.import foo }

      it 'imports its methods' do
        expect { subject }
          .to change { bar.respond_to? :prefix }
          .from(false)
          .to(true)
        expect(bar[:prefix, 'baz']['qux']).to eql 'baz_qux'
      end

      it { is_expected.to eq bar }
    end

    context 'a module with the same method' do
      subject { bar.import foo }
      before  { bar.singleton_class.send(:define_method, :prefix) { |*| nil } }

      it 'redefines method' do
        expect { subject }
          .to change { bar[:prefix, 'baz']['qux'] }.from(nil).to('baz_qux')
      end
    end

    context 'a method' do
      subject { bar.import :prefix, from: foo }

      it 'imports the method with the same name' do
        expect { subject }
          .to change { bar.respond_to? :prefix }
          .from(false)
          .to(true)
        expect(bar[:prefix, 'bar']['baz']).to eql 'bar_baz'
      end
    end

    context 'a renamed method' do
      subject { bar.import :prefix, from: foo, as: :affix }

      it 'imports the method with the new name' do
        expect { subject }
          .to change { bar.respond_to? :affix }
          .from(false)
          .to(true)
        expect(bar[:affix, 'bar']['baz']).to eql 'bar_baz'
      end
    end
  end

  describe '.uses' do
    it 'is an alias for .import' do
      expect { bar.import foo }
        .to change { bar.respond_to? :prefix }
        .from(false)
        .to(true)
    end
  end
end
