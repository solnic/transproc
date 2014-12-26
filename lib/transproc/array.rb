module Transproc
  register(:map_array) do |array, fn|
    Transproc(:map_array!, fn)[array.dup]
  end

  register(:map_array!) do |array, fn|
    array.map! { |value| fn[value] }
  end

  register(:wrap) do |array, key, keys|
    names = nil

    array.map { |hash|
      names ||= hash.keys - keys

      root = Hash[names.zip(hash.values_at(*names))]
      child = Hash[keys.zip(hash.values_at(*keys))]

      root.merge(key => child.values.any? ? child : nil)
    }
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
