require 'transproc/transformer/class_interface'

module Transproc
  # Transfomer class for defining transprocs with a class DSL.
  #
  # @example
  #   require 'anima'
  #   require 'transproc/all'
  #
  #   class User
  #     include Anima.new(:name, :address)
  #   end
  #
  #   class Address
  #     include Anima.new(:city, :street, :zipcode)
  #   end
  #
  #   class UsersMapper < Transproc::Transformer
  #     map_array do
  #       symbolize_keys
  #       rename_keys user_name: :name
  #       nest :address, %i(city street zipcode)
  #       map_value :address do
  #         constructor_inject Address
  #       end
  #       constructor_inject User
  #     end
  #   end
  #
  #   UsersMapper.new.call(
  #     [
  #       { 'user_name' => 'Jane',
  #         'city' => 'NYC',
  #         'street' => 'Street 1',
  #         'zipcode' => '123'
  #       }
  #     ]
  #   )
  #   # => [
  #     #<User
  #       name="Jane"
  #       address=#<Address city="NYC" street="Street 1" zipcode="123">>
  #   ]
  #
  # @api public
  class Transformer
    extend ClassInterface

    # Execute the transformation pipeline with the given input.
    #
    # @example
    #
    #   class SymbolizeKeys < Transproc::Transformer
    #     symbolize_keys
    #   end
    #
    #   SymbolizeKeys.new.call('name' => 'Jane')
    #   # => {:name=>"Jane"}
    #
    # @param [mixed] input The input to pass to the pipeline
    #
    # @return [mixed] output The output returned from the pipeline
    #
    # @api public
    def call(input)
      self.class.transproc.call(input)
    end
  end
end
