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
    extend Registry

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
    def self.map_keys(source_hash, fn)
      Hash[source_hash].tap do |hash|
        hash.keys.each { |key| hash[fn[key]] = hash.delete(key) }
      end
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
    def self.symbolize_keys(hash)
      map_keys(hash, Coercions[:to_symbol].fn)
    end

    # Symbolize keys in a hash recursively
    #
    # @example
    #
    #   input = { 'foo' => 'bar', 'baz' => [{ 'one' => 1 }] }
    #
    #   t(:deep_symbolize_keys)[input]
    #   # => { :foo => "bar", :baz => [{ :one => 1 }] }
    #
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def self.deep_symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), output|
        output[key.to_sym] =
          case value
          when Hash
            deep_symbolize_keys(value)
          when Array
            value.map { |item|
              item.is_a?(Hash) ? deep_symbolize_keys(item) : item
            }
          else
            value
          end
      end
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
    def self.stringify_keys(hash)
      map_keys(hash, Coercions[:to_string].fn)
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
    def self.map_values(source_hash, fn)
      Hash[source_hash].tap do |hash|
        hash.each { |key, value| hash[key] = fn[value] }
      end
    end

    # Rename all keys in a hash using provided mapping hash
    #
    # @example
    #   Transproc(:rename_keys, user_name: :name)[user_name: 'Jane']
    #   # => {:name => "Jane"}
    #
    # @param [Hash] source_hash The input hash
    # @param [Hash] mapping The key-rename mapping
    #
    # @return [Hash]
    #
    # @api public
    def self.rename_keys(source_hash, mapping)
      Hash[source_hash].tap do |hash|
        mapping.each { |k, v| hash[v] = hash.delete(k) if hash.key?(k) }
      end
    end

    # Copy all keys in a hash using provided mapping hash
    #
    # @example
    #   Transproc(:copy_keys, user_name: :name)[user_name: 'Jane']
    #   # => {:user_name => "Jane", :name => "Jane"}
    #
    # @param [Hash] source_hash The input hash
    # @param [Hash] mapping The key-copy mapping
    #
    # @return [Hash]
    #
    # @api public
    def self.copy_keys(source_hash, mapping)
      Hash[source_hash].tap do |hash|
        mapping.each do |original_key, new_keys|
          [*new_keys].each do |new_key|
            hash[new_key] = hash[original_key]
          end
        end
      end
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
    def self.reject_keys(hash, keys)
      Hash[hash].reject { |k, _| keys.include?(k) }
    end

    # Accepts specified keys from a hash
    #
    # @example
    #   Transproc(:accept_keys, [:name])[name: 'Jane', email: 'jane@doe.org']
    #   # => {:name=>"Jane"}
    #
    # @param [Hash] hash The input hash
    # @param [Array] keys The keys to be accepted
    #
    # @return [Hash]
    #
    # @api public
    def self.accept_keys(hash, keys)
      reject_keys(hash, hash.keys - keys)
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
    def self.map_value(hash, key, fn)
      hash.merge(key => fn[hash[key]])
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
    def self.nest(hash, root, keys)
      child = {}

      keys.each do |key|
        child[key] = hash[key] if hash.key?(key)
      end

      output = Hash[hash]

      child.each_key { |key| output.delete(key) }

      old_root = hash[root]

      if old_root.is_a?(Hash)
        output[root] = old_root.merge(child)
      else
        output[root] = child
      end

      output
    end

    # Collapse a nested hash from a specified key
    #
    # @example
    #   Transproc(:unwrap, :address, [:street, :zipcode])[address: { street: 'Street', zipcode: '123' }]
    #   # => {street: "Street", zipcode: "123"}
    #
    # @param [Hash] source_hash
    # @param [Mixed] root The root key to unwrap values from
    # @param [Array] selected The keys that should be unwrapped (optional)
    # @param [Hash] options hash of options (optional)
    # @option options [Boolean] :prefix if true, unwrapped keys will be prefixed
    #                           with the root key followed by an underscore (_)
    #
    # @return [Hash]
    #
    # @api public
    def self.unwrap(source_hash, root, selected = nil, prefix: false)
      return source_hash unless source_hash[root]

      add_prefix = ->(key) do
        combined = [root, key].join('_')
        root.is_a?(::Symbol) ? combined.to_sym : combined
      end

      Hash[source_hash].merge(root => Hash[source_hash[root]]).tap do |hash|
        nested_hash = hash[root]
        keys = nested_hash.keys
        keys &= selected if selected
        new_keys = prefix ? keys.map(&add_prefix) : keys

        hash.update(Hash[new_keys.zip(keys.map { |key| nested_hash.delete(key) })])
        hash.delete(root) if nested_hash.empty?
      end
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
    def self.fold(hash, key, tuple_key)
      hash.merge(key => ArrayTransformations.extract_key(hash[key], tuple_key))
    end

    # Splits hash to array by all values from a specified key
    #
    # The operation adds missing keys extracted from the array to regularize the output.
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
    #   Transproc(:split, :tasks, [:priority])[input]
    #   => [
    #       { name: 'Joe', priority: 1,   tasks: [{ title: 'sleep well' }]              },
    #       { name: 'Joe', priority: 2,   tasks: [{ title: 'be nice' }, { title: nil }] },
    #       { name: 'Joe', priority: nil, tasks: [{ title: 'be cool' }]                 }
    #     ]
    #
    # @param [Hash] hash
    # @param [Object] key The key to split a hash by
    # @param [Array] subkeys The list of subkeys to be extracted from key
    #
    # @return [Array<Hash>]
    #
    # @api public
    def self.split(hash, key, keys)
      list = Array(hash[key])
      return [hash.reject { |k, _| k == key }] if list.empty?

      existing  = list.flat_map(&:keys).uniq
      grouped   = existing - keys
      ungrouped = existing & keys

      list = ArrayTransformations.group(list, key, grouped) if grouped.any?
      list = list.map { |item| item.merge(reject_keys(hash, [key])) }
      ArrayTransformations.add_keys(list, ungrouped)
    end

    # Recursively evaluate hash values if they are procs/lambdas
    #
    # @example
    #   hash = {
    #     num: -> i { i + 1 },
    #     str: -> i { "num #{i}" }
    #   }
    #
    #   t(:eval_values, 1)[hash]
    #   # => {:num => 2, :str => "num 1" }
    #
    #   # with filters
    #   t(:eval_values, 1, [:str])[hash]
    #   # => {:num => #{still a proc}, :str => "num 1" }
    #
    # @param [Hash]
    # @param [Array,Object] args Anything that should be passed to procs
    # @param [Array] filters A list of attribute names that should be evaluated
    #
    # @api public
    def self.eval_values(hash, args, filters = [])
      hash.each_with_object({}) do |(key, value), output|
        output[key] =
          case value
          when Proc
            if filters.empty? || filters.include?(key)
              value.call(*args)
            else
              value
            end
          when Hash
            eval_values(value, args, filters)
          when Array
            value.map { |item|
              item.is_a?(Hash) ? eval_values(item, args, filters) : item
            }
          else
            value
          end
      end
    end

    # Merge a hash recursively
    #
    # @example
    #
    #   input = { 'foo' => 'bar', 'baz' => { 'one' => 1 } }
    #   other = { 'foo' => 'buz', 'baz' => { :one => 'one', :two => 2 } }
    #
    #   t(:deep_merge)[input, other]
    #   # => { 'foo' => "buz", :baz => { :one => 'one', 'one' => 1, :two => 2 } }
    #
    # @param [Hash]
    # @param [Hash]
    #
    # @return [Hash]
    #
    # @api public
    def self.deep_merge(hash, other)
      Hash[hash].merge(other) do |_, original_value, new_value|
        if original_value.respond_to?(:to_hash) &&
           new_value.respond_to?(:to_hash)
          deep_merge(Hash[original_value], Hash[new_value])
        else
          new_value
        end
      end
    end
  end
end
