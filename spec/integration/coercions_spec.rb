require 'spec_helper'

describe 'Transproc / Coercions' do
  describe 'to_string' do
    it 'turns integer into a string' do
      expect(Transproc(:to_string)[1]).to eql('1')
    end
  end

  describe 'to_integer' do
    it 'turns string into an integer' do
      expect(Transproc(:to_integer)['1']).to eql(1)
    end
  end

  describe 'to_float' do
    it 'turns string into a float' do
      expect(Transproc(:to_float)['1']).to eql(1.0)
    end

    it 'turns integer into a float' do
      expect(Transproc(:to_float)[1]).to eql(1.0)
    end
  end

  describe 'to_date' do
    it 'turns string into a date' do
      date = Date.new(1983, 11, 18)
      expect(Transproc(:to_date)['18th, November 1983']).to eql(date)
    end
  end

  describe 'to_datetime' do
    it 'turns string into a date' do
      datetime = DateTime.new(2012, 1, 23, 11, 7, 7)
      expect(Transproc(:to_datetime)['2012-01-23 11:07:07']).to eql(datetime)
    end
  end

  describe 'to_boolean' do
    subject(:coercer) { Transproc(:to_boolean) }

    Transproc::TRUE_VALUES.each do |value|
      it "turns #{value.inspect} to true" do
        expect(coercer[value]).to be(true)
      end
    end

    Transproc::FALSE_VALUES.each do |value|
      it "turns #{value.inspect} to false" do
        expect(coercer[value]).to be(false)
      end
    end
  end
end
