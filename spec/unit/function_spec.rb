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
      Transproc.register(:to_s, t(:to_string))
      fn = t(:to_s)

      expect(fn[:ok]).to eql('ok')
      expect(fn.to_ast).to eql([:to_string, []])
    end
  end
end
