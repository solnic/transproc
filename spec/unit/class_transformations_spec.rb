require 'dry/equalizer'
require 'spec_helper'

describe Transproc::ClassTransformations do
  describe '.constructor_inject' do
    let(:klass) do
      Struct.new(:name, :age) { include Dry::Equalizer.new(:name, :age) }
    end

    it 'returns a new object initialized with the given arguments' do
      constructor_inject = described_class.t(:constructor_inject, klass)

      input = ['Jane', 25]
      output = klass.new(*input)
      result = constructor_inject[*input]

      expect(result).to eql(output)
      expect(result).to be_instance_of(klass)
    end
  end

  describe '.set_ivars' do
    let(:klass) do
      Class.new do
        include Dry::Equalizer.new(:name, :age)

        attr_reader :name, :age, :test

        def initialize(name:, age:)
          @name = name
          @age = age
          @test = true
        end
      end
    end

    it 'allocates a new object and sets instance variables from hash key/value pairs' do
      set_ivars = described_class.t(:set_ivars, klass)

      input = { name: 'Jane', age: 25 }
      output = klass.new(input)
      result = set_ivars[input]

      expect(result).to eql(output)
      expect(result.test).to be(nil)
      expect(result).to be_instance_of(klass)
    end
  end
end
