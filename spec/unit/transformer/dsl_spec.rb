RSpec.describe Transproc::Transformer do
  let(:container) { Module.new { extend Transproc::Registry } }
  let(:klass) { Transproc::Transformer[container] }
  let(:transformer) { klass.new }

  context 'when invalid method is used' do
    it 'raises an error on initialization' do
      klass.define! do
        not_valid
      end

      expect { klass.new }.to raise_error(Transproc::Compiler::InvalidFunctionNameError, /not_valid/)
    end
  end
end
