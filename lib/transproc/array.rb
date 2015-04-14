require 'transproc/hash'

module Transproc
  # Transformation functions for Array objects
  #
  # @example
  #   require 'transproc/array'
  #
  #   include Transproc::Helper
  #
  #   fn = t(:map_array, t(:symbolize_keys)) >> t(:wrap, :address, [:city, :zipcode])
  #
  #   fn.call(
  #     [
  #       { 'city' => 'Boston', 'zipcode' => '123' },
  #       { 'city' => 'NYC', 'zipcode' => '312' }
  #     ]
  #   )
  #   # => [{ city: 'Boston', zipcode: '123' }, { city: 'NYC', zipcode: '312' }]
  #
  #
  module ArrayTransformations
    extend Functions

    # Map array values using transformation function
    #
    # @example
    #
    #   fn = Transproc(:map_array, -> v { v.upcase })
    #
    #   fn.call ['foo', 'bar'] # => ["FOO", "BAR"]
    #
    # @param [Array] array The input array
    # @param [Proc] fn The transformation function
    #
    # @return [Array]
    #
    # @api public
    def map_array(array, fn)
      map_array!(Array[*array], fn)
    end

    # Same as `map_array` but mutates the array
    #
    # @see ArrayTransformations.map_array
    #
    # @api public
    def map_array!(array, fn)
      array.map! { |value| fn[value] }
    end

    # Wrap array values using HashTransformations.nest function
    #
    # @example
    #   fn = Transproc(:wrap, :address, [:city, :zipcode])
    #
    #   fn.call [{ city: 'NYC', zipcode: '123' }]
    #   # => [{ address: { city: 'NYC', zipcode: '123' } }]
    #
    # @param [Array] array The input array
    # @param [Object] key The nesting root key
    # @param [Object] keys The nesting value keys
    #
    # @return [Array]
    #
    # @api public
    def wrap(array, key, keys)
      map_array(array, Transproc(:nest, key, keys))
    end

    # Group array values using provided root key and value keys
    #
    # @example
    #   fn = Transproc(:group, :tags, [:tag_name])
    #
    #   fn.call [
    #     { task: 'Group it', tag: 'task' },
    #     { task: 'Group it', tag: 'important' }
    #   ]
    #   # => [{ task: 'Group it', tags: [{ tag: 'task' }, { tag: 'important' }]]
    #
    # @param [Array] array The input array
    # @param [Object] key The nesting root key
    # @param [Object] keys The nesting value keys
    #
    # @return [Array]
    #
    # @api public
    def group(array, key, keys)
      grouped = Hash.new { |h, k| h[k] = [] }
      array.each do |hash|
        hash = hash.dup
        child = {}
        keys.each { |k| child[k] = hash.delete(k) }
        grouped[hash] << child
      end
      grouped.map do |root, children|
        root.merge(key => children)
      end
    end
  end
end
