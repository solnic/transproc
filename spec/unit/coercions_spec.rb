require 'spec_helper'

describe Transproc::Coercions do
  describe '.to_string' do
    it 'turns integer into a string' do
      expect(described_class.t(:to_string)[1]).to eql('1')
    end
  end

  describe '.to_symbol' do
    it 'turns string into a symbol' do
      expect(described_class.t(:to_symbol)['test']).to eql(:test)
    end
  end

  describe '.to_integer' do
    it 'turns string into an integer' do
      expect(described_class.t(:to_integer)['1']).to eql(1)
    end
  end

  describe '.to_float' do
    it 'turns string into a float' do
      expect(described_class.t(:to_float)['1']).to eql(1.0)
    end

    it 'turns integer into a float' do
      expect(described_class.t(:to_float)[1]).to eql(1.0)
    end
  end

  describe '.to_decimal' do
    it 'turns string into a decimal' do
      expect(described_class.t(:to_decimal)['1.251']).to eql(BigDecimal('1.251'))
    end

    it 'turns float into a decimal' do
      expect(described_class.t(:to_decimal)[1.251]).to eql(BigDecimal('1.251'))
    end

    it 'turns integer into a decimal' do
      expect(described_class.t(:to_decimal)[1]).to eql(BigDecimal('1.0'))
    end
  end

  describe '.to_date' do
    it 'turns string into a date' do
      date = Date.new(1983, 11, 18)
      expect(described_class.t(:to_date)['18th, November 1983']).to eql(date)
    end
  end

  describe '.to_time' do
    it 'turns string into a time object' do
      time = Time.new(2012, 1, 23, 11, 7, 7)
      expect(described_class.t(:to_time)['2012-01-23 11:07:07']).to eql(time)
    end
  end

  describe '.to_datetime' do
    it 'turns string into a date' do
      datetime = DateTime.new(2012, 1, 23, 11, 7, 7)
      expect(described_class.t(:to_datetime)['2012-01-23 11:07:07']).to eql(datetime)
    end
  end

  describe '.to_boolean' do
    subject(:coercer) { described_class.t(:to_boolean) }

    Transproc::Coercions::TRUE_VALUES.each do |value|
      it "turns #{value.inspect} to true" do
        expect(coercer[value]).to be(true)
      end
    end

    Transproc::Coercions::FALSE_VALUES.each do |value|
      it "turns #{value.inspect} to false" do
        expect(coercer[value]).to be(false)
      end
    end
  end

  describe '.to_tuples' do
    subject(:to_tuples) { described_class.t(:to_tuples) }

    context 'non-array' do
      let(:input) { :foo }

      it 'returns an array with one blank tuple' do
        output = [{}]

        expect(to_tuples[input]).to eql(output)
      end
    end

    context 'empty array' do
      let(:input) { [] }

      it 'returns an array with one blank tuple' do
        output = [{}]

        expect(to_tuples[input]).to eql(output)
      end
    end

    context 'array of tuples' do
      let(:input) { [:foo, { bar: :BAZ }, :qux] }

      it 'returns an array with tuples only' do
        output = [{ bar: :BAZ }]

        expect(to_tuples[input]).to eql(output)
      end
    end
  end
end
