module Transproc
  register(:if) do |value, predicate, fn|
    predicate[value] ? fn[value] : value
  end
end
