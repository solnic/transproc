# frozen_string_literal: true

describe Transproc::Store do
  let(:store) { described_class.new methods      }
  let(:methods) { { foo: instance_double(Proc) } }

  describe '.new' do
    it 'is immutable' do
      expect(store).to be_frozen
    end

    it 'does not freeze the source hash' do
      expect { store }.not_to change { methods.frozen? }
    end
  end # describe .new

  describe '#methods' do
    it 'returns the hash from the initializer' do
      expect(store.methods).to eql methods
    end

    it 'returns empty hash by default' do
      expect(described_class.new.methods).to eql({})
    end

    it 'is immutable' do
      expect(store.methods).to be_frozen
    end
  end # describe #methods

  describe '#fetch' do
    it 'returns a registered proc' do
      expect(store.fetch(:foo)).to eql methods[:foo]
    end

    it 'does not accepts anything but symbol as key' do
      expect { store.fetch('foo') }.to raise_error KeyError
    end

    it 'raises KeyError if requested proc is unknown' do
      expect { store.fetch(:bar) }.to raise_error KeyError
    end
  end # describe #fetch

  describe '#contain?' do
    it 'returns true for registered proc' do
      expect(store.contain?(:foo)).to be true
    end

    it 'returns false if requested proc is unknown' do
      expect(store.contain?(:bar)).to be false
    end
  end # describe #fetch

  describe '#register' do
    subject { new_store }
    let(:new_store) { store.register(:increment, ->(v) { v + 1 }) }

    it { is_expected.to be_contain(:increment) }

    it { expect(new_store.fetch(:increment)[2]).to eq 3 }

    it 'preserves existing methods' do
      expect(new_store).to be_contain(:foo)
    end

    context 'with block argument' do
      let(:new_store) { store.register(:increment) { |v| v + 1 } }

      it 'works as well as with proc' do
        expect(new_store.fetch(:increment)[2]).to eq 3
      end
    end
  end

  describe '#import', :focus do
    before do
      module Bar
        def self.bar
          :bar
        end
      end

      module Baz
        def self.baz
          :baz
        end
      end

      module Qux
        extend Transproc::Registry

        import Bar
        import Baz

        def self.baz
          :qux_baz
        end

        def self.qux
          :qux
        end
      end
    end

    shared_examples :importing_method do
      let(:preserved) { subject.methods[:foo] }
      let(:imported)  { subject.methods[key]  }

      it '[preserves old methods]' do
        expect(preserved).to eql(methods[:foo])
      end

      it '[registers a new method]' do
        expect(imported).to be_kind_of Method
        expect(imported.call).to eql(value)
      end
    end

    context 'named method' do
      subject { store.import 'qux', from: Qux }

      it_behaves_like :importing_method do
        let(:key)   { :qux }
        let(:value) { :qux }
      end
    end

    context 'named methods' do
      subject { store.import 'qux', 'bar', from: Qux }

      it_behaves_like :importing_method do
        let(:key)   { :qux }
        let(:value) { :qux }
      end

      it_behaves_like :importing_method do
        let(:key)   { :bar }
        let(:value) { :bar }
      end
    end

    context 'renamed method' do
      subject { store.import 'qux', from: Qux, as: 'quxx' }

      it_behaves_like :importing_method do
        let(:key)   { :quxx }
        let(:value) { :qux  }
      end
    end

    context 'imported proc' do
      subject { store.import 'bar', from: Qux, as: 'barr' }

      it_behaves_like :importing_method do
        let(:key)   { :barr }
        let(:value) { :bar  }
      end
    end

    context 'method that reloads imported proc' do
      subject { store.import 'baz', from: Qux, as: 'bazz' }

      it_behaves_like :importing_method do
        let(:key)   { :bazz    }
        let(:value) { :qux_baz }
      end
    end

    context 'module' do
      subject { store.import Qux }

      it_behaves_like :importing_method do
        let(:key)   { :bar }
        let(:value) { :bar }
      end

      it_behaves_like :importing_method do
        let(:key)   { :baz     }
        let(:value) { :qux_baz }
      end

      it_behaves_like :importing_method do
        let(:key)   { :qux }
        let(:value) { :qux }
      end

      it 'skips Transproc::Registry singleton methods' do
        pending "this fails for some reason" if RUBY_ENGINE == "jruby"
        expect(subject.methods.keys).to contain_exactly(:foo, :bar, :baz, :qux)
      end
    end

    after do
      %w(Bar Baz Qux).each { |name| Object.send :remove_const, name }
    end
  end # describe #import
end # describe Transproc::Store
