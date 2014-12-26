module Transproc
  register(:symbolize_keys) do |hash|
    Transproc(:symbolize_keys!)[hash.dup]
  end

  register(:symbolize_keys!) do |hash|
    hash.keys.each { |key| hash[key.to_sym] = hash.delete(key) }
    hash
  end

  register(:map_hash) do |hash, mapping|
    Transproc(:map_hash!, mapping)[hash.dup]
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
end
