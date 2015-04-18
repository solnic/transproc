require 'spec_helper'

describe Transproc::Composer do
  subject(:object) do
    Class.new do
      include Transproc::Composer

      def fn
        compose do |fns|
          fns << t(:map_array, t(:symbolize_keys)) <<
            t(:map_array, t(:map_value, :age, t(:to_integer)))
        end
      end
    end.new
  end

  it 'allows composing functions' do
    expect(object.fn[[{ 'age' => '12' }]]).to eql([{ age: 12 }])
  end
end
