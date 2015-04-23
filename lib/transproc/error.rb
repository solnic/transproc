module Transproc
  Error = Class.new(StandardError)
  FunctionNotFoundError = Class.new(Error)
  FunctionAlreadyRegisteredError = Class.new(Error)
  MalformedInputError = Class.new(Error)

  class MalformedInputError < Error
    def initialize(function, value, error)
      @function = function
      @value = value
      @original_error = error
      super("failed to call function #{function} on #{value}, #{error}")
    end

    attr_reader :function, :value, :original_error
  end
end