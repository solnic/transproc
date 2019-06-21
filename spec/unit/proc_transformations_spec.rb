require 'ostruct'
require 'spec_helper'

describe Transproc::ProcTransformations do
  describe '.bind' do
    let(:fn) { described_class.t(:bind, binding, proc) }
    let(:binding) { OpenStruct.new(prefix: prefix) }
    let(:proc) { -> v { [prefix, v].join('_') } }
    let(:prefix) { 'foo' }
    let(:input) { 'bar' }
    let(:output) { 'foo_bar' }

    subject  { fn[input] }

    it 'binds the given proc to the specified binding' do
      is_expected.to eq(output)
    end
  end
end
