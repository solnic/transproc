require 'spec_helper'

describe Transproc::ArrayTransformations do
  let(:hashes) { Transproc::HashTransformations }

  describe '.extract_key' do
    it 'extracts values by key from all hashes' do
      extract_key = described_class.t(:extract_key, 'name')

      input = [
        { 'name' => 'Alice', 'role' => 'sender' },
        { 'name' => 'Bob', 'role' => 'receiver' },
        { 'role' => 'listener' }
      ].freeze

      output = ['Alice', 'Bob', nil]

      expect(extract_key[input]).to eql(output)
    end
  end

  it { expect(described_class).not_to be_contain(:extract_key!) }

  describe '.insert_key' do
    it 'wraps values to tuples with given key' do
      insert_key = described_class.t(:insert_key, 'name')

      input = ['Alice', 'Bob', nil].freeze

      output = [
        { 'name' => 'Alice' },
        { 'name' => 'Bob' },
        { 'name' => nil }
      ]

      expect(insert_key[input]).to eql(output)
    end
  end

  it { expect(described_class).not_to be_contain(:insert_key!) }

  describe '.add_keys' do
    it 'returns a new array with missed keys added to tuples' do
      add_keys = described_class.t(:add_keys, [:foo, :bar, :baz])

      input = [{ foo: 'bar' }, { bar: 'baz' }].freeze

      output = [
        { foo: 'bar', bar: nil, baz: nil },
        { foo: nil, bar: 'baz', baz: nil }
      ]

      expect(add_keys[input]).to eql(output)
    end
  end

  it { expect(described_class).not_to be_contain(:add_keys!) }

  describe '.map_array' do
    it 'applies funtions to all values' do
      map = described_class.t(:map_array, hashes[:symbolize_keys])

      input = [
        { 'name' => 'Jane', 'title' => 'One' }.freeze,
        { 'name' => 'Jane', 'title' => 'Two' }.freeze
      ].freeze

      output = [
        { name: 'Jane', title: 'One' },
        { name: 'Jane', title: 'Two' }
      ]

      expect(map[input]).to eql(output)
    end

    it 'handles huge arrays' do
      map = described_class.t(:map_array, hashes[:symbolize_keys])

      input = Array.new(138_706) { |i| { 'key' => i } }

      expect { map[input] }.to_not raise_error(SystemStackError, %r{stack level too deep})
    end
  end

  it { expect(described_class).not_to be_contain(:map_array!) }

  describe '.wrap' do
    it 'returns a new array with wrapped hashes' do
      wrap = described_class.t(:wrap, :task, [:title])

      input = [{ name: 'Jane', title: 'One' }]
      output = [{ name: 'Jane', task: { title: 'One' } }]

      expect(wrap[input]).to eql(output)
    end

    it 'returns a array new with deeply wrapped hashes' do
      wrap =
        described_class.t(
          :map_array,
          hashes[:nest, :user, [:name, :title]] +
          hashes[:map_value, :user, hashes[:nest, :task, [:title]]]
        )

      input = [{ name: 'Jane', title: 'One' }]
      output = [{ user: { name: 'Jane', task: { title: 'One' } } }]

      expect(wrap[input]).to eql(output)
    end

    it 'adds data to the existing tuples' do
      wrap = described_class.t(:wrap, :task, [:title])

      input  = [{ name: 'Jane', task: { priority: 1 }, title: 'One' }]
      output = [{ name: 'Jane', task: { priority: 1, title: 'One' } }]

      expect(wrap[input]).to eql(output)
    end
  end

  describe '.group' do
    subject(:group) { described_class.t(:group, :tasks, [:title]) }

    it 'returns a new array with grouped hashes' do
      input  = [{ name: 'Jane', title: 'One' }, { name: 'Jane', title: 'Two' }]
      output = [{ name: 'Jane', tasks: [{ title: 'One' }, { title: 'Two' }] }]

      expect(group[input]).to eql(output)
    end

    it 'updates the existing group' do
      input  = [
        {
          name: 'Jane',
          title: 'One',
          tasks: [{ type: 'one' }, { type: 'two' }]
        },
        {
          name: 'Jane',
          title: 'Two',
          tasks: [{ type: 'one' }, { type: 'two' }]
        }
      ]
      output = [
        {
          name: 'Jane',
          tasks: [
            { title: 'One', type: 'one' },
            { title: 'One', type: 'two' },
            { title: 'Two', type: 'one' },
            { title: 'Two', type: 'two' }
          ]
        }
      ]

      expect(group[input]).to eql(output)
    end

    it 'ingnores old values except for array of tuples' do
      input  = [
        { name: 'Jane', title: 'One',   tasks: [{ priority: 1 }, :wrong] },
        { name: 'Jane', title: 'Two',   tasks: :wrong }
      ]
      output = [
        {
          name: 'Jane',
          tasks: [{ title: 'One', priority: 1 }, { title: 'Two' }]
        }
      ]

      expect(group[input]).to eql(output)
    end
  end

  describe '.ungroup' do
    subject(:ungroup) { described_class.t(:ungroup, :tasks, [:title]) }

    it 'returns a new array with ungrouped hashes' do
      input = [{ name: 'Jane', tasks: [{ title: 'One' }, { title: 'Two' }] }]
      output = [{ name: 'Jane', title: 'One' }, { name: 'Jane', title: 'Two' }]

      expect(ungroup[input]).to eql(output)
    end

    it 'returns an input with empty array removed' do
      input = [{ name: 'Jane', tasks: [] }]
      output = [{ name: 'Jane' }]

      expect(ungroup[input]).to eql(output)
    end

    it 'returns an input when a key is absent' do
      input = [{ name: 'Jane' }]
      output = [{ name: 'Jane' }]

      expect(ungroup[input]).to eql(output)
    end

    it 'ungroups array partially' do
      input = [
        {
          name: 'Jane',
          tasks: [
            { title: 'One', type: 'one' },
            { title: 'One', type: 'two' },
            { title: 'Two', type: 'one' },
            { title: 'Two', type: 'two' }
          ]
        }
      ]
      output = [
        {
          name: 'Jane',
          title: 'One',
          tasks: [{ type: 'one' }, { type: 'two' }]
        },
        {
          name: 'Jane',
          title: 'Two',
          tasks: [{ type: 'one' }, { type: 'two' }]
        }
      ]

      expect(ungroup[input]).to eql(output)
    end
  end

  describe '.combine' do
    it 'merges hashes from arrays using provided join keys' do
      input = [
        # parent users
        [
          { name: 'Jane', email: 'jane@doe.org' },
          { name: 'Joe', email: 'joe@doe.org' }
        ],
        [
          [
            # user tasks
            [
              { user: 'Jane', title: 'One' },
              { user: 'Jane', title: 'Two' },
              { user: 'Joe', title: 'Three' }
            ],
            [
              # task tags
              [
                { task: 'One', tag: 'red' },
                { task: 'Three', tag: 'blue' }
              ]
            ]
          ]
        ]
      ]

      output = [
        { name: 'Jane', email: 'jane@doe.org', tasks: [
          { user: 'Jane', title: 'One', tags: [{ task: 'One', tag: 'red' }] },
          { user: 'Jane', title: 'Two', tags: [] }]
        },
        {
          name: 'Joe', email: 'joe@doe.org', tasks: [
            {
              user: 'Joe', title: 'Three', tags: [
                { task: 'Three', tag: 'blue' }
              ]
            }
          ]
        }
      ]

      combine = described_class.t(:combine, [
        [:tasks, { name: :user }, [[:tags, title: :task]]]
      ])

      expect(combine[input]).to eql(output)
    end
  end
end
