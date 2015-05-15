require 'spec_helper'

describe Transproc::ClassTransformations do
  let(:klass) do
    Struct.new(:name, :age) { include Equalizer.new(:name, :age) }
  end

  describe '.constructor_inject' do
    it 'returns a new object initialized with the given arguments' do
      set_ivars = t(:constructor_inject, 'Jane', 25)

      input = klass
      output = klass.new('Jane', 25)

      expect(set_ivars[input]).to eql(output)
      expect(input).to eql(klass)
    end
  end
end
