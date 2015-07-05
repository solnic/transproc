require 'transproc/coercions'

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
  #   # => [{:address=>{:city=>"Boston", :zipcode=>"123"}}, {:address=>{:city=>"NYC", :zipcode=>"312"}}]
  #
  # @api public
  module ArrayTransformations
    extend Registry

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
    def self.map_array(array, fn)
      map_array!(Array[*array], fn)
    end

    # Same as `map_array` but mutates the array
    #
    # @see ArrayTransformations.map_array
    #
    # @api public
    def self.map_array!(array, fn)
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
    def self.wrap(array, key, keys)
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
    def self.group(array, key, keys)
      grouped = Hash.new { |h, k| h[k] = [] }
      array.each do |hash|
        hash = Hash[hash]

        old_group = Transproc::Coercions.to_tuples(hash.delete(key))
        new_group = keys.inject({}) { |a, e| a.merge(e => hash.delete(e)) }

        grouped[hash] << old_group.map { |item| item.merge(new_group) }
      end
      grouped.map do |root, children|
        root.merge(key => children.flatten)
      end
    end

    # Ungroup array values using provided root key and value keys
    #
    # @example
    #   fn = Transproc(:group, :tags, [:tag_name])
    #
    #   fn.call [
    #     { task: 'Group it', tags: [{ tag: 'task' }, { tag: 'important' }]
    #   ]
    #   # => [
    #     { task: 'Group it', tag: 'task' },
    #     { task: 'Group it', tag: 'important' }
    #   ]
    #
    # @param [Array] array The input array
    # @param [Object] key The nesting root key
    # @param [Object] keys The nesting value keys
    #
    # @return [Array]
    #
    # @api public
    def self.ungroup(array, key, keys)
      array.flat_map { |item| HashTransformations.split(item, key, keys) }
    end

    # Combines two arrays by merging child items from right array using join keys
    #
    # @example
    #   fn = t(:combine, [[:tasks, name: :user]])
    #
    #   fn.call([[{ name: 'Jane' }], [{ user: 'Jane', title: 'One' }]])
    #   # => [{:name=>"Jane", :tasks=>[{:user=>"Jane", :title=>"One"}]}]
    #
    # @param [Array<Array>] array The input array
    # @param [Array<Hash>] mappings The mapping definitions array
    #
    # @return [Array<Hash>]
    #
    # @api public
    def self.combine(array, mappings)
      root, groups = array

      cache = Hash.new { |h, k| h[k] = {} }

      root.map { |parent|
        child_hash = {}

        groups.each_with_index do |candidates, index|
          key, keys, group_mappings = mappings[index]

          children =
            if group_mappings
              combine(candidates, group_mappings)
            else
              candidates
            end

          child_keys = keys.values
          pkey_value = parent.values_at(*keys.keys) # ugh

          cache[key][child_keys] ||= children.group_by { |child|
            child.values_at(*child_keys)
          }
          child_arr = cache[key][child_keys][pkey_value] || []

          child_hash.update(key => child_arr)
        end

        parent.merge(child_hash)
      }
    end

    # Converts the array of hashes to array of values, extracted by given key
    #
    # @example
    #   fn = t(:extract_key, :name)
    #   fn.call [
    #     { name: 'Alice', role: 'sender' },
    #     { name: 'Bob', role: 'receiver' },
    #     { role: 'listener' }
    #   ]
    #   # => ['Alice', 'Bob', nil]
    #
    # @param [Array<Hash>] array The input array of hashes
    # @param [Object] key The key to extract values by
    #
    # @return [Array]
    #
    # @api public
    def self.extract_key(array, key)
      extract_key!(Array[*array], key)
    end

    # Same as `extract_key` but mutates the array
    #
    # @see ArrayTransformations.extract_key
    #
    # @api public
    def self.extract_key!(array, key)
      map_array!(array, -> v { v[key] })
    end

    # Wraps every value of the array to tuple with given key
    #
    # The transformation partially inverses the `extract_key`.
    #
    # @example
    #   fn = t(:insert_key, 'name')
    #   fn.call ['Alice', 'Bob', nil]
    #   # => [{ 'name' => 'Alice' }, { 'name' => 'Bob' }, { 'name' => nil }]
    #
    # @param [Array<Hash>] array The input array of hashes
    # @param [Object] key The key to extract values by
    #
    # @return [Array]
    #
    # @api public
    def self.insert_key(array, key)
      insert_key!(Array[*array], key)
    end

    # Same as `insert_key` but mutates the array
    #
    # @see ArrayTransformations.insert_key
    #
    # @api public
    def self.insert_key!(array, key)
      map_array!(array, -> v { { key => v } })
    end

    # Adds missing keys with nil value to all tuples in array
    #
    # @param [Array] keys
    #
    # @return [Array]
    #
    # @api public
    #
    def self.add_keys(array, keys)
      add_keys!(Array[*array], keys)
    end

    # Same as `add_keys` but mutates the array
    #
    # @see ArrayTransformations.add_keys
    #
    # @api public
    def self.add_keys!(array, keys)
      base = keys.inject({}) { |a, e| a.merge(e => nil) }
      map_array!(array, -> v { base.merge(v) })
    end
  end

  ArrayTransformations.singleton_methods(false).each do |meth|
    uses meth, from: ArrayTransformations
  end
end
