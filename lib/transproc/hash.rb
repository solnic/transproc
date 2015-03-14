module Transproc
  register(:symbolize_keys) do |hash|
    Transproc(:symbolize_keys!)[Hash[hash]]
  end

  register(:symbolize_keys!) do |hash|
    hash.keys.each { |key| hash[key.to_sym] = hash.delete(key) }
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
end
