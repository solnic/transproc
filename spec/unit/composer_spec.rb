require 'spec_helper'

describe Transproc::Composer do
  before do
    module Foo
      extend Transproc::Registry
      import Transproc::ArrayTransformations
      import Transproc::HashTransformations
      import Transproc::Coercions
    end
  end

  subject(:object) do
    Class.new do
      include Transproc::Composer

      def fn
        compose do |fns|
          fns << Foo[:map_array, Foo[:symbolize_keys]] <<
            Foo[:map_array, Foo[:map_value, :age, Foo[:to_integer]]]
        end
      end
    end.new
  end

  it 'allows composing functions' do
    expect(object.fn[[{ 'age' => '12' }]]).to eql([{ age: 12 }])
  end

  after { Object.send :remove_const, :Foo }
end
