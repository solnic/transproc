require 'spec_helper'

require 'transproc/hash'
require 'transproc/array'

describe 'Array transformations with Transproc' do
  describe 'wrap' do
    it 'returns a new array with wrapped hashes' do
      wrap = Transproc(:wrap, :task, [:title])

      input = [{ name: 'Jane', title: 'One' }]
      output = [{ name: 'Jane', task: { title: 'One' } }]

      expect(wrap[input]).to eql(output)
    end
  end

  describe 'group' do
    it 'returns a new array with grouped hashes' do
      group = Transproc(:group, :tasks, [:title])

      input = [{ name: 'Jane', title: 'One' }, { name: 'Jane', title: 'Two' }]
      output = [{ name: 'Jane', tasks: [{ title: 'One' }, { title: 'Two' }] }]

      expect(group[input]).to eql(output)
    end
  end

  describe 'map_array' do
    it 'applies funtions to all values' do
      map = Transproc(:map_array, Transproc(:symbolize_keys))

      input = [
        { 'name' => 'Jane', 'title' => 'One' },
        { 'name' => 'Jane', 'title' => 'Two' }
      ]

      output = [
        { name: 'Jane', title: 'One' },
        { name: 'Jane', title: 'Two' }
      ]

      expect(map[input]).to eql(output)
    end
  end

  describe 'composition' do
    it 'allows composing transformations' do
      map = Transproc(:map_array, Transproc(:symbolize_keys))
      group = Transproc(:group, :tasks, [:title])

      input = [
        { 'name' => 'Jane', 'title' => 'One' },
        { 'name' => 'Jane', 'title' => 'Two' }
      ]

      output = [{ name: 'Jane', tasks: [{ title: 'One' }, { title: 'Two' }] }]

      transformation = map + group

      expect(transformation[input]).to eql(output)
    end
  end
end
