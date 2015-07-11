# encoding: utf-8

describe Transproc::FunctionNotFoundError do
  it 'complains that the function not registered globally' do
    expect { Transproc(:foo) }.to raise_error do |error|
      expect(error).to be_kind_of described_class
      expect(error.message["foo"]).not_to be_nil
      expect(error.message["global"]).not_to be_nil
    end
  end

  it 'complains that the function not registered locally' do
    Foo = Module.new { extend Transproc::Registry }

    expect { Foo[:foo] }.to raise_error do |error|
      expect(error).to be_kind_of described_class
      expect(error.message["function Foo[:foo]"]).not_to be_nil
    end
  end
end
