require 'spec_helper'
require 'transproc/rspec'

describe Transproc::HashTransformations do
  describe '.map_keys' do
    it 'returns a new hash with given proc applied to keys' do
      map_keys = described_class.t(:map_keys, ->(key) { key.strip })

      input = { ' foo ' => 'bar' }
      output = { 'foo' => 'bar' }

      expect(map_keys[input]).to eql(output)
      expect(input).to eql(' foo ' => 'bar')
    end
  end

  describe '.map_keys!' do
    it 'returns updated hash with given proc applied to keys' do
      map_keys = described_class.t(:map_keys!, ->(key) { key.strip })

      input = { ' foo ' => 'bar' }
      output = { 'foo' => 'bar' }

      expect(map_keys[input]).to eql(output)
      expect(input).to eql('foo' => 'bar')
    end
  end

  describe '.symbolize_keys' do
    it 'returns a new hash with symbolized keys' do
      symbolize_keys = described_class.t(:symbolize_keys)

      input = { 'foo' => 'bar' }
      output = { foo: 'bar' }

      expect(symbolize_keys[input]).to eql(output)
      expect(input).to eql('foo' => 'bar')
    end
  end

  describe '.deep_symbolize_keys' do
    it 'returns a new hash with symbolized keys' do
      symbolize_keys = described_class.t(:deep_symbolize_keys)

      input = { 'foo' => 'bar', 'baz' => [{ 'one' => 1 }, 'two'] }
      output = { foo: 'bar', baz: [{ one: 1 }, 'two'] }

      expect(symbolize_keys[input]).to eql(output)
      expect(input).to eql({ 'foo' => 'bar', 'baz' => [{ 'one' => 1 }, 'two'] })
    end
  end

  describe '.symbolize_keys!' do
    it 'returns updated hash with symbolized keys' do
      symbolize_keys = described_class.t(:symbolize_keys!)

      input = { 'foo' => 'bar' }
      output = { foo: 'bar' }

      symbolize_keys[input]

      expect(input).to eql(output)
    end
  end

  describe '.stringify_keys' do
    it 'returns a new hash with stringified keys' do
      stringify_keys = described_class.t(:stringify_keys)

      input = { foo: 'bar' }
      output = { 'foo' => 'bar' }

      expect(stringify_keys[input]).to eql(output)
      expect(input).to eql(foo: 'bar')
    end
  end

  describe '.stringify_keys!' do
    it 'returns a new hash with stringified keys' do
      stringify_keys = described_class.t(:stringify_keys!)

      input = { foo: 'bar' }
      output = { 'foo' => 'bar' }

      expect(stringify_keys[input]).to eql(output)
      expect(input).to eql('foo' => 'bar')
    end
  end

  describe '.map_values' do
    it 'returns a new hash with given proc applied to values' do
      map_values = described_class.t(:map_values, ->(value) { value.strip })

      input = { 'foo' => ' bar ' }
      output = { 'foo' => 'bar' }

      expect(map_values[input]).to eql(output)
      expect(input).to eql('foo' => ' bar ')
    end
  end

  describe '.map_values!' do
    it 'returns updated hash with given proc applied to values' do
      map_values = described_class.t(:map_values!, ->(value) { value.strip })

      input = { 'foo' => ' bar ' }
      output = { 'foo' => 'bar' }

      expect(map_values[input]).to eql(output)
      expect(input).to eql('foo' => 'bar')
    end
  end

  describe '.rename_keys' do
    it 'returns a new hash with applied functions' do
      map = described_class.t(:rename_keys, 'foo' => :foo)

      input = { 'foo' => 'bar', :bar => 'baz' }
      output = { foo: 'bar', bar: 'baz' }

      expect(map[input]).to eql(output)
      expect(input).to eql('foo' => 'bar', :bar => 'baz')
    end
  end

  describe '.rename_keys!' do
    it 'returns updated hash with applied functions' do
      map = described_class.t(:rename_keys!, 'foo' => :foo)

      input = { 'foo' => 'bar', :bar => 'baz' }
      output = { foo: 'bar', bar: 'baz' }

      map[input]

      expect(input).to eql(output)
    end
  end

  describe '.map_value' do
    it 'applies function to value under specified key' do
      transformation =
        described_class.t(:map_value, :user, described_class.t(:symbolize_keys))

      input = { user: { 'name' => 'Jane' } }
      output = { user: { name: 'Jane' } }

      expect(transformation[input]).to eql(output)
      expect(input).to eql(user: { 'name' => 'Jane' })
    end
  end

  describe '.map_value!' do
    it 'applies function to value under specified key' do
      transformation =
        described_class
        .t(:map_value!, :user, described_class.t(:symbolize_keys))

      input = { user: { 'name' => 'Jane' } }
      output = { user: { name: 'Jane' } }

      transformation[input]

      expect(input).to eql(output)
    end
  end

  describe '.nest' do
    it 'returns new hash with keys nested under a new key' do
      nest = described_class.t(:nest, :baz, ['foo'])

      input = { 'foo' => 'bar' }
      output = { baz: { 'foo' => 'bar' } }

      expect(nest[input]).to eql(output)
      expect(input).to eql('foo' => 'bar')
    end
  end

  describe '.nest!' do
    it 'returns new hash with keys nested under a new key' do
      nest = described_class.t(:nest!, :baz, ['one', 'two', 'not-here'])

      input = { 'foo' => 'bar', 'one' => nil, 'two' => false }
      output = { 'foo' => 'bar', baz: { 'one' => nil, 'two' => false } }

      nest[input]

      expect(input).to eql(output)
    end

    it 'returns new hash with keys nested under the existing key' do
      nest = described_class.t(:nest!, :baz, ['two'])

      input  = { 'foo' => 'bar', baz: { 'one' => nil }, 'two' => false }
      output = { 'foo' => 'bar', baz: { 'one' => nil, 'two' => false } }

      nest[input]

      expect(input).to eql(output)
    end

    it 'rewrites the existing key if its value is not a hash' do
      nest = described_class.t(:nest!, :baz, ['two'])

      input  = { 'foo' => 'bar', baz: 'one', 'two' => false }
      output = { 'foo' => 'bar', baz: { 'two' => false } }

      nest[input]

      expect(input).to eql(output)
    end

    it 'returns new hash with an empty hash under a new key when nest-keys are missing' do
      nest = described_class.t(:nest!, :baz, ['foo'])

      input = { 'bar' => 'foo' }
      output = { 'bar' => 'foo', baz: {} }

      nest[input]

      expect(input).to eql(output)
    end
  end

  describe '.unwrap!' do
    it 'returns updated hash with nested keys lifted to the root' do
      unwrap = described_class.t(:unwrap!, 'wrapped', %w(one))

      input = { 'foo' => 'bar', 'wrapped' => { 'one' => nil, 'two' => false } }
      output = { 'foo' => 'bar', 'one' => nil, 'wrapped' => { 'two' => false } }

      unwrap[input]

      expect(input).to eql(output)
    end

    it 'lifts all keys if none are passed' do
      unwrap = described_class.t(:unwrap!, 'wrapped')

      input = { 'wrapped' => { 'one' => nil, 'two' => false } }
      output = { 'one' => nil, 'two' => false }

      unwrap[input]

      expect(input).to eql(output)
    end

    it 'ignores unknown keys' do
      unwrap = described_class.t(:unwrap!, 'wrapped', %w(one two three))

      input = { 'wrapped' => { 'one' => nil, 'two' => false } }
      output = { 'one' => nil, 'two' => false }

      unwrap[input]

      expect(input).to eql(output)
    end
  end

  describe '.unwrap' do
    it 'returns new hash with nested keys lifted to the root' do
      unwrap = described_class.t(:unwrap, 'wrapped')

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
      symbolize_keys = described_class.t(:symbolize_keys)
      map_user_key = described_class.t(:map_value, :user, symbolize_keys)

      transformation = symbolize_keys >> map_user_key

      input = { 'user' => { 'name' => 'Jane' } }
      output = { user: { name: 'Jane' } }

      expect(transformation[input]).to eql(output)
    end
  end

  describe 'combining transformations' do
    it 'applies functions to the hash' do
      symbolize_keys = described_class.t(:symbolize_keys)
      map = described_class.t(:rename_keys, user_name: :name, user_email: :email)

      transformation = symbolize_keys >> map

      input = { 'user_name' => 'Jade', 'user_email' => 'jade@doe.org' }
      output = { name: 'Jade', email: 'jade@doe.org' }

      result = transformation[input]

      expect(result).to eql(output)
    end
  end

  describe '.reject_keys!' do
    it 'returns an updated hash with rejected keys' do
      reject_keys = described_class.t(:reject_keys, [:name, :age])

      input = { name: 'Jane', email: 'jane@doe.org', age: 21 }
      output = { email: 'jane@doe.org' }

      expect(reject_keys[input]).to eql(output)
    end
  end

  describe '.reject_keys' do
    it 'returns a new hash with rejected keys' do
      reject_keys = described_class.t(:reject_keys, [:name, :age])

      input = { name: 'Jane', email: 'jane@doe.org', age: 21 }
      output = { email: 'jane@doe.org' }

      expect(reject_keys[input]).to eql(output)
      expect(input).to eql(name: 'Jane', email: 'jane@doe.org', age: 21)
    end
  end

  describe '.accept_keys!' do
    it 'returns an updated hash with accepted keys' do
      accept_keys = described_class.t(:accept_keys, [:age])

      input = { name: 'Jane', email: 'jane@doe.org', age: 21 }
      output = { age: 21 }

      expect(accept_keys[input]).to eql(output)
    end
  end

  describe '.reject_keys' do
    it 'returns a new hash with rejected keys' do
      accept_keys = described_class.t(:accept_keys, [:age])

      input = { name: 'Jane', email: 'jane@doe.org', age: 21 }
      output = { age: 21 }

      expect(accept_keys[input]).to eql(output)
      expect(input).to eql(name: 'Jane', email: 'jane@doe.org', age: 21)
    end
  end

  describe '.fold' do
    let(:input) do
      {
        name: 'Jane',
        tasks: [{ title: 'be nice', priority: 1 }, { title: 'sleep well' }]
      }
    end

    it_behaves_like :transforming_immutable_data do
      let(:arguments) { [:fold, :tasks, :title] }
      let(:output)    { { name: 'Jane', tasks: ['be nice', 'sleep well'] } }
    end

    it_behaves_like :transforming_immutable_data do
      let(:arguments) { [:fold, :tasks, :priority] }
      let(:output)    { { name: 'Jane', tasks: [1, nil] } }
    end
  end

  describe '.fold!' do
    let(:input) do
      {
        name: 'Jane',
        tasks: [{ title: 'be nice', priority: 1 }, { title: 'sleep well' }]
      }
    end

    it_behaves_like :mutating_input_data do
      let(:arguments) { [:fold!, :tasks, :title] }
      let(:output)    { { name: 'Jane', tasks: ['be nice', 'sleep well'] } }
    end

    it_behaves_like :mutating_input_data do
      let(:arguments) { [:fold!, :tasks, :priority] }
      let(:output)    { { name: 'Jane', tasks: [1, nil] } }
    end
  end

  describe '.split' do
    let(:input) do
      {
        name: 'Joe',
        tasks: [
          { title: 'sleep well', priority: 1   },
          { title: 'be nice',    priority: 2   },
          {                      priority: 2   },
          { title: 'be cool'                   },
          {}
        ]
      }
    end

    it 'splits a tuple into array partially by given keys' do
      split = described_class.t(:split, :tasks, [:priority])

      output = [
        {
          name: 'Joe', priority: 1,
          tasks: [{ title: 'sleep well' }]
        },
        {
          name: 'Joe', priority: 2,
          tasks: [{ title: 'be nice' }, { title: nil }]
        },
        {
          name: 'Joe', priority: nil,
          tasks: [{ title: 'be cool' }, { title: nil }]
        }
      ]

      expect(split[input]).to eql output
    end

    it 'splits a tuple into array fully by all subkeys' do
      split = described_class.t(:split, :tasks, [:priority, :title])

      output = [
        { name: 'Joe', title: 'sleep well', priority: 1   },
        { name: 'Joe', title: 'be nice',    priority: 2   },
        { name: 'Joe', title: nil,          priority: 2   },
        { name: 'Joe', title: 'be cool',    priority: nil },
        { name: 'Joe', title: nil,          priority: nil }
      ]

      expect(split[input]).to eql output
    end

    it 'returns an array of one tuple with updated keys when there is nothing to split by' do
      output = [
        {
          name: 'Joe',
          tasks: [
            { title: 'sleep well', priority: 1   },
            { title: 'be nice',    priority: 2   },
            { title: nil,          priority: 2   },
            { title: 'be cool',    priority: nil },
            { title: nil,          priority: nil }
          ]
        }
      ]

      split = described_class.t(:split, :tasks, [])
      expect(split[input]).to eql output

      split = described_class.t(:split, :tasks, [:absent])
      expect(split[input]).to eql output
    end

    it 'returns an array of initial tuple when attribute is absent' do
      split = described_class.t(:split, :absent, [:priority, :title])
      expect(split[input]).to eql [input]
    end

    it 'ignores empty array' do
      input = { name: 'Joe', tasks: [] }

      split = described_class.t(:split, :tasks, [:title])

      expect(split[input]).to eql [{ name: 'Joe' }]
    end
  end

  describe ':eval_values' do
    it 'recursively evaluates values' do
      evaluate = described_class.t(:eval_values, 1)

      input = {
        one: 1, two: -> i { i+1 },
        three: -> i { i+2 }, four: 4,
        more: [{ one: -> i { i }, two: 2 }]
      }

      output = {
        one: 1, two: 2,
        three: 3, four: 4,
        more: [{ one: 1, two: 2 }]
      }

      expect(evaluate[input]).to eql(output)
    end

    it 'recursively evaluates values matching key names' do
      evaluate = described_class.t(:eval_values, 1, [:one, :two])

      input = {
        one: 1, two: -> i { i+1 },
        three: -> i { i+2 }, four: 4,
        more: [{ one: -> i { i }, two: 2 }]
      }

      result = evaluate[input]

      expect(result[:three]).to be_a(Proc)
      expect(result).to include(two: 2)
      expect(result[:more]).to eql([{ one: 1, two: 2 }])
    end
  end
end
