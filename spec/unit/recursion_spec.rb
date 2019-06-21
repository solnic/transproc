# frozen_string_literal: true

describe Transproc::Recursion do
  let(:hashes) { Transproc::HashTransformations }

  describe '.recursion' do
    let(:original) do
      {
        'foo' => 'bar',
        'bar' => {
          'foo' => 'bar',
          'bar' => %w(foo bar baz),
          'baz' => 'foo'
        },
        'baz' => 'bar'
      }
    end

    let(:input) { original.dup }

    let(:output) do
      {
        'foo' => 'bar',
        'bar' => {
          'foo' => 'bar',
          'bar' => %w(foo bar)
        }
      }
    end

    context 'when function is non-destructive' do
      let(:map) do
        described_class.t(:recursion, -> enum {
          enum.reject { |v| v == 'baz' }
        })
      end

      it 'applies funtions to all items recursively' do
        expect(map[input]).to eql(output)
        expect(input).to eql(original)
      end
    end

    context 'when function is destructive' do
      let(:map) do
        described_class.t(:recursion, -> enum {
          enum.reject! { |v| v == 'baz' }
        })
      end

      it 'applies funtions to all items recursively and destructively' do
        expect(map[input]).to eql(output)
        expect(input).to eql(output)
      end
    end
  end

  describe '.array_recursion' do
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
          %w(foo bar)
        ]
      ]
    end

    context 'when function is non-destructive' do
      let(:map) { described_class.t(:array_recursion, proc(&:compact)) }

      it 'applies funtions to all items recursively' do
        expect(map[input]).to eql(output)
        expect(input).to eql(original)
      end
    end

    context 'when function is destructive' do
      let(:map) { described_class.t(:array_recursion, proc(&:compact!)) }

      it 'applies funtions to all items recursively and destructively' do
        expect(map[input]).to eql(output)
        expect(input).to eql(output)
      end
    end
  end

  describe '.hash_recursion' do
    let(:input) do
      {
        'foo' => 'bar',
        'bar' => {
          'foo' => 'bar',
          'bar' => {
            'foo' => 'bar'
          }.freeze
        }.freeze,
        'baz' => 'bar'
      }.freeze
    end

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

    let(:map) do
      described_class.t(:hash_recursion, hashes.t(:symbolize_keys))
    end

    it 'applies funtions to all values recursively' do
      expect(map[input]).to eql(output)
    end
  end
end
