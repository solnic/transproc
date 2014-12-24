require 'spec_helper'

require 'transproc/coercions'

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
end
