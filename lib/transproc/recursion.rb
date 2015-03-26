module Transproc
  register(:array_recursion) do |value, fn|
    result = fn[value]

    result.map! do |item|
      if item.is_a?(::Array)
        Transproc(:array_recursion, fn)[item]
      else
        item
      end
    end
  end

  register(:hash_recursion) do |value, fn|
    result = fn[value]

    result.keys.each do |key|
      item = result.delete(key)

      if item.is_a?(::Hash)
        result[key] = Transproc(:hash_recursion, fn)[item]
      else
        result[key] = item
      end
    end

    result
  end
end
