require 'typhon/environment/python_object'

module Typhon
  module Environment
    # We need to do some magic to make these two things refer to each
    # other in the right way. Type is an ObjectBase of type Type, which has
    # several recursive relationships. So we define ObjectBase first,
    # then define Type and set its type to Type, then we re-open
    # ObjectBase to set its type to Type (and add further definition) as well.
    ObjectClass = PythonObject.new(nil) do
      def self.determine_type(bases)
        # TODO: Look at bases for a proper type.
        return bases.first ? bases.first.type : Type
      end
      
      def self.create(mod, bases, name, doc, &init)
        PythonObject.new(determine_type(bases)) do
          @mod = mod
          @bases = bases
          @mro = [self, *bases] # TODO: This needs to be a lot smarter and less completely wrong.
          @name = name
          @doc = doc
          attrs = {
            :__bases__ => bases,
            :__name__ => name,
            :__doc__ => doc,
            :__module__ => mod,
            :__mro__ => @mro,
          }
          instance_eval(&init) if block_given?

          def self.reopen(&block)
            instance_eval(&block)
          end
      
          def module; @mod; end
          def name; @name; end
          def bases; @bases; end
          def method_resolve_order; @mro; end
          def self.inspect()
            "<type '#{@name}' at 0x#{object_id.to_s(16)}>"
          end
          
          def derived_class(mod, name, doc, &init)
            ObjectClass.create(mod, [self], name, doc, &init)
          end
          def derived_class_c(const_name, mod, name, doc, m = self, &init)
            m.const_set(const_name.to_sym, ObjectClass.create(mod, [self], name, doc, &init))
          end
        end        
      end
    end
    def self.python_class(mod, bases, name, doc, &init)
      ObjectClass.create(mod, bases, name, doc, &init)
    end
    def self.python_class_c(const_name, mod, bases, name, doc, m = self, &init)
      m.const_set(const_name.to_sym, ObjectClass.create(mod, bases, name, doc, &init))
    end
    
    python_class_c :ObjectBase, Environment, [], 'object', 'Base class'
    
    # Future code:
    # find(:__init__) do |obj|
    #  obj[:__init__].invoke(self, *args)
    #  break;
    #end

    python_class_c :Type, Environment, [ObjectBase], 'type', 
      "type(object) -> the object's type\ntype(name,bases,dict) -> new type" do
      reset_type(self) # make it self-referential
      
      def new(name, bases, items = {})
        # do some stuff.
      end
      
      def inspect()
        "<type 'type'>"
      end
      
      def method_resolve_order()
        return @mro
      end
      
      def invoke(*args)
        if (args.count == 1)
          return args[0].type
        else
          # TODO: construct a new type from the given information and return it.
          return new(*args)
        end
      end
    end
    
    ObjectBase.reset_type(Type)
  end
end
    
=begin
    # Specialized behaviour for class objects. They have a more
    # complex name resolution policy in that they search an array
    # of base classes.
    class TypeInstance < Instance
      def self.base_type
        @base_type ||= TypeInstance.new(Environment, [], 'type', 'Base type from which all other types derive.') do
          reset_type(self) # make it self-referential
        end
      end
      
      def self.determine_type_from_bases(bases)
        if (bases.count > 0)
          # TODO: This needs to be considerably less naive
          return bases[0].type
        end
        return nil
      end
      
      def initialize(mod, bases, name, doc, &init)
        @mod = mod
        @bases = bases
        @name = name
        @doc = doc
        attrs = {
          :__bases__ => bases,
          :__name__ => name,
          :__doc__ => doc,
          :__module__ => mod,
        }
        type = TypeInstance.determine_type_from_bases(bases) || TypeInstance.base_type
        super(type, attrs, init)
      end
      
      # yields a parent with a key if there is one, otherwise doesn't yield and
      # returns false. Unlike the basic instance type, this one doesn't search in
      # __class__, but instead searches in __bases__ because __class__ will always
      # be a TypeInstance (it refers to itself)
      def find(key, &block)
        parent = self
        while (parent)
          if (parent.has_key?(key))
            return yield(parent)
          end
          parent = self.parent
        end
        return false
      end
    end
    
    module TypeClass
      def initialize(mod, parent, name, doc, &init)
        @mod = mod
        @parent = parent || Environment
        @name = name
        @attributes = {
          :__builtin__ => Environment,
          :__parent__ => parent,
          :__class_name__ => name,
          :__doc__ => doc,
        }
        instance_eval(&init)
      end
      
      def new(*args, &init)
        i = InstanceClass.new(self, &init)
        __py___init__(i, *args)
        i
      end

      def python_method(name, cm = nil, scope = nil, &block)
        cm ||= block.block.method
        scope ||= Rubinius::StaticScope.new(Environment)
        Rubinius.attach_method(:"__py_#{name}", cm, scope, self)
        @attributes[name] = cm
      end
      
      def __py___init__(s, mod, parent, name, doc)
        @mod = mod
        @parent = parent || Environment
        @name = name
        @attributes = {
          :__builtin__ => Environment,
          :__parent__ => parent,
          :__class_name__ => name,
          :__doc__ => doc,
        }
      end
      
      def attributes
        @attributes
      end
      def parent
        @parent
      end
      def name
        @name
      end
      
      def method_missing(name, *args, &block)
        return @parent.send(name, *args, &block) if @parent
        super(name, *args, &block)
      end
    end
    
    class InstanceClass < TypeClass
      def initialize(type)
        @parent = type
        @attributes = { :__class__ => type }
        instance_eval(&Proc.new) if block_given?
      end
    end
    
    Type = TypeClass.new(nil, nil, 'type', 'The class all classes derive from') do
      python_method :__setattr__ do |s, name, val|
        s.attributes[name] = val
      end
      
      python_method :__delattr__ do |s, name, val|
        s.attributes.delete(name)
        # TODO: undefine the method.
      end
      
      python_method :__getattribute__ do |s, name|
        s.attributes[name.to_sym] || s.parent.__py___getattribute__(s.parent, name.to_sym)
      end
      
      python_method :__dict__ do |s|
        s.attributes
      end
      
      python_method :__str__ do |s|
        "<#{s.name}>"
      end
    end

  end
end
=end
