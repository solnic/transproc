require 'spec_helper'

require 'transproc/hash'

describe 'Hash mapping with Transproc' do
  describe 'symbolize_keys' do
    it 'returns a new hash with symbolized keys' do
      symbolize_keys = Transproc(:symbolize_keys)

      input = { 'foo' => 'bar' }
      output = { foo: 'bar' }

      expect(symbolize_keys[input]).to eql(output)
    end
  end

  describe 'map' do
    it 'returns a new hash with applied functions' do
      map = Transproc(:map, 'foo' => :foo)

      input = { 'foo' => 'bar' }
      output = { foo: 'bar' }

      expect(map[input]).to eql(output)
    end
  end

  describe 'map_key' do
    it 'applies function to value under specified key' do
      transformation = Transproc(:map_key, :user, Transproc(:symbolize_keys))

      input = { user: { 'name' => 'Jane' } }
      output = { user: { name: 'Jane' } }

      expect(transformation[input]).to eql(output)
    end
  end

  describe 'nested transform' do
    it 'applies functions to nested hashes' do
      symbolize_keys = Transproc(:symbolize_keys)
      map_user_key = Transproc(:map_key, :user, symbolize_keys)

      transformation = symbolize_keys + map_user_key

      input = { 'user' => { 'name' => 'Jane' } }
      output = { user: { name: 'Jane' } }

      expect(transformation[input]).to eql(output)
    end
  end

  describe 'combining transformations' do
    it 'applies functions to the hash' do
      symbolize_keys = Transproc(:symbolize_keys)
      map = Transproc(:map, user_name: :name, user_email: :email)

      transformation = symbolize_keys + map

      input = { 'user_name' => 'Jade', 'user_email' => 'jade@doe.org' }
      output = { name: 'Jade', email: 'jade@doe.org' }

      result = transformation[input]

      expect(result).to eql(output)
    end
  end
end
