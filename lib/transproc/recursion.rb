require 'transproc/conditional'

module Transproc
  # Recursive transformation functions
  #
  # @example
  #   require 'transproc/recursion'
  #
  #   include Transproc::Helper
  #
  #   fn = t(:hash_recursion, t(:symbolize_keys))
  #
  #   fn["name" => "Jane", "address" => { "street" => "Street 1", "zipcode" => "123" }]
  #   # => {:name=>"Jane", :address=>{:street=>"Street 1", :zipcode=>"123"}}
  #
  # @api public
  module Recursion
    extend Functions

    IF_ARRAY = -> fn { Transproc(:is, Array, fn) }

    IF_HASH = -> fn { Transproc(:is, Hash, fn) }

    # Recursively apply the provided transformation function to an array
    #
    # @example
    #   Transproc(:array_recursion, -> s { s.compact })[
    #     [['Joe', 'Jane', nil], ['Smith', 'Doe', nil]]
    #   ]
    #   # =>  [["Joe", "Jane"], ["Smith", "Doe"]]
    #
    # @param [Array]
    #
    # @return [Array]
    #
    # @api public
    def array_recursion(value, fn)
      result = fn[value]
      guarded = IF_ARRAY[-> v { Transproc(:array_recursion, fn)[v] }]

      result.map! do |item|
        guarded[item]
      end
    end

    # Recursively apply the provided transformation function to a hash
    #
    # @example
    #   Transproc(:hash_recursion, Transproc(:symbolize_keys))[
    #     ["name" => "Jane", "address" => { "street" => "Street 1", "zipcode" => "123" }]
    #   ]
    #   # =>  {:name=>"Jane", :address=>{:street=>"Street 1", :zipcode=>"123"}}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def hash_recursion(value, fn)
      result = fn[value]
      guarded = IF_HASH[-> v { Transproc(:hash_recursion, fn)[v] }]

      result.keys.each do |key|
        result[key] = guarded[result.delete(key)]
      end

      result
    end
  end
end
