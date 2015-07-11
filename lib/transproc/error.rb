module Transproc
  Error = Class.new(StandardError)
  FunctionAlreadyRegisteredError = Class.new(Error)

  class FunctionNotFoundError < Error
    def initialize(function, source = nil)
      return super "No registered function #{source}[:#{function}]" if source
      super "No globally registered function for #{function}"
    end
  end

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
