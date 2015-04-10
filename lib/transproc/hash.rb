require 'transproc/coercions'

module Transproc
  module HashTransformations
    module_function

    def symbolize_keys(hash)
      Transproc(:symbolize_keys!)[Hash[hash]]
    end

    def map_keys(hash, fn)
      Transproc(:map_keys!, fn)[Hash[hash]]
    end

    def map_keys!(hash, fn)
      hash.keys.each { |key| hash[fn[key]] = hash.delete(key) }
      hash
    end

    def symbolize_keys!(hash)
      Transproc(:map_keys!, Transproc(:to_symbol))[hash]
    end

    def stringify_keys(hash)
      Transproc(:stringify_keys!)[Hash[hash]]
    end

    def stringify_keys!(hash)
      Transproc(:map_keys!, Transproc(:to_string))[hash]
    end

    def map_values(hash, fn)
      Transproc(:map_values!, fn)[Hash[hash]]
    end

    def map_values!(hash, fn)
      hash.each { |key, value| hash[key] = fn[value] }
      hash
    end

    def map_hash(hash, mapping)
      Transproc(:map_hash!, mapping)[Hash[hash]]
    end

    def map_hash!(hash, mapping)
      mapping.each { |k, v| hash[v] = hash.delete(k) }
      hash
    end

    def map_key(hash, key, fn)
      hash.merge(key => fn[hash[key]])
    end

    def map_key!(hash, key, fn)
      hash.update(key => fn[hash[key]])
    end

    def nest(hash, key, keys)
      Transproc(:nest!, key, keys)[Hash[hash]]
    end

    def nest!(hash, root, keys)
      nest_keys = hash.keys & keys

      if nest_keys.size > 0
        child = Hash[nest_keys.zip(nest_keys.map { |key| hash.delete(key) })]
        hash.update(root => child)
      else
        hash.update(root => {})
      end
    end

    def unwrap(hash, root, keys)
      copy = Hash[hash].merge(root => Hash[hash[root]])
      Transproc(:unwrap!, root, keys)[copy]
    end

    def unwrap!(hash, root, keys = nil)
      if nested_hash = hash[root]
        keys ||= nested_hash.keys
        hash.update(Hash[keys.zip(keys.map { |key| nested_hash.delete(key) })])
        hash.delete(root) if nested_hash.empty?
      end

      hash
    end

    Transproc.register_from(self)
  end
end
