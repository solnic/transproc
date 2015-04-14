require 'spec_helper'

describe "Transproc::Function" do
  describe "#>>" do
    it "composes two functions" do
      f1 = t(:symbolize_keys)
      f2 = t(:map_hash, user_name: :name)

      f3 = f1 >> f2

      expect(f3.to_ast).to eql(
        [
          :symbolize_keys, [t(:symbolize_keys).fn, []],
          [
            :map_hash, [t(:map_hash).fn, [{ user_name: :name }]]
          ]
        ]
      )

      expect(f3['user_name' => 'Jane']).to eql(name: 'Jane')

      f4 = f3 >> t(:nest, :details, [:name])

      expect(f4.to_ast).to eql(
        [
          :symbolize_keys, [t(:symbolize_keys).fn, []],
          [
            :map_hash, [t(:map_hash).fn, [{ user_name: :name }]]
          ],
          [
            :nest, [t(:nest).fn, [:details, [:name]]]
          ]
        ]
      )

      expect(f4['user_name' => 'Jane']).to eql(details: { name: 'Jane' })
    end
  end
end
