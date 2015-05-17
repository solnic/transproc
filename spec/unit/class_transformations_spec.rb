require 'spec_helper'

describe Transproc::ClassTransformations do
  let(:klass) do
    Struct.new(:name, :age) { include Equalizer.new(:name, :age) }
  end

  describe '.constructor_inject' do
    it 'returns a new object initialized with the given arguments' do
      constructor_inject = t(:constructor_inject, klass)

      input = ['Jane', 25]
      output = klass.new(*input)
      result = constructor_inject[*input]

      expect(result).to eql(output)
      expect(result).to be_instance_of(klass)
    end
  end
end
