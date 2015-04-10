require 'spec_helper'

describe 'Conditional transformations with Transproc' do
  describe 'guard' do
    let(:fn) { t(:guard, ->(value) { value.is_a?(::String) }, t(:to_integer)) }

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
