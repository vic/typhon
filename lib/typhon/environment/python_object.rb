module Typhon
  module Environment

    # Default implementation that gets replaced later.
    def self.get_python_module()
      nil
    end

    # Defines the behaviour of an instance of a python object.
    module PythonObjectMixin

      class DictWrapper
        def initialize(h)
          @h = h
        end

        def py_get(name)
          @h[name.to_sym]
        end

        def py_set(name, val)
          @h[name.to_sym, val]
        end

        def py_descriptor; false; end
        def py_data_descriptor; false; end
      end

      attr_reader :py_type
      attr_reader :py_attributes
      attr_reader :py_from_module

      # this is a hash that applies *only* to this
      # object, with no inheritance rules applied.
      # It's for storing cached values since @variables
      # don't work on python_methods.
      attr_reader :py_cache

      def py_init(type, merge_attrs = {}, *args, &block)
        @py_cache = {}
        @py_from_module = Environment.get_python_module
        @py_type = type
        @py_attributes = {
          :__class__ => type,
        }
        @py_attributes[:__dict__] = DictWrapper.new(@py_attributes)
        merge_attrs.each {|k,v| @py_attributes[k]=v }
        instance_eval(&block) if block
      end

      def py_reset_type(new_type)
        @py_type = new_type
        @py_attributes[:__class__] = new_type
      end

      def py_get(name, flags = {})
        overload_self = flags[:with_self] || self

        if py_type?
          descriptor_args = [nil, overload_self]
        else
          descriptor_args = [overload_self, overload_self.py_type]
        end

        # first we look in the parent type's __dict__ for a data descriptor
        topts = py_type.find(name) do |p|
          at = p.py_attributes[name]
          if at && desc = at.py_data_descriptor
            return desc.py_attributes[:__get__].py_invoke(at, *descriptor_args)
          end
        end
        # then we look in this class (if we're a type ourselves, we look in our own bases)
        if py_type?
          find(name) do |p|
            at = p.py_attributes[name]
            if at && desc = at.py_descriptor
              return desc.py_attributes[:__get__].py_invoke(at, *descriptor_args)
            else
              return at
            end
          end
        elsif py_attributes.has_key?(name)
          return py_attributes[name]
        end

        # and then we once again look in the parent type's __dict__, this time
        # allowing for any type of descriptor
        # note we reuse the list from the lookup above since we can expect it to
        # not have changed in the meantime (hopefuly)
        topts && topts.each do |p|
          at = p.py_attributes[name]
          if at && desc = at.py_descriptor
            return desc.py_attributes[:__get__].py_invoke(at, *descriptor_args)
          else
            return at
          end
        end
        raise AttributeError.new("Unknown attribute #{name} on #{overload_self}".to_py)
      end

      def py_type?
        return py_type == Type
      end

      def py_descriptor
        return py_attributes.has_key?(:__get__) && self || py_type.py_descriptor
      end

      def py_data_descriptor
        return py_attributes.has_key?(:__get__) && py_attributes.has_key?(:__set__) && self || py_type.py_data_descriptor
      end

      def py_set(name, val)
        py_del(name) # make sure it clears any cached method invocation.
        py_type.find(name) do |p|
          at = p.py_attributes[name]
          if desc = p.py_data_desciptor
            desc.py_attributes[:__set__].py_invoke(at, self, val)
            return val
          end
        end
        @py_attributes[name] = val
      end

      # like [] except it allows you to specify a set of other objects to look in as well.
      # Used for module scope lookups.
      def py_lookup(name, *backups)
        begin
          return self.py_get(name)
        rescue NameError
          return backups.shift.py_lookup(name, *backups) if !backups.empty?
        end
        raise AttributeError.new("Unknown attribute #{name} on #{self}".to_py)
      end

      def py_has_attrib?(name)
        return true if py_attributes[name]
        py_type.find(name) {|p| return true }
        return false
      end

      def py_del(name)
        @py_attributes.delete(name)
      end

      def py_send(method, *args)
        py_get(method).invoke(*args)
      end

      # Default behaviour for object invocation. If there's an __call__
      # attribute we defer to it, otherwise we blow up
      def py_invoke(*args)
        py_send(:__call__, *args)
      end
    end

    # Defines a mixin that can be used on things like Integer that is
    # essentially read only and provides very few traits. It turns the
    # class (as opposed to the object) into a PythonObject and returns
    # information from that while making it read-only.
    # Remember to call py_init on the class.
    module PythonSingleton
      def self.included(o)
        o.extend(PythonObjectMixin)
      end

      def py_type?; false; end
      def py_descriptor; nil; end
      def py_data_descriptor; nil; end
      def py_invoke(*args); raise TypeError.new("Can't invoke an singleton object of type #{type}"); end
      def py_type; self.class.py_type; end
      def py_get(name); self.class.py_get(name, :with_self => self); end
      def py_set(name, val); raise AttributeError.new("Can't set attributes on singleton object of type #{type}"); end
      def py_send(name, *args); self.class.py_get(name, :with_self => self).invoke(*args); end
      def py_cache; self.class.py_cache; end
    end

    class PythonObject
      include PythonObjectMixin

      def initialize(*args, &block)
        py_init(*args, &block)
      end

      def inspect()
        "<#{@type && @type.module && @type.module[:__name__] || '?'}.#{@type && @type.name || '?'} object at 0x#{object_id.to_s(16)}>"
      end

      def to_s
        inspect
      end
    end
  end
end
