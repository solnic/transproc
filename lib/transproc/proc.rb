# frozen_string_literal: true

module Transproc
  # Transformation functions for Procs
  #
  # @example
  #   require 'ostruct'
  #   require 'transproc/proc'
  #
  #   include Transproc::Helper
  #
  #   fn = t(
  #     :map_value,
  #     'foo_bar',
  #     t(:bind, OpenStruct.new(prefix: 'foo'), -> s { [prefix, s].join('_') })
  #   )
  #
  #   fn["foo_bar" => "bar"]
  #   # => {"foo_bar" => "foo_bar"}
  #
  # @api public
  module ProcTransformations
    extend Registry

    # Change the binding for the given function
    #
    # @example
    #   Transproc(
    #     :bind,
    #     OpenStruct.new(prefix: 'foo'),
    #     -> s { [prefix, s].join('_') }
    #   )['bar']
    #   # => "foo_bar"
    #
    # @param [Proc]
    #
    # @return [Proc]
    #
    # @api public
    def self.bind(value, binding, fn)
      binding.instance_exec(value, &fn)
    end
  end
end
