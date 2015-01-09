module Transproc
  register(:map_array) do |array, *fns|
    Transproc(:map_array!, *fns)[array.dup]
  end

  register(:map_array!) do |array, *fns|
    fn = fns.size == 1 ? fns[0] : fns.reduce(:+)
    array.map! { |value| fn[value] }
  end

  register(:wrap) do |array, key, keys|
    Transproc(:map_array, Transproc(:nest, key, keys))[array]
  end

  register(:group) do |array, key, keys|
    grouped = Hash.new { |hash, key| hash[key] = [] }
    array.each do |hash|
      child = {}
      keys.each { |k| child[k] = hash.delete(k) }
      grouped[hash] << child
    end
    grouped.map do |root, children|
      root.merge(key => children)
    end
  end
end
