module Transproc
  module ArrayTransformations
    extend Functions

    def map_array(array, fn)
      Transproc(:map_array!, fn)[Array[*array]]
    end

    def map_array!(array, fn)
      array.map! { |value| fn[value] }
    end

    def wrap(array, key, keys)
      Transproc(:map_array, Transproc(:nest, key, keys))[array]
    end

    def group(array, key, keys)
      grouped = Hash.new { |h, k| h[k] = [] }
      array.each do |hash|
        hash = hash.dup
        child = {}
        keys.each { |k| child[k] = hash.delete(k) }
        grouped[hash] << child
      end
      grouped.map do |root, children|
        root.merge(key => children)
      end
    end
  end
end
