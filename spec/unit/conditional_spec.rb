# frozen_string_literal: true

describe Transproc::Conditional do
  describe '.not' do
    let(:fn) { described_class.t(:not, -> value { value.is_a? String }) }
    subject  { fn[input] }

    context 'when predicate returns truthy value' do
      let(:input)  { 'foo' }
      let(:output) { false }

      it 'applies the first transformation' do
        expect(subject).to eql output
      end
    end

    context 'when predicate returns falsey value' do
      let(:input)  { :foo }
      let(:output) { true }

      it 'applies the first transformation' do
        expect(subject).to eql output
      end
    end
  end

  describe '.guard' do
    let(:fn) { described_class.t(:guard, condition, operation) }
    let(:condition) { ->(value) { value.is_a?(::String) } }
    let(:operation) { Transproc::Coercions.t(:to_integer) }

    context 'when predicate returns truthy value' do
      it 'applies the transformation and returns the result' do
        input = '2'

        expect(fn[input]).to eql(2)
      end
    end

    context 'when predicate returns falsey value' do
      it 'returns the original value' do
        input = { 'foo' => 'bar' }

        expect(fn[input]).to eql('foo' => 'bar')
      end
    end
  end
end
