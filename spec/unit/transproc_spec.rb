require 'spec_helper'

describe Transproc do
  describe 'composition' do
    it 'allows composing two transformation functions' do
      input = '1'
      output = 1.0

      to_i = t(-> value { value.to_i })
      to_f = t(-> value { value.to_f })

      result = to_i >> to_f

      expect(result[input]).to eql(output)
    end
  end

  describe '.register' do
    it 'allows registering functions by name' do
      Transproc.register(:id, -> value { value })

      value = 'hello world'

      result = t(:id)[value]

      expect(result).to be(value)
    end

    it 'allows registering function by passing a block' do
      Transproc.register(:to_boolean1) { |value| value == 'true' }

      result = t(-> value { value.to_s }) >> t(:to_boolean1)

      expect(result[:true]).to be(true)
      expect(result[:false]).to be(false)
    end

    it 'raises a Transproc::FunctionAlreadyRegisteredError if a function is already registered' do
      Transproc.register(:bogus) {}
      expect { Transproc.register(:bogus) {} }.to raise_error(Transproc::FunctionAlreadyRegisteredError)
    end
  end

  describe '.contain?' do
    it 'returns false for absent function' do
      expect(Transproc.contain?(:absent)).to be false
    end

    it 'returns true for registered function' do
      Transproc.register(:my_function, -> value { value })
      expect(Transproc.contain?(:my_function)).to be true
    end
  end

  describe 'nonextistent functions' do
    it 'raises a Transproc::FunctionNotFoundError if asking for function that is non exsistent' do
      expect {
        Transproc(:i_do_not_exist)
        raise('expected the :i_do_not_exist function to not exist')
      }.to raise_error(Transproc::FunctionNotFoundError)
    end
  end

  describe 'accessing a function with args' do
    it 'curries the args' do
      Transproc.register(:map_array, Transproc::ArrayTransformations.t(:map_array))
      Transproc.register(:to_string, Transproc::Coercions.t(:to_string))
      fn = Transproc(:map_array, Transproc(:to_string))

      expect(fn.args).to include(Transproc(:to_string))
    end
  end
end
