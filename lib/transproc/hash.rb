module Transproc
  register(:map_keys) do |hash, fn|
    Transproc(:map_keys!, fn)[Hash[hash]]
  end

  register(:map_keys!) do |hash, fn|
    hash.keys.each { |key| hash[fn[key]] = hash.delete(key) }
    hash
  end

  register(:symbolize_keys) do |hash|
    Transproc(:symbolize_keys!)[Hash[hash]]
  end

  register(:symbolize_keys!) do |hash|
    Transproc(:map_keys!, Transproc(:to_symbol))[hash]
  end

  register(:stringify_keys) do |hash|
    Transproc(:stringify_keys!)[Hash[hash]]
  end

  register(:stringify_keys!) do |hash|
    Transproc(:map_keys!, Transproc(:to_string))[hash]
  end

  register(:map_values) do |hash, fn|
    Transproc(:map_values!, fn)[Hash[hash]]
  end

  register(:map_values!) do |hash, fn|
    hash.each { |key, value| hash[key] = fn[value] }
    hash
  end

  register(:map_hash) do |hash, mapping|
    Transproc(:map_hash!, mapping)[Hash[hash]]
  end

  register(:map_hash!) do |hash, mapping|
    mapping.each { |k, v| hash[v] = hash.delete(k) }
    hash
  end

  register(:map_key) do |hash, key, fn|
    hash.merge(key => fn[hash[key]])
  end

  register(:map_key!) do |hash, key, fn|
    hash.update(key => fn[hash[key]])
  end

  register(:nest) do |hash, key, keys|
    Transproc(:nest!, key, keys)[Hash[hash]]
  end

  register(:nest!) do |hash, root, keys|
    nest_keys = hash.keys & keys

    if nest_keys.size > 0
      child = Hash[nest_keys.zip(nest_keys.map { |key| hash.delete(key) })]
      hash.update(root => child)
    else
      hash.update(root => {})
    end
  end

  register(:unwrap) do |hash, root, keys|
    copy = Hash[hash].merge(root => Hash[hash[root]])
    Transproc(:unwrap!, root, keys)[copy]
  end

  register(:unwrap!) do |hash, root, keys|
    if nested_hash = hash[root]
      keys ||= nested_hash.keys
      hash.update(Hash[keys.zip(keys.map { |key| nested_hash.delete(key) })])
      hash.delete(root) if nested_hash.empty?
    end

    hash
  end
end
