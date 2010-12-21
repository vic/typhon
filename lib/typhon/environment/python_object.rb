module Typhon
  module Environment
    # Default implementation that gets replaced later.
    def self.get_python_module()
      nil
    end
    
    # Defines the behaviour of an instance of a python object.
    class PythonObject
      attr_reader :type
      attr_reader :attributes
      attr_reader :from_module
      
      # this is a hash that applies *only* to this
      # object, with no inheritance rules applied.
      # It's for storing cached values since @variables
      # don't work on python_methods.
      attr_reader :cache
      
      class DictWrapper
        def initialize(h)
          @h = h
        end
        def [](name)
          @h[name.to_sym]
        end
        def []=(name, val)
          @h[name.to_sym, val]
        end
        def descriptor; false; end
        def data_descriptor; false; end
      end
      
      def initialize(type, merge_attrs = {}, *args)
        @cache = {}
        @from_module = Typhon::Environment.get_python_module
        @type = type
        @attributes = {
          :__class__ => type,
        }
        @attributes[:__dict__] = DictWrapper.new(@attributes)
        merge_attrs.each {|k,v| @attributes[k]=v }
        instance_eval(&Proc.new) if block_given?
      end
      
      def inspect()
        "<#{@type && @type.module && @type.module[:__name__] || '?'}.#{@type && @type.name || '?'} object at 0x#{object_id.to_s(16)}>"
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
      
      def [](name)
        if (type?)
          descriptor_args = [nil, self]
        else
          descriptor_args = [self, self.type]
        end
        
        # first we look in the parent type's __dict__ for a data descriptor
        topts = type.find(name) do |p|
          at = p.attributes[name]
          if (at && desc = at.data_descriptor)
            return desc.attributes[:__get__].invoke(at, *descriptor_args)
          end
        end
        # then we look in this class (if we're a type ourselves, we look in our own bases)
        if (type?)
          find(name) do |p|
            at = p.attributes[name]
            if (at && desc = at.descriptor)
              return desc.attributes[:__get__].invoke(at, *descriptor_args)
            else
              return at
            end
          end
        elsif (attributes.has_key?(name))
          return attributes[name]
        end
        
        # and then we once again look in the parent type's __dict__, this time
        # allowing for any type of descriptor
        # note we reuse the list from the lookup above since we can expect it to
        # not have changed in the meantime (hopefuly)
        topts && topts.each do |p|
          at = p.attributes[name]
          if (at && desc = at.descriptor)
            return desc.attributes[:__get__].invoke(at, *descriptor_args)
          else
            return at
          end
        end
        raise NameError, "Unknown attribute #{name} on #{self}"
      end
      
      def type?
        return type == Type
      end
      
      def descriptor
        return attributes.has_key?(:__get__) && self || type.descriptor
      end
      def data_descriptor
        return attributes.has_key?(:__get__) && attributes.has_key(:__set__) && self || type.data_descriptor
      end
      
      def []=(name, val)
        delete(name) # make sure it clears any cached method invocation.
        type.find(name) do |p|
          at = p.attributes[name]
          if (desc = p.data_desciptor)
            desc.attributes[:__set__].invoke(at, self, val)
            return val
          end
        end
        return @attributes[name] = val
      end
      # like [] except it allows you to specify a set of other objects to look in as well.
      # Used for module scope lookups.
      def lookup(name, *backups)
        begin
          return self[name]
        rescue NameError
          return backups.shift.lookup(name, *backups) if !backups.empty?
        end
        raise(NameError, "Unknown attribute #{name} on #{self}")
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