require 'spec_helper'

require 'transproc/hash'

describe 'Hash mapping with Transproc' do
  describe 'symbolize_keys' do
    it 'returns a new hash with symbolized keys' do
      symbolize_keys = Transproc(:symbolize_keys)

      input = { 'foo' => 'bar' }
      output = { foo: 'bar' }

      expect(symbolize_keys[input]).to eql(output)
      expect(input).to eql('foo' => 'bar')
    end
  end

  describe 'symbolize_keys!' do
    it 'returns updated hash with symbolized keys' do
      symbolize_keys = Transproc(:symbolize_keys!)

      input = { 'foo' => 'bar' }
      output = { foo: 'bar' }

      symbolize_keys[input]

      expect(input).to eql(output)
    end
  end

  describe 'nest!' do
    it 'returns new hash with keys nested under a new key' do
      nest = Transproc(:nest!, :baz, ['foo'])

      input = { 'foo' => 'bar' }
      output = { baz: { 'foo' => 'bar' } }

      nest[input]

      expect(input).to eql(output)
    end
  end

  describe 'map_hash' do
    it 'returns a new hash with applied functions' do
      map = Transproc(:map_hash, 'foo' => :foo)

      input = { 'foo' => 'bar', :bar => 'baz' }
      output = { foo: 'bar', bar: 'baz' }

      expect(map[input]).to eql(output)
      expect(input).to eql('foo' => 'bar', :bar => 'baz')
    end
  end

  describe 'map_hash!' do
    it 'returns updated hash with applied functions' do
      map = Transproc(:map_hash!, 'foo' => :foo)

      input = { 'foo' => 'bar', :bar => 'baz' }
      output = { foo: 'bar', bar: 'baz' }

      map[input]

      expect(input).to eql(output)
    end
  end

  describe 'map_key' do
    it 'applies function to value under specified key' do
      transformation = Transproc(:map_key, :user, Transproc(:symbolize_keys))

      input = { user: { 'name' => 'Jane' } }
      output = { user: { name: 'Jane' } }

      expect(transformation[input]).to eql(output)
      expect(input).to eql(user: { 'name' => 'Jane' })
    end
  end

  describe 'map_key!' do
    it 'applies function to value under specified key' do
      transformation = Transproc(:map_key!, :user, Transproc(:symbolize_keys))

      input = { user: { 'name' => 'Jane' } }
      output = { user: { name: 'Jane' } }

      transformation[input]

      expect(input).to eql(output)
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
      map = Transproc(:map_hash, user_name: :name, user_email: :email)

      transformation = symbolize_keys + map

      input = { 'user_name' => 'Jade', 'user_email' => 'jade@doe.org' }
      output = { name: 'Jade', email: 'jade@doe.org' }

      result = transformation[input]

      expect(result).to eql(output)
    end
  end
end
