module Transproc

  # Conditional transformation functions
  #
  # @example
  #   require 'transproc/conditional'
  #
  #   include Transproc::Helper
  #
  #   fn = t(:guard, -> s { s.is_a?(::String) }, -> s { s.to_sym })
  #
  #   [fn[2], fn['Jane']]
  #   # => [2, :Jane]
  #
  # @api public
  module Conditional
    extend Functions

    # Apply the transformation function to subject if the predicate returns true, or return un-modified
    #
    # @example
    #   [2, 'Jane'].map do |subject|
    #     Transproc(:guard, -> s { s.is_a?(::String) }, -> s { s.to_sym })[subject]
    #   end
    #   # => [2, :Jane]
    #
    # @param [Mixed]
    #
    # @return [Mixed]
    #
    # @api public
    def guard(value, predicate, fn)
      predicate[value] ? fn[value] : value
    end
  end
end
