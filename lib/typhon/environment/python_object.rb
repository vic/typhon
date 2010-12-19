module Typhon
  module Environment
    # Defines the behaviour of an instance of a python object.
    class PythonObject
      attr_reader :type
      attr_reader :attributes
      
      def initialize(type, merge_attrs = {}, *args)
        @type = type
        @attributes = {
          :__class__ => type,
        }
        merge_attrs.each {|k,v| @attributes[k]=v }
        instance_eval(&Proc.new) if block_given?
      end
      
      def inspect()
        "<#{@type && @type.module.name || '?'}.#{@type && @type.name || '?'} object at 0x#{object_id.to_s(16)}>"
      end
      
      def to_s
        inspect
      end
      
      def reset_type(new_type)
        @type = new_type
        @attributes[:__class__] = type
      end
      
      def _meta
        class <<self; self; end
      end
      
      # Returns all parents with a key if there are any. Otherwise nil.
      # If a block is given, yields them instead.
      # Uses __class__.__mro__ to define search order
      def find(name)
        found = []
        mro = @type && @type.method_resolve_order()
        mro ||= []
        [self, *mro].each do |c|
          if (c.attributes.has_key?(name))
            yield(c) if block_given?
            found.push(c)
          end
        end
        return found.empty? ? nil : found
      end
      
      def [](name)
        find(name) {|parent| return parent.attributes[name] }
        raise(NameError, "Unknown attribute #{name} on #{self}")
      end
      def []=(name, val)
        delete(name) # make sure it clears any cached method invocation.
        @attributes[name] = val
      end
      def has_key?(name)
        find(name) {|p| return true }
        return false
      end
      def delete(name)
        @attributes.delete(name)
        _meta.instance_eval do
          remove_method("__py_#{name}") if respond_to?("__py_#{name}")
        end
      end
      
      # Default behaviour for object invocation. If there's an __call__
      # attribute we defer to it, otherwise we blow up
      def invoke(*args)
        self[:__call__].invoke(*args)
      end
    end
  end
end