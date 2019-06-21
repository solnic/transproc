# frozen_string_literal: true

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
  #   fn["name" => "Jane", "address" => { "street" => "Street 1" }]
  #   # => {:name=>"Jane", :address=>{:street=>"Street 1"}}
  #
  # @api public
  module Recursion
    extend Registry

    IF_ENUMERABLE = -> fn { Conditional[:is, Enumerable, fn] }

    IF_ARRAY = -> fn { Conditional[:is, Array, fn] }

    IF_HASH = -> fn { Conditional[:is, Hash, fn] }

    # Recursively apply the provided transformation function to an enumerable
    #
    # @example
    #   Transproc(:recursion, Transproc(:is, ::Hash, Transproc(:symbolize_keys)))[
    #     {
    #       'id' => 1,
    #       'name' => 'Jane',
    #       'tasks' => [
    #         { 'id' => 1, 'description' => 'Write some code' },
    #         { 'id' => 2, 'description' => 'Write some more code' }
    #       ]
    #     }
    #   ]
    #   => {
    #        :id=>1,
    #        :name=>"Jane",
    #        :tasks=>[
    #          {:id=>1, :description=>"Write some code"},
    #          {:id=>2, :description=>"Write some more code"}
    #        ]
    #      }
    #
    # @param [Enumerable]
    #
    # @return [Enumerable]
    #
    # @api public
    def self.recursion(value, fn)
      result = fn[value]
      guarded = IF_ENUMERABLE[-> v { recursion(v, fn) }]

      case result
      when ::Hash
        result.keys.each do |key|
          result[key] = guarded[result.delete(key)]
        end
      when ::Array
        result.map! do |item|
          guarded[item]
        end
      end

      result
    end

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
    def self.array_recursion(value, fn)
      result = fn[value]
      guarded = IF_ARRAY[-> v { array_recursion(v, fn) }]

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
    def self.hash_recursion(value, fn)
      result = fn[value]
      guarded = IF_HASH[-> v { hash_recursion(v, fn) }]

      result.keys.each do |key|
        result[key] = guarded[result.delete(key)]
      end

      result
    end
  end
end
