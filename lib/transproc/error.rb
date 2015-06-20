module Transproc
  Error = Class.new(StandardError)
  FunctionNotFoundError = Class.new(Error)
  FunctionAlreadyRegisteredError = Class.new(Error)

  class MalformedInputError < Error
    attr_reader :function, :value, :original_error

    def initialize(function, value, error)
      @function = function
      @value = value
      @original_error = error
      super "Failed to call_function #{function} with #{value.inspect} - #{error}"
      set_backtrace(error.backtrace)
    end
  end
end
