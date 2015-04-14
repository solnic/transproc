require 'date'
require 'time'
require 'bigdecimal'
require 'bigdecimal/util'

module Transproc
  module Coercions
    extend Functions

    TRUE_VALUES = [true, 1, '1', 'on', 't', 'true', 'y', 'yes'].freeze
    FALSE_VALUES = [false, 0, '0', 'off', 'f', 'false', 'n', 'no'].freeze

    BOOLEAN_MAP = Hash[
      TRUE_VALUES.product([true]) + FALSE_VALUES.product([false])
    ].freeze

    def to_string(value)
      value.to_s
    end

    def to_symbol(value)
      value.to_sym
    end

    def to_integer(value)
      value.to_i
    end

    def to_float(value)
      value.to_f
    end

    def to_decimal(value)
      value.to_d
    end

    def to_boolean(value)
      Coercions::BOOLEAN_MAP.fetch(value)
    end

    def to_date(value)
      Date.parse(value)
    end

    def to_time(value)
      Time.parse(value)
    end

    def to_datetime(value)
      DateTime.parse(value)
    end
  end
end
