require 'spec_helper'

describe Transproc::HashTransformations do
  describe '.map_keys' do
    it 'returns a new hash with given proc applied to keys' do
      map_keys = t(:map_keys, ->(key) { key.strip })

      input = { ' foo ' => 'bar' }
      output = { 'foo' => 'bar' }

      expect(map_keys[input]).to eql(output)
      expect(input).to eql(' foo ' => 'bar')
    end
  end

  describe '.map_keys!' do
    it 'returns updated hash with given proc applied to keys' do
      map_keys = t(:map_keys!, ->(key) { key.strip })

      input = { ' foo ' => 'bar' }
      output = { 'foo' => 'bar' }

      expect(map_keys[input]).to eql(output)
      expect(input).to eql('foo' => 'bar')
    end
  end

  describe '.symbolize_keys' do
    it 'returns a new hash with symbolized keys' do
      symbolize_keys = t(:symbolize_keys)

      input = { 'foo' => 'bar' }
      output = { foo: 'bar' }

      expect(symbolize_keys[input]).to eql(output)
      expect(input).to eql('foo' => 'bar')
    end
  end

  describe '.symbolize_keys!' do
    it 'returns updated hash with symbolized keys' do
      symbolize_keys = t(:symbolize_keys!)

      input = { 'foo' => 'bar' }
      output = { foo: 'bar' }

      symbolize_keys[input]

      expect(input).to eql(output)
    end
  end

  describe '.stringify_keys' do
    it 'returns a new hash with stringified keys' do
      stringify_keys = t(:stringify_keys)

      input = { foo: 'bar' }
      output = { 'foo' => 'bar' }

      expect(stringify_keys[input]).to eql(output)
      expect(input).to eql(foo: 'bar')
    end
  end

  describe '.stringify_keys!' do
    it 'returns a new hash with stringified keys' do
      stringify_keys = t(:stringify_keys!)

      input = { foo: 'bar' }
      output = { 'foo' => 'bar' }

      expect(stringify_keys[input]).to eql(output)
      expect(input).to eql('foo' => 'bar')
    end
  end

  describe '.map_values' do
    it 'returns a new hash with given proc applied to values' do
      map_values = t(:map_values, ->(value) { value.strip })

      input = { 'foo' => ' bar ' }
      output = { 'foo' => 'bar' }

      expect(map_values[input]).to eql(output)
      expect(input).to eql('foo' => ' bar ')
    end
  end

  describe '.map_values!' do
    it 'returns updated hash with given proc applied to values' do
      map_values = t(:map_values!, ->(value) { value.strip })

      input = { 'foo' => ' bar ' }
      output = { 'foo' => 'bar' }

      expect(map_values[input]).to eql(output)
      expect(input).to eql('foo' => 'bar')
    end
  end

  describe '.rename_keys' do
    it 'returns a new hash with applied functions' do
      map = t(:rename_keys, 'foo' => :foo)

      input = { 'foo' => 'bar', :bar => 'baz' }
      output = { foo: 'bar', bar: 'baz' }

      expect(map[input]).to eql(output)
      expect(input).to eql('foo' => 'bar', :bar => 'baz')
    end
  end

  describe '.rename_keys!' do
    it 'returns updated hash with applied functions' do
      map = t(:rename_keys!, 'foo' => :foo)

      input = { 'foo' => 'bar', :bar => 'baz' }
      output = { foo: 'bar', bar: 'baz' }

      map[input]

      expect(input).to eql(output)
    end
  end

  describe '.map_value' do
    it 'applies function to value under specified key' do
      transformation = t(:map_value, :user, t(:symbolize_keys))

      input = { user: { 'name' => 'Jane' } }
      output = { user: { name: 'Jane' } }

      expect(transformation[input]).to eql(output)
      expect(input).to eql(user: { 'name' => 'Jane' })
    end
  end

  describe '.map_value!' do
    it 'applies function to value under specified key' do
      transformation = t(:map_value!, :user, t(:symbolize_keys))

      input = { user: { 'name' => 'Jane' } }
      output = { user: { name: 'Jane' } }

      transformation[input]

      expect(input).to eql(output)
    end
  end

  describe '.nest' do
    it 'returns new hash with keys nested under a new key' do
      nest = t(:nest, :baz, ['foo'])

      input = { 'foo' => 'bar' }
      output = { baz: { 'foo' => 'bar' } }

      expect(nest[input]).to eql(output)
      expect(input).to eql('foo' => 'bar')
    end
  end

  describe '.nest!' do
    it 'returns new hash with keys nested under a new key' do
      nest = t(:nest!, :baz, ['one', 'two', 'not-here'])

      input = { 'foo' => 'bar', 'one' => nil, 'two' => false }
      output = { 'foo' => 'bar', baz: { 'one' => nil, 'two' => false } }

      nest[input]

      expect(input).to eql(output)
    end

    it 'returns new hash with an empty hash under a new key when nest-keys are missing' do
      nest = t(:nest!, :baz, ['foo'])

      input = { 'bar' => 'foo' }
      output = { 'bar' => 'foo', baz: {} }

      nest[input]

      expect(input).to eql(output)
    end
  end

  describe '.unwrap!' do
    it 'returns updated hash with nested keys lifted to the root' do
      unwrap = t(:unwrap!, 'wrapped', %w(one two))

      input = { 'foo' => 'bar', 'wrapped' => { 'one' => nil, 'two' => false } }
      output = { 'foo' => 'bar', 'one' => nil, 'two' => false }

      unwrap[input]

      expect(input).to eql(output)
    end

    it 'lifts all keys if none are passed' do
      unwrap = t(:unwrap!, 'wrapped')

      input = { 'wrapped' => { 'one' => nil, 'two' => false } }
      output = { 'one' => nil, 'two' => false }

      unwrap[input]

      expect(input).to eql(output)
    end
  end

  describe '.unwrap' do
    it 'returns new hash with nested keys lifted to the root' do
      unwrap = t(:unwrap, 'wrapped', %w(one two))

      input = {
        'foo' => 'bar',
        'wrapped' => { 'one' => nil, 'two' => false }
      }.freeze

      expect(unwrap[input]).to eql(
        'foo' => 'bar',
        'one' => nil,
        'two' => false
      )
    end
  end

  describe 'nested transform' do
    it 'applies functions to nested hashes' do
      symbolize_keys = t(:symbolize_keys)
      map_user_key = t(:map_value, :user, symbolize_keys)

      transformation = symbolize_keys >> map_user_key

      input = { 'user' => { 'name' => 'Jane' } }
      output = { user: { name: 'Jane' } }

      expect(transformation[input]).to eql(output)
    end
  end

  describe 'combining transformations' do
    it 'applies functions to the hash' do
      symbolize_keys = t(:symbolize_keys)
      map = t(:rename_keys, user_name: :name, user_email: :email)

      transformation = symbolize_keys >> map

      input = { 'user_name' => 'Jade', 'user_email' => 'jade@doe.org' }
      output = { name: 'Jade', email: 'jade@doe.org' }

      result = transformation[input]

      expect(result).to eql(output)
    end
  end

  describe '.reject_keys!' do
    it 'returns an updated hash with rejected keys' do
      reject_keys = t(:reject_keys, [:name, :age])

      input = { name: 'Jane', email: 'jane@doe.org', age: 21 }
      output = { email: 'jane@doe.org' }

      expect(reject_keys[input]).to eql(output)
    end
  end

  describe '.reject_keys' do
    it 'returns a new hash with rejected keys' do
      reject_keys = t(:reject_keys, [:name, :age])

      input = { name: 'Jane', email: 'jane@doe.org', age: 21 }
      output = { email: 'jane@doe.org' }

      expect(reject_keys[input]).to eql(output)
      expect(input).to eql(name: 'Jane', email: 'jane@doe.org', age: 21)
    end
  end
end
