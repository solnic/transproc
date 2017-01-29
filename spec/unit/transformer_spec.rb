require 'spec_helper'

describe Transproc::Transformer do
  let(:klass) { Class.new(Transproc::Transformer) }
  let(:transformer) { klass.new }

  describe '.container' do
    context 'without setter argument' do
      subject! { klass.container }

      it 'defaults to Transproc' do
        is_expected.to eq(Transproc)
      end
    end

    context 'with setter argument' do
      subject! { klass.container({}) }

      it 'sets and returns the container' do
        expect(klass.container).to eq({})
      end
    end
  end

  describe '.[]' do
    let(:container) { double('Transproc') }

    subject!(:klass) { Transproc::Transformer[container] }

    it { expect(klass.container).to eq(container) }
    it { is_expected.to be_a(::Class) }
  end

  describe '.t' do
    let(:container) do
      Module.new do
        extend Transproc::Registry

        import Transproc::HashTransformations
        import Transproc::Conditional

        def self.custom(value, suffix)
          value + suffix
        end
      end
    end

    subject!(:klass) { Transproc::Transformer[container] }

    it { expect(klass.t(:custom, '_bar')).to eq container[:custom, '_bar'] }

    it 'is useful in DSL' do
      transproc = Class.new(klass) do
        map_value :a, t(:custom, '_bar')
      end.new

      expect(transproc.call(a: 'foo')).to eq(a: 'foo_bar')
    end

    it 'works in nested block' do
      transproc = Class.new(klass) do
        map_values do
          is String, t(:custom, '_bar')
        end
      end.new

      expect(transproc.call(a: 'foo', b: :symbol)).to eq(a: 'foo_bar', b: :symbol)
    end
  end

  describe '#call' do
    let(:container) do
      Module.new do
        extend Transproc::Registry

        import Transproc::HashTransformations
        import Transproc::ArrayTransformations
        import Transproc::ClassTransformations
      end
    end

    let(:klass) do
      Class.new(Transproc::Transformer[container]) do
        map_array do
          symbolize_keys
          rename_keys user_name: :name
          nest :address, [:city, :street, :zipcode]
          map_value :address do
            constructor_inject Test::Address
          end
          constructor_inject Test::User
        end
      end
    end
    let(:input) do
      [
        { 'user_name' => 'Jane',
          'city' => 'NYC',
          'street' => 'Street 1',
          'zipcode' => '123'
        }
      ]
    end
    let(:output) do
      [
        Test::User.new(
          name: 'Jane',
          address: Test::Address.new(
            city: 'NYC',
            street: 'Street 1',
            zipcode: '123'
          )
        )
      ]
    end

    before do
      module Test
        class User
          include Anima.new(:name, :address)
        end

        class Address
          include Anima.new(:city, :street, :zipcode)
        end
      end
    end

    subject! { transformer.call(input) }

    it { is_expected.to eq(output) }

    context 'with custom registry' do
      let(:klass) do
        Class.new(Transproc::Transformer[registry]) do
          custom ' is awesome'
        end
      end
      let(:registry) do
        Module.new do
          extend Transproc::Registry

          def self.custom(value, suffix)
            value + suffix
          end
        end
      end
      let(:input) { 'transproc' }

      it { is_expected.to eq('transproc is awesome') }
    end
  end
end
