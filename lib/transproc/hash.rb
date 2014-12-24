module Transproc
  register(:symbolize_keys) do |hash|
    Hash[hash.map { |k, v| [k.to_sym, v] }]
  end

  register(:map) do |hash, mapping|
    Hash[hash.map { |k, v| [mapping[k], v] }]
  end
end
