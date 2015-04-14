require 'spec_helper'

describe "Transproc::Function" do
  describe "#>>" do
    it "composes named functions" do
      f1 = t(:symbolize_keys)
      f2 = t(:map_hash, user_name: :name)

      f3 = f1 >> f2

      expect(f3.to_ast).to eql(
        [
          :symbolize_keys, [],
          [
            :map_hash, [ user_name: :name ]
          ]
        ]
      )

      expect(f3['user_name' => 'Jane']).to eql(name: 'Jane')

      f4 = f3 >> t(:nest, :details, [:name])

      expect(f4.to_ast).to eql(
        [
          :symbolize_keys, [],
          [
            :map_hash, [ user_name: :name ]
          ],
          [
            :nest, [:details, [:name]]
          ]
        ]
      )

      expect(f4['user_name' => 'Jane']).to eql(details: { name: 'Jane' })
    end

    it "composes anonymous functions" do
      f1 = Transproc -> (v, m) { v * m }, 2
      f2 = Transproc -> (v) { v.to_s }

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
  end
end
