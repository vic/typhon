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
      
      def self.create(bases, name, doc, &init)
        PythonObject.new(determine_type(bases)) do
          @mod = from_module
          @bases = bases
          @mro = [self, *bases] # TODO: This needs to be a lot smarter and less completely wrong.
          @name = name
          @doc = doc
          attrs = {
            :__bases__ => bases,
            :__name__ => name,
            :__doc__ => doc,
            :__module__ => @mod,
            :__mro__ => @mro,
          }
          
          def invoke(*args)
            self[:__new__].invoke(*args)
          end
          def new(*args, &block)
            o = invoke(*args)
            o.instance_eval(&block) if block
            o
          end
          
          # Returns all parents with a key if there are any. Otherwise nil.
          # If a block is given, yields them instead. Unlike #find, this
          # one doesn't look at the type of the object, only its bases.
          # Uses __class__.__mro__ to define search order
          def find(name)
            found = []
            method_resolve_order.each do |c|
              if (c.attributes.has_key?(name))
                yield(c) if block_given?
                found.push(c)
              end
            end
            return found.empty? ? nil : found
          end
          
          def descriptor
            find(:__get__) {|i| return i }
            return nil
          end
          def data_descriptor
            find(:__get__) {|i| return i if (i.attributes[:__set__]) }
            return nil
          end
          
          def reopen(&block)
            instance_eval(&block)
          end
          def reset_module(mod)
            @mod = mod
            @attributes[:__module__] = mod
          end
      
          def module; @mod; end
          def name; @name; end
          def bases; @bases; end
          def method_resolve_order; @mro; end
          def inspect()
            "<type '#{@name}' at 0x#{object_id.to_s(16)}>"
          end
          
          def derived_class(mod, name, doc, &init)
            ObjectClass.create(mod, [self], name, doc, &init)
          end
          def derived_class_c(const_name, mod, name, doc, m = self, &init)
            m.const_set(const_name.to_sym, ObjectClass.create(mod, [self], name, doc, &init))
          end

          instance_eval(&init) if block_given?
        end        
      end
    end
    def self.python_class(bases, name, doc, &init)
      ObjectClass.create(bases, name, doc, &init)
    end
    def self.python_class_c(const_name, bases, name, doc, m = self, &init)
      m.const_set(const_name.to_sym, ObjectClass.create(bases, name, doc, &init))
    end
    
    python_class_c :ObjectBase, [], 'object', 'Base class'
    
    # Future code:
    # find(:__init__) do |obj|
    #  obj[:__init__].invoke(self, *args)
    #  break;
    #end

    python_class_c :Type, [ObjectBase], 'type', 
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
    
    # Include function and re-open things so we can add some functions
    require 'typhon/environment/function'
    
    ObjectBase.reopen do
      extend FunctionTools
      python_method(:__init__) do |s, *args|
        # do nothing.
      end
      
      python_method(:__new__) do |c, *args|
        PythonObject.new(c) do
          self[:__init__].invoke(*args)
          self
        end
      end
    end
  end
end