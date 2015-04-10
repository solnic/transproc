module Transproc
  module Recursion
    module_function

    def array_recursion(value, fn)
      result = fn[value]

      result.map! do |item|
        if item.is_a?(::Array)
          Transproc(:array_recursion, fn)[item]
        else
          item
        end
      end
    end

    def hash_recursion(value, fn)
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

    Transproc.register_from(self)
  end
end
