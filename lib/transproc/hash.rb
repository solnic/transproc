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
      Transproc(:map_keys!, fn)[Hash[hash]]
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
      Transproc(:symbolize_keys!)[Hash[hash]]
    end

    # Same as `:symbolize_keys` but mutates the hash
    #
    # @see HashTransformations.symbolize_keys!
    #
    # @api public
    def symbolize_keys!(hash)
      Transproc(:map_keys!, Transproc(:to_symbol))[hash]
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
      Transproc(:stringify_keys!)[Hash[hash]]
    end

    # Same as `:stringify_keys` but mutates the hash
    #
    # @see HashTransformations.stringify_keys
    #
    # @api public
    def stringify_keys!(hash)
      Transproc(:map_keys!, Transproc(:to_string))[hash]
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
      Transproc(:map_values!, fn)[Hash[hash]]
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
    #   Transproc(:map_hash, user_name: :name)[user_name: 'Jane']
    #   # => {:name => "Jane"}
    #
    # @param [Hash] hash The input hash
    # @param [Hash] mapping The key-rename mapping
    #
    # @return [Hash]
    #
    # @api public
    def map_hash(hash, mapping)
      Transproc(:map_hash!, mapping)[Hash[hash]]
    end

    # Same as `:map_hash` but mutates the hash
    #
    # @see HashTransformations.map_hash
    #
    # @api public
    def map_hash!(hash, mapping)
      mapping.each { |k, v| hash[v] = hash.delete(k) }
      hash
    end

    # Map a key in a hash with the provided transformation function
    #
    # @example
    #   Transproc(:map_key, -> s { s.upcase })['name' => 'jane']
    #   # => {"name" => "jane"}
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def map_key(hash, key, fn)
      hash.merge(key => fn[hash[key]])
    end

    # Same as `:map_key` but mutates the hash
    #
    # @see HashTransformations.map_key!
    #
    # @api public
    def map_key!(hash, key, fn)
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
      Transproc(:nest!, key, keys)[Hash[hash]]
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
    def unwrap(hash, root, keys)
      copy = Hash[hash].merge(root => Hash[hash[root]])
      Transproc(:unwrap!, root, keys)[copy]
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
  end
end
