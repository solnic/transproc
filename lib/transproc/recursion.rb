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

      result.map! do |item|
        if item.is_a?(::Array)
          Transproc(:array_recursion, fn)[item]
        else
          item
        end
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

      result.keys.each do |key|
        item = result.delete(key)

        if item.is_a?(::Hash)
          result[key] = Transproc(:hash_recursion, fn)[item]
        else
          result[key] = item
        end
      end

      result
    end
  end
end
