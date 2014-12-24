require 'date'

module Transproc
  TRUE_VALUES = [true, 1, '1', 'on', 't', 'true', 'y', 'yes'].freeze
  FALSE_VALUES = [false, 0, '0', 'off', 'f', 'false', 'n', 'no'].freeze

  BOOLEAN_MAP = Hash[
    TRUE_VALUES.product([true]) + FALSE_VALUES.product([false])
  ].freeze

  register(:to_string) do |value|
    value.to_s
  end

  register(:to_integer) do |value|
    value.to_i
  end

  register(:to_float) do |value|
    value.to_f
  end

  register(:to_boolean) do |value|
    BOOLEAN_MAP.fetch(value)
  end

  register(:to_date) do |value|
    Date.parse(value)
  end

  register(:to_datetime) do |value|
    DateTime.parse(value)
  end
end
