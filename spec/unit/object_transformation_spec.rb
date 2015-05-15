require 'spec_helper'

describe Transproc::ObjectTransformations do
  let(:object) do
    Class.new do
      def initialize(attributes = {})
        attributes.each do |(ivar_name, ivar_value)|
          instance_variable_set("@#{ivar_name}", ivar_value)
        end
      end

      def eql?(other)
        instance_values == other.instance_values
      end

      def instance_values
        instance_variables.each_with_object({}) do |(key, value), instance_value_hash|
          instance_value_hash[key] = value
        end
      end
    end
  end

  describe '.set_ivars' do
    it 'returns a new object with instance variables from hash key/value pairs' do
      set_ivars = t(:set_ivars, { name: 'Jane', age: 25 })

      input = object.new
      output = object.new(name: 'Jane', age: 25)

      expect(set_ivars[input]).to eql(output)
      expect(input).to eql(object.new)
    end
  end

  describe '.set_ivars!' do
    it 'returns an updated object with instance variables from hash key/value pairs' do
      set_ivars = t(:set_ivars!, { name: 'Jane', age: 25 })

      input = object.new
      output = object.new(name: 'Jane', age: 25)

      expect(set_ivars[input]).to eql(output)
      expect(input).to eql(output)
    end
  end
end
