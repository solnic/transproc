require 'date'

module Transproc
  register(:to_string) do |value|
    value.to_s
  end

  register(:to_integer) do |value|
    value.to_i
  end

  register(:to_float) do |value|
    value.to_f
  end

  register(:to_date) do |value|
    Date.parse(value)
  end
end
