module Transproc
  Error = Class.new(StandardError)
  FunctionAlreadyRegisteredError = Class.new(Error)

  class FunctionNotFoundError < Error
    def initialize(function, source = nil)
      return super "No registered function #{source}[:#{function}]" if source
      super "No globally registered function for #{function}"
    end
  end
end
