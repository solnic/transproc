require 'transproc/array'
require 'transproc/coercions'

module Transproc
  # Transformation functions for Hash objects
  #
  # @example
  #   require 'transproc/hash'
  #
  #   include Transproc::Helper
  #
  #   fn = t(:symbolize_keys) >> t(:nest, :address, [:street, :zipcode])
  #
  #   fn["street" => "Street 1", "zipcode" => "123"]
  #   # => {:address => {:street => "Street 1", :zipcode => "123"}}
  #
  # @api public
  module HashTransformations
    extend Functions

    # Map all keys in a hash with the provided transformation function
    #
    # @example
    #   Transproc(:map_keys, -> s { s.upcase })['name' => 'Jane']
    #   # => {"NAME" => "Jane"}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def map_keys(hash, fn)
      map_keys!(Hash[hash], fn)
    end

    # Same as `:map_keys` but mutates the hash
    #
    # @see HashTransformations.map_keys
    #
    # @api public
    def map_keys!(hash, fn)
      hash.keys.each { |key| hash[fn[key]] = hash.delete(key) }
      hash
    end

    # Symbolize all keys in a hash
    #
    # @example
    #   Transproc(:symbolize_keys)['name' => 'Jane']
    #   # => {:name => "Jane"}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def symbolize_keys(hash)
      symbolize_keys!(Hash[hash])
    end

    # Same as `:symbolize_keys` but mutates the hash
    #
    # @see HashTransformations.symbolize_keys!
    #
    # @api public
    def symbolize_keys!(hash)
      map_keys!(hash, Transproc(:to_symbol).fn)
    end

    # Stringify all keys in a hash
    #
    # @example
    #   Transproc(:stringify_keys)[:name => 'Jane']
    #   # => {"name" => "Jane"}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def stringify_keys(hash)
      stringify_keys!(Hash[hash])
    end

    # Same as `:stringify_keys` but mutates the hash
    #
    # @see HashTransformations.stringify_keys
    #
    # @api public
    def stringify_keys!(hash)
      map_keys!(hash, Transproc(:to_string).fn)
    end

    # Map all values in a hash using transformation function
    #
    # @example
    #   Transproc(:map_values, -> v { v.upcase })[:name => 'Jane']
    #   # => {"name" => "JANE"}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def map_values(hash, fn)
      map_values!(Hash[hash], fn)
    end

    # Same as `:map_values` but mutates the hash
    #
    # @see HashTransformations.map_values
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def map_values!(hash, fn)
      hash.each { |key, value| hash[key] = fn[value] }
      hash
    end

    # Rename all keys in a hash using provided mapping hash
    #
    # @example
    #   Transproc(:rename_keys, user_name: :name)[user_name: 'Jane']
    #   # => {:name => "Jane"}
    #
    # @param [Hash] hash The input hash
    # @param [Hash] mapping The key-rename mapping
    #
    # @return [Hash]
    #
    # @api public
    def rename_keys(hash, mapping)
      rename_keys!(Hash[hash], mapping)
    end

    # Same as `:rename_keys` but mutates the hash
    #
    # @see HashTransformations.rename_keys
    #
    # @api public
    def rename_keys!(hash, mapping)
      mapping.each { |k, v| hash[v] = hash.delete(k) }
      hash
    end

    # Same as `:reject_keys` but mutates the hash
    #
    # @see HashTransformations.reject_keys
    #
    # @api public
    def reject_keys!(hash, keys)
      hash.reject { |k, _| keys.include?(k) }
    end

    # Rejects specified keys from a hash
    #
    # @example
    #   Transproc(:reject_keys, [:name])[name: 'Jane', email: 'jane@doe.org']
    #   # => {:email => "jane@doe.org"}
    #
    # @param [Hash] hash The input hash
    # @param [Array] keys The keys to be rejected
    #
    # @return [Hash]
    #
    # @api public
    def reject_keys(hash, keys)
      reject_keys!(Hash[hash], keys)
    end

    # Same as `:accept_keys` but mutates the hash
    #
    # @see HashTransformations.reject_keys
    #
    # @api public
    def accept_keys!(hash, keys)
      reject_keys!(hash, hash.keys - keys)
    end

    # Accepts specified keys from a hash
    #
    # @example
    #   Transproc(:accept_keys, [:name])[name: 'Jane', email: 'jane@doe.org']
    #   # => {:email => "jane@doe.org"}
    #
    # @param [Hash] hash The input hash
    # @param [Array] keys The keys to be accepted
    #
    # @return [Hash]
    #
    # @api public
    def accept_keys(hash, keys)
      accept_keys!(Hash[hash], keys)
    end

    # Map a key in a hash with the provided transformation function
    #
    # @example
    #   Transproc(:map_value, 'name', -> s { s.upcase })['name' => 'jane']
    #   # => {"name" => "JANE"}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def map_value(hash, key, fn)
      hash.merge(key => fn[hash[key]])
    end

    # Same as `:map_value` but mutates the hash
    #
    # @see HashTransformations.map_value!
    #
    # @api public
    def map_value!(hash, key, fn)
      hash.update(key => fn[hash[key]])
    end

    # Nest values from specified keys under a new key
    #
    # @example
    #   Transproc(:nest, :address, [:street, :zipcode])[street: 'Street', zipcode: '123']
    #   # => {address: {street: "Street", zipcode: "123"}}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def nest(hash, key, keys)
      nest!(Hash[hash], key, keys)
    end

    # Same as `:nest` but mutates the hash
    #
    # @see HashTransformations.nest
    #
    # @api public
    def nest!(hash, root, keys)
      nest_keys = hash.keys & keys

      if nest_keys.size > 0
        child = Hash[nest_keys.zip(nest_keys.map { |key| hash.delete(key) })]
        hash.update(root => child)
      else
        hash.update(root => {})
      end
    end

    # Collapse a nested hash from a specified key
    #
    # @example
    #   Transproc(:unwrap, :address, [:street, :zipcode])[address: { street: 'Street', zipcode: '123' }]
    #   # => {street: "Street", zipcode: "123"}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def unwrap(hash, root, keys = nil)
      copy = Hash[hash].merge(root => Hash[hash[root]])
      unwrap!(copy, root, keys)
    end

    # Same as `:unwrap` but mutates the hash
    #
    # @see HashTransformations.unwrap
    #
    # @api public
    def unwrap!(hash, root, keys = nil)
      if nested_hash = hash[root]
        keys ||= nested_hash.keys
        hash.update(Hash[keys.zip(keys.map { |key| nested_hash.delete(key) })])
        hash.delete(root) if nested_hash.empty?
      end

      hash
    end

    # Folds array of tuples to array of values from a specified key
    #
    # @example
    #   source = {
    #     name: "Jane",
    #     tasks: [{ title: "be nice", priority: 1 }, { title: "sleep well" }]
    #   }
    #   Transproc(:fold, :tasks, :title)[source]
    #   # => { name: "Jane", tasks: ["be nice", "sleep well"] }
    #   Transproc(:fold, :tasks, :priority)[source]
    #   # => { name: "Jane", tasks: [1, nil] }
    #
    # @param [Hash] hash
    # @param [Object] key The key to fold values to
    # @param [Object] tuple_key The key to take folded values from
    #
    # @return [Hash]
    #
    # @api public
    def fold(hash, key, tuple_key)
      fold!(hash.dup, key, tuple_key)
    end

    # Same as `:fold` but mutates the hash
    #
    # @see HashTransformations.fold
    #
    # @api public
    def fold!(hash, key, tuple_key)
      hash.merge!(key => ArrayTransformations.extract_key(hash[key], tuple_key))
    end

    # Splits hash to array by all values from a specified key
    #
    # @example
    #   input = {
    #     name: 'Joe',
    #     tasks: [
    #       { title: 'sleep well', priority: 1 },
    #       { title: 'be nice',    priority: 2 },
    #       {                      priority: 2 },
    #       { title: 'be cool'                 }
    #     ]
    #   }
    #   Transproc(:split, :tasks, [:priority])
    #   => [
    #       { name: 'Joe', priority: 1, tasks: [{ title: 'sleep well' }]              },
    #       { name: 'Joe', priority: 2, tasks: [{ title: 'be nice' }, { title: nil }] },
    #       { name: 'Joe',              tasks: [{ title: 'be cool' }]                 }
    #     ]
    #
    # @param [Hash] hash
    # @param [Object] key The key to split a hash by
    # @param [Array] subkeys The list of subkeys to be extracted from key
    #
    # @return [Array<Hash>]
    #
    # @api public
    def split(hash, key, keys)
      list = hash.fetch(key, [{}])
      group_by = list.flat_map(&:keys).uniq - keys
      list = ArrayTransformations.group(list, key, group_by) if group_by.any?
      clone = -> item { item.merge(reject_keys(hash, [key])) }
      list.map(&clone)
    end
  end
end
