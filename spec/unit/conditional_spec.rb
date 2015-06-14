require 'spec_helper'

describe Transproc::Conditional do
  describe '.itself' do
    let(:fn) { t(:itself) }

    it 'returns the original value' do
      expect(fn[:foo]).to eql :foo
    end
  end

  describe '.not' do
    let(:fn) { t(:not, -> value { value.is_a? String }) }
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

  describe '.iif' do
    let(:predicate)  { -> value { value['o'] } }
    let(:on_success) { -> value { value.upcase } }
    let(:on_fail)    { -> value { value.downcase } }
    let(:fn) { t(:iif, predicate, on_success, on_fail) }

    subject { fn[input] }

    context 'when predicate returns truthy value' do
      let(:input)  { 'Foo' }
      let(:output) { 'FOO' }

      it 'applies the first transformation' do
        expect(subject).to eql output
      end
    end

    context 'when predicate returns falsey value' do
      let(:input)  { 'Bar' }
      let(:output) { 'bar' }

      it 'applies the second transformation' do
        expect(subject).to eql output
      end
    end
  end

  describe '.guard' do
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

  describe '.is' do
    let(:fn) { t(:is, ::String, -> value { value.to_sym }) }
    subject  { fn[input] }

    context 'when type-check passes' do
      let(:input)  { 'foo' }
      let(:output) { :foo  }

      it 'applies the transformation' do
        expect(subject).to eql output
      end
    end

    context 'when type-check fails' do
      let(:input)  { 1 }
      let(:output) { 1 }

      it 'returns the original value' do
        expect(subject).to eql output
      end
    end
  end
end
