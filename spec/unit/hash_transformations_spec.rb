require 'spec_helper'
require 'transproc/rspec'

describe Transproc::HashTransformations do
  describe '.map_keys' do
    it 'returns a new hash with given proc applied to keys' do
      map_keys = described_class.t(:map_keys, ->(key) { key.strip })

      input = { ' foo ' => 'bar' }.freeze
      output = { 'foo' => 'bar' }

      expect(map_keys[input]).to eql(output)
    end
  end

  it { expect(described_class).not_to be_contain(:map_keys!) }

  describe '.symbolize_keys' do
    it 'returns a new hash with symbolized keys' do
      symbolize_keys = described_class.t(:symbolize_keys)

      input = { 1 => 'bar' }.freeze
      output = { '1'.to_sym => 'bar' }

      expect(symbolize_keys[input]).to eql(output)
    end
  end

  describe '.deep_symbolize_keys' do
    it 'returns a new hash with symbolized keys' do
      symbolize_keys = described_class.t(:deep_symbolize_keys)

      input = { 'foo' => 'bar', 'baz' => [{ 'one' => 1 }, 'two'] }
      output = { foo: 'bar', baz: [{ one: 1 }, 'two'] }

      expect(symbolize_keys[input]).to eql(output)
      expect(input).to eql('foo' => 'bar', 'baz' => [{ 'one' => 1 }, 'two'])
    end
  end

  it { expect(described_class).not_to be_contain(:symbolize_keys!) }

  describe '.stringify_keys' do
    it 'returns a new hash with stringified keys' do
      stringify_keys = described_class.t(:stringify_keys)

      input = { foo: 'bar' }.freeze
      output = { 'foo' => 'bar' }

      expect(stringify_keys[input]).to eql(output)
    end
  end

  it { expect(described_class).not_to be_contain(:stringify_keys!) }

  describe '.map_values' do
    it 'returns a new hash with given proc applied to values' do
      map_values = described_class.t(:map_values, ->(value) { value.strip })

      input = { 'foo' => ' bar ' }.freeze
      output = { 'foo' => 'bar' }

      expect(map_values[input]).to eql(output)
    end
  end

  it { expect(described_class).not_to be_contain(:map_values!) }

  describe '.rename_keys' do
    it 'returns a new hash with applied functions' do
      map = described_class.t(:rename_keys, 'foo' => :foo)

      input = { 'foo' => 'bar', :bar => 'baz' }.freeze
      output = { foo: 'bar', bar: 'baz' }

      expect(map[input]).to eql(output)
    end

    it 'only renames keys and never creates new ones' do
      map = described_class.t(:rename_keys, 'foo' => :foo, 'bar' => :bar)

      input = { 'bar' => 'baz' }.freeze
      output = { bar: 'baz' }

      expect(map[input]).to eql(output)
    end
  end

  it { expect(described_class).not_to be_contain(:rename_keys!) }

  describe '.copy_keys' do
    context 'with single destination key' do
      it 'returns a new hash with applied functions' do
        map = described_class.t(:copy_keys, 'foo' => :foo)

        input = { 'foo' => 'bar', :bar => 'baz' }.freeze
        output = { 'foo' => 'bar', foo: 'bar', bar: 'baz' }

        expect(map[input]).to eql(output)
      end
    end

    context 'with multiple destination keys' do
      it 'returns a new hash with applied functions' do
        map = described_class.t(:copy_keys, 'foo' => [:foo, :baz])

        input = { 'foo' => 'bar', :bar => 'baz' }.freeze
        output = { 'foo' => 'bar', foo: 'bar', baz: 'bar', bar: 'baz' }

        expect(map[input]).to eql(output)
      end
    end
  end

  it { expect(described_class).not_to be_contain(:copy_keys!) }

  describe '.map_value' do
    it 'applies function to value under specified key' do
      transformation =
        described_class.t(:map_value, :user, described_class.t(:symbolize_keys))

      input = { user: { 'name' => 'Jane' }.freeze }.freeze
      output = { user: { name: 'Jane' } }

      expect(transformation[input]).to eql(output)
    end
  end

  it { expect(described_class).not_to be_contain(:map_value!) }

  describe '.nest' do
    it 'returns new hash with keys nested under a new key' do
      nest = described_class.t(:nest, :baz, ['foo'])

      input = { 'foo' => 'bar' }.freeze
      output = { baz: { 'foo' => 'bar' } }

      expect(nest[input]).to eql(output)
    end

    it 'returns new hash with keys nested under the existing key' do
      nest = described_class.t(:nest, :baz, ['two'])

      input = {
        'foo' => 'bar',
        baz: { 'one' => nil }.freeze,
        'two' => false
      }.freeze

      output = { 'foo' => 'bar', baz: { 'one' => nil, 'two' => false } }

      expect(nest[input]).to eql(output)
    end

    it 'rewrites the existing key if its value is not a hash' do
      nest = described_class.t(:nest, :baz, ['two'])

      input  = { 'foo' => 'bar', baz: 'one', 'two' => false }.freeze
      output = { 'foo' => 'bar', baz: { 'two' => false } }

      expect(nest[input]).to eql(output)
    end

    it 'returns new hash with an empty hash under a new key when nest-keys are missing' do
      nest = described_class.t(:nest, :baz, ['foo'])

      input = { 'bar' => 'foo' }.freeze
      output = { 'bar' => 'foo', baz: {} }

      expect(nest[input]).to eql(output)
    end
  end

  it { expect(described_class).not_to be_contain(:nest!) }

  describe '.unwrap' do
    it 'returns new hash with nested keys lifted to the root' do
      unwrap = described_class.t(:unwrap, 'wrapped', %w(one))

      input = {
        'foo' => 'bar',
        'wrapped' => { 'one' => nil, 'two' => false }.freeze
      }.freeze

      output = { 'foo' => 'bar', 'one' => nil, 'wrapped' => { 'two' => false } }

      expect(unwrap[input]).to eql(output)
    end

    it 'lifts all keys if none are passed' do
      unwrap = described_class.t(:unwrap, 'wrapped')

      input = { 'wrapped' => { 'one' => nil, 'two' => false }.freeze }.freeze
      output = { 'one' => nil, 'two' => false }

      expect(unwrap[input]).to eql(output)
    end

    it 'ignores unknown keys' do
      unwrap = described_class.t(:unwrap, 'wrapped', %w(one two three))

      input = { 'wrapped' => { 'one' => nil, 'two' => false }.freeze }.freeze
      output = { 'one' => nil, 'two' => false }

      expect(unwrap[input]).to eql(output)
    end

    it 'prefixes unwrapped keys and retains root string type if prefix option is truthy' do
      unwrap = described_class.t(:unwrap, 'wrapped', prefix: true)

      input = { 'wrapped' => { one: nil, two: false }.freeze }.freeze
      output = { 'wrapped_one' => nil, 'wrapped_two' => false }

      expect(unwrap[input]).to eql(output)
    end

    it 'prefixes unwrapped keys and retains root type if prefix option is truthy' do
      unwrap = described_class.t(:unwrap, :wrapped, prefix: true)

      input = { wrapped: { 'one' => nil, 'two' => false }.freeze }.freeze
      output = { wrapped_one: nil, wrapped_two: false }

      expect(unwrap[input]).to eql(output)
    end
  end

  it { expect(described_class).not_to be_contain(:unwrap!) }

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
      map = described_class.t :rename_keys, user_name: :name, user_email: :email

      transformation = symbolize_keys >> map

      input = { 'user_name' => 'Jade', 'user_email' => 'jade@doe.org' }
      output = { name: 'Jade', email: 'jade@doe.org' }

      result = transformation[input]

      expect(result).to eql(output)
    end
  end

  describe '.reject_keys' do
    it 'returns a new hash with rejected keys' do
      reject_keys = described_class.t(:reject_keys, [:name, :age])

      input = { name: 'Jane', email: 'jane@doe.org', age: 21 }.freeze
      output = { email: 'jane@doe.org' }

      expect(reject_keys[input]).to eql(output)
    end
  end

  it { expect(described_class).not_to be_contain(:reject_keys!) }

  describe '.accept_keys' do
    it 'returns a new hash with rejected keys' do
      accept_keys = described_class.t(:accept_keys, [:age])

      input = { name: 'Jane', email: 'jane@doe.org', age: 21 }.freeze
      output = { age: 21 }

      expect(accept_keys[input]).to eql(output)
    end
  end

  it { expect(described_class).not_to be_contain(:accept_keys!) }

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
        one: 1, two: -> i { i + 1 },
        three: -> i { i + 2 }, four: 4,
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
        one: 1, two: -> i { i + 1 },
        three: -> i { i + 2 }, four: 4,
        array: [{ one: -> i { i }, two: 2 }],
        hash: { one: -> i { i } }
      }

      result = evaluate[input]

      expect(result[:three]).to be_a(Proc)
      expect(result).to include(two: 2)
      expect(result[:array]).to eql([{ one: 1, two: 2 }])
      expect(result[:hash]).to eql(one: 1)
    end
  end

  describe '.deep_merge' do
    let(:hash) {
      {
        name: 'Jane',
        email: 'jane@doe.org',
        favorites:
          {
            food: 'stroopwafel'
          }
      }
    }

    let(:update) {
      {
        email: 'jane@example.org',
        favorites:
          {
            color: 'orange'
          }
      }
    }

    it 'recursively merges hash values' do
      deep_merge = described_class.t(:deep_merge)
      output = {
        name: 'Jane',
        email: 'jane@example.org',
        favorites: { food: 'stroopwafel', color: 'orange' }
      }

      expect(deep_merge[hash, update]).to eql(output)
    end

    it 'does not alter the provided arguments' do
      original_hash = hash.dup
      original_update = update.dup

      described_class.t(:deep_merge)[hash, update]

      expect(hash).to eql(original_hash)
      expect(update).to eql(original_update)
    end
  end
end
