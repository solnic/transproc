require 'spec_helper'

describe Transproc::Function do
  let(:hashes) { Transproc::HashTransformations }

  describe '#name' do
    let(:block) { proc { |v| v } }

    it 'returns the name of the module function' do
      expect(hashes[:symbolize_keys].name).to eql :symbolize_keys
    end

    it 'returns the explicitly assigned name' do
      expect(described_class.new(block, name: :identity).name).to eql :identity
    end

    it 'returns the unnamed closure' do
      expect(described_class.new(block).name).to eql block
    end
  end

  describe '#>>' do
    it 'composes named functions' do
      f1 = hashes[:symbolize_keys]
      f2 = hashes[:rename_keys, user_name: :name]

      f3 = f1 >> f2

      expect(f3.to_ast).to eql(
        [
          :symbolize_keys, [],
          [
            :rename_keys, [user_name: :name]
          ]
        ]
      )

      expect(f3['user_name' => 'Jane']).to eql(name: 'Jane')

      f4 = f3 >> hashes[:nest, :details, [:name]]

      expect(f4.to_ast).to eql(
        [
          :symbolize_keys, [],
          [
            :rename_keys, [user_name: :name]
          ],
          [
            :nest, [:details, [:name]]
          ]
        ]
      )

      expect(f4['user_name' => 'Jane']).to eql(details: { name: 'Jane' })
    end

    it 'composes anonymous functions' do
      # TODO: Use Transproc -> (v) { v.to_s } after release of jruby-9k
      f1 = Transproc proc { |v, m| v * m }, 2
      f2 = Transproc proc(&:to_s)

      f3 = f1 >> f2

      expect(f3.to_ast).to eql(
        [
          f1.fn, [2],
          [
            f2.fn, []
          ]
        ]
      )
    end

    it 'plays well with registered compositions' do
      Transproc.register(:user_names, hashes[:symbolize_keys] + hashes[:rename_keys, user_name: :name])
      f = t(:user_names)

      expect(f['user_name' => 'Jane']).to eql(name: 'Jane')
      expect(f.to_ast).to eql(
        [
          :symbolize_keys, [],
          [
            :rename_keys, [user_name: :name]
          ]
        ]
      )
    end

    it 'plays well with registered functions' do
      Transproc.register(:to_s, Transproc::Coercions.t(:to_string))
      fn = t(:to_s)

      expect(fn[:ok]).to eql('ok')
      expect(fn.to_ast).to eql([:to_string, []])
    end
  end

  describe '#==' do
    let(:fns) do
      Module.new do
        extend Transproc::Registry
        import :wrap, from: Transproc::ArrayTransformations
      end
    end

    it 'returns true when the other is equal' do
      left = fns[:wrap, :user, [:name, :email]]
      right = fns[:wrap, :user, [:name, :email]]

      expect(left == right).to be(true)
    end

    it 'returns false when the other is not a fn' do
      left = fns[:wrap, :user, [:name, :email]]
      right = 'boo!'

      expect(left == right).to be(false)
    end
  end

  describe '#to_proc' do
    shared_examples :providing_a_proc do
      let(:fn) { described_class.new(source) }
      subject  { fn.to_proc }

      it 'returns a proc' do
        expect(subject).to be_instance_of Proc
      end

      it 'works fine' do
        expect(subject.call :foo).to eql('foo')
      end
    end

    context 'from a method' do
      let(:source) do
        mod = Module.new do
          def self.get(x)
            x.to_s
          end
        end
        mod.method(:get)
      end
      it_behaves_like :providing_a_proc
    end

    context 'from a proc' do
      let(:source) { -> value { value.to_s } }
      it_behaves_like :providing_a_proc
    end

    context 'from a transproc' do
      let(:source) { Transproc::Function.new -> value { value.to_s } }
      it_behaves_like :providing_a_proc

      it 'can be applied to collection' do
        expect([:foo, :bar].map(&source)).to eql(%w(foo bar))
      end
    end

    context 'with curried args' do
      let(:source) { -> i, j { [i, j].join(' ') } }

      it 'works fine' do
        fn = described_class.new(source, args: ['world'])

        result = fn.to_proc.call('hello')

        expect(result).to eql('hello world')
      end
    end
  end
end
