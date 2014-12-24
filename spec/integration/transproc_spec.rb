require 'spec_helper'

describe Transproc do
  describe 'composition' do
    it 'allows composing two transformation functions' do
      input = '1'
      output = 1.0

      to_i = Transproc(-> value { value.to_i })
      to_f = Transproc(-> value { value.to_f })

      result = to_i + to_f

      expect(result[input]).to eql(output)
    end
  end

  describe 'function registration' do
    it 'allows registering functions by name' do
      Transproc.register(:to_boolean, -> value { value == 'true' })

      result = Transproc(-> value { value.to_s }) + Transproc(:to_boolean)

      expect(result[:true]).to be(true)
      expect(result[:false]).to be(false)
    end

    it 'allows registering function by passing a block' do
      Transproc.register(:to_boolean) { |value| value == 'true' }

      result = Transproc(-> value { value.to_s }) + Transproc(:to_boolean)

      expect(result[:true]).to be(true)
      expect(result[:false]).to be(false)
    end
  end
end
