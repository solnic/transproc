RSpec.describe Transproc::Transformer, 'instance methods' do
  subject(:transformer) do
    Class.new(Transproc::Transformer[registry]) do
      define! do
        map_array(&:capitalize)
      end

      def capitalize(input)
        input.upcase
      end
    end.new
  end

  let(:registry) do
    Module.new do
      extend Transproc::Registry

      import Transproc::ArrayTransformations
    end
  end

  it 'registers a new transformation function' do
    expect(transformer.call(%w[foo bar])).to eql(%w[FOO BAR])
  end
end
