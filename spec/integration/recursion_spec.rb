require 'spec_helper'

describe 'Recursive transformations with Transproc' do
  describe 'array_recursion' do
    let(:original) do
      [
        'foo',
        'bar',
        nil,
        [
          'foo',
          'bar',
          nil,
          [
            'foo',
            'bar',
            nil
          ]
        ]
      ]
    end

    let(:input) { original.dup }

    let(:output) do
      [
        'foo',
        'bar',
        [
          'foo',
          'bar',
          [
            'foo',
            'bar'
          ]
        ]
      ]
    end

    context 'when function is non-destructive' do
      let(:map) { t(:array_recursion, proc { |arr| arr.compact }) }

      it 'applies funtions to all items recursively' do
        expect(map[input]).to eql(output)
        expect(input).to eql(original)
      end
    end

    context 'when function is destructive' do
      let(:map) { t(:array_recursion, proc { |arr| arr.compact! }) }

      it 'applies funtions to all items recursively and destructively' do
        expect(map[input]).to eql(output)
        expect(input).to eql(output)
      end
    end
  end

  describe 'hash_recursion' do
    let(:original) do
      {
        'foo' => 'bar',
        'bar' => {
          'foo' => 'bar',
          'bar' => {
            'foo' => 'bar'
          }
        },
        'baz' => 'bar'
      }
    end

    let(:input) { original.dup }

    let(:output) do
      {
        foo: 'bar',
        bar: {
          foo: 'bar',
          bar: {
            foo: 'bar'
          }
        },
        baz: 'bar'
      }
    end

    context 'when function is non-destructive' do
      let(:map) { t(:hash_recursion, t(:symbolize_keys)) }

      it 'applies funtions to all values recursively' do
        expect(map[input]).to eql(output)
        expect(input).to eql(original)
      end
    end

    context 'when function is destructive' do
      let(:map) { t(:hash_recursion, t(:symbolize_keys!)) }

      it 'applies funtions to all values recursively and destructively' do
        expect(map[input]).to eql(output)
        expect(input).to eql(output)
      end
    end
  end
end
