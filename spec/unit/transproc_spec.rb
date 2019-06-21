# frozen_string_literal: true

describe Transproc do
  describe 'composition' do
    it 'allows composing two transformation functions' do
      input = '1'
      output = 1.0

      to_i = Transproc::Function.new(->(value) { value.to_i })
      to_f = Transproc::Function.new(->(value) { value.to_f })

      result = to_i >> to_f

      expect(result[input]).to eql(output)
    end
  end
end
