module Transproc
  register(:symbolize_keys) do |hash|
    Hash[hash.map { |k, v| [k.to_sym, v] }]
  end

  register(:map_hash) do |hash, mapping|
    Hash[hash.map { |k, v| [mapping[k], v] }]
  end

  register(:map_key) do |hash, key, fn|
    hash.update(key => fn[hash[key]])
  end
end
