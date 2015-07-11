# encoding: utf-8

module Transproc
  # Immutable collection of named procedures from external modules
  #
  # @api private
  #
  class Store
    # @!attribute [r] methods
    #
    # @return [Hash] The associated list of imported procedures
    #
    attr_reader :methods

    # @!scope class
    # @!name new(methods = {})
    # Creates an immutable store with a hash of procedures
    #
    # @param [Hash] methods
    #
    # @return [Transproc::Store]

    # @private
    def initialize(methods = {})
      @methods = methods.dup.freeze
      freeze
    end

    # Returns a procedure by its key in the collection
    #
    # @param [Symbol] key
    #
    # @return [Proc]
    #
    def fetch(key)
      methods.fetch(key.to_sym)
    end

    # Imports proc(s) to the collection from another module
    #
    # @overload add(source)
    #   @param  (see #import_methods)
    #   @return (see #import_methods)
    #
    # @overload add(source, options)
    #   @param  (see #import_method)
    #   @return (see #import_method)
    #
    def import(source, options = nil)
      return import_methods(source) if source.instance_of?(Module)
      import_method(source, options)
    end

    protected

    # Creates new immutable collection from the current one,
    # updated with either the module's singleton method,
    # or the proc having been imported from another module.
    #
    # @param [Symbol] source The name of the method, or imported proc
    # @param [Hash] options
    # @option options [Module] :from
    #   The module whose method or imported proc should be added
    # @option options [Symbol] :as
    #   The key for the proc in the current collection
    #
    # @return [Transproc::Store]
    #
    def import_method(source, options)
      src  = options.fetch(:from)
      name = source.to_sym
      key  = options.fetch(:as) { name }.to_sym
      fn   = src.is_a?(Registry) ? src.fetch(name) : src.method(name)

      self.class.new(methods.merge(key => fn))
    end

    # Creates new immutable collection from the current one,
    # updated with all singleton methods and imported methods
    # from the other module
    #
    # @param [Module] source The module to import procedures from
    #
    # @return [Transproc::Store]
    #
    def import_methods(source)
      list =  source.public_methods - Registry.instance_methods - Module.methods
      list -= [:initialize] # for compatibility with Rubinius
      list += source.store.methods.keys if source.is_a? Registry

      list.inject(self) { |a, e| a.import_method(e, from: source) }
    end
  end # class Store
end # module Transproc
