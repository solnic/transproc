module Transproc
  Error = Class.new(StandardError)
  FunctionNotFoundError = Class.new(Error)
  FunctionAlreadyRegisteredError = Class.new(Error)
end
