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
    names = nil

    array
      .group_by { |hash|
        names ||= hash.keys - keys
        Hash[names.zip(hash.values_at(*names))]
      }
      .map { |root, children|
        children.map! { |child| Hash[keys.zip(child.values_at(*keys))] }
        children.select! { |child| child.values.any? }
        root.merge(key => children)
      }
  end
end
