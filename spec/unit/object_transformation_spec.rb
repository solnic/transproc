require 'spec_helper'

describe Transproc::ObjectTransformations do
  let(:klass) do
    Class.new { include Anima.new(:name, :age) }
  end

  describe '.set_ivars' do
    it 'returns a new object with instance variables from hash key/value pairs' do
      set_ivars = t(:set_ivars, name: 'Jane', age: 25)

      input = klass.allocate
      output = klass.new(name: 'Jane', age: 25)

      expect(set_ivars[input]).to eql(output)
      expect(input).to eql(klass.allocate)
    end
  end

  describe '.set_ivars!' do
    it 'returns an updated object with instance variables from hash key/value pairs' do
      set_ivars = t(:set_ivars!, name: 'Jane', age: 25)

      input = klass.allocate
      output = klass.new(name: 'Jane', age: 25)

      expect(set_ivars[input]).to eql(output)
      expect(input).to eql(output)
    end
  end
end
