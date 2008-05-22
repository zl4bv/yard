module YARD::CodeObjects
  class ClassObject < NamespaceObject
    attr_accessor :superclass
    
    def initialize(namespace, name, *args, &block)
      @superclass = P(:Object)
      super
    end
    
    def inheritance_tree(include_mods = false)
      list = [self] + (include_mods ? mixins : [])
      if superclass.is_a? Proxy
        list << superclass unless superclass == P(:Object)
      elsif superclass.respond_to? :inheritance_tree
        list += superclass.inheritance_tree
      end
      list
    end
    
    def meths(opts = {})
      opts = SymbolHash[:inheritance => true].update(opts)
      super(opts) + (opts[:inheritance] ? inherited_meths(opts) : [])
    end
    
    def inherited_meths(opts = {})
      inheritance_tree[1..-1].inject([]) do |list, superclass|
        if superclass.is_a?(Proxy)
          list
        else
          list += superclass.meths(opts).reject do |o|
            child(:name => o.name, :scope => o.scope)
          end
        end
      end
    end
    
    def constants(inheritance = true)
      super() + (inheritance ? inherited_constants : [])
    end
    
    def inherited_constants
      inheritance_tree[1..-1].inject([]) do |list, superclass|
        if superclass.is_a?(Proxy)
          list
        else
          list += superclass.constants.reject do |o|
            child(:name => o.name)
          end
        end
      end
    end
    
    ##
    # Sets the superclass of the object
    # 
    # @param [Base, Proxy, String, Symbol] object: the superclass value
    def superclass=(object)
      case object
      when Base, Proxy, NilClass
        @superclass = object
      when String, Symbol
        @superclass = P(namespace, object)
      else
        raise ArgumentError, "superclass must be CodeObject, Proxy, String or Symbol" 
      end
    end
  end
end