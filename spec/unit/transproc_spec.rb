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
      Transproc.register(:identity, -> value { value })

      value = 'hello world'

      result = t(:identity)[value]

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
      fn = Transproc(:map_array, Transproc(:to_string))

      expect(fn.args).to include(Transproc(:to_string))
    end
  end

  describe 'handling malformed input' do
    it 'raises a Transproc::MalformedInputError' do
      expect {
        Transproc(:to_integer)[{}]
      }.to raise_error(Transproc::MalformedInputError)

      begin
        Transproc(:to_integer)[{}]
      rescue Transproc::MalformedInputError => e
        expect(e.message).to include('to_integer')
        expect(e.message).to include("undefined method `to_i'")
        expect(e.backtrace).to eql(e.original_error.backtrace)
      end
    end
  end
end
