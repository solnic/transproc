# frozen_string_literal: true

module Transproc
  # Function container extension
  #
  # @example
  #   module MyTransformations
  #     extend Transproc::Functions
  #
  #     def boom!(value)
  #       "#{value} BOOM!"
  #     end
  #   end
  #
  #   Transproc(:boom!)['w00t!'] # => "w00t! BOOM!"
  #
  # @api public
  module Functions
    def self.extended(mod)
      warn 'Transproc::Functions is deprecated please switch to Transproc::Registry'
      super
    end

    def method_added(meth)
      module_function meth
      Transproc.register(meth, method(meth))
    end
  end
end
