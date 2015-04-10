module Transproc
  module Conditional
    module_function

    def guard(value, predicate, fn)
      predicate[value] ? fn[value] : value
    end

    Transproc.register_from(self)
  end
end
