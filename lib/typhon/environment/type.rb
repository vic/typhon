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
        return bases.first ? bases.first.py_type : Type
      end

      def self.create(bases, name, doc, &init)
        PythonObject.new(determine_type(bases)) do
          @mod = py_from_module
          @bases = bases
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
            self.py_send(:__new__, *args)
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
              if c.py_attributes.has_key?(name)
                yield(c) if block_given?
                found.push(c)
              end
            end
            return found.empty? ? nil : found
          end

          def py_descriptor
            find(:__get__) {|i| return i }
            return nil
          end

          def py_data_descriptor
            find(:__get__) {|i| return i if i.py_attributes[:__set__] }
            return nil
          end

          def reopen(&block)
            instance_eval(&block)
          end

          def reset_module(mod)
            @mod = mod
            @py_attributes[:__module__] = mod
          end

          def module; @mod; end
          def name; @name; end
          def bases; @bases; end
          def method_resolve_order; @mro; end

          def inspect()
            "<type '#{@name}' at 0x#{object_id.to_s(16)}>"
          end

          # Creates a new class with +name+ deriving from self
          def derived_class(mod, name, doc, &init)
            ObjectClass.create(mod, [self], name, doc, &init)
          end

          # Creates a new class and sets const_name to it
          def derived_class_c(const_name, mod, name, doc, m = self, &init)
            m.const_set(const_name.to_sym,
                        ObjectClass.create(mod, [self], name, doc, &init))
          end

          def calculate_mro(ignore_method = false)
            # this method is a little weird because we need to calculate
            # the MRO before methods actually work. As such, this function
            # gets called in initialization, and then it probably calls self[:mro],
            # which calls this again with the ignore_method flag set to true.
            if !ignore_method && mro_meth = py_attributes[:mro]
              return mro_meth.invoke(self)
            else
              # TODO: this is completely and utterly wrong. See:
              # http://www.python.org/download/releases/2.3/mro/
              # for more information on the real algorithm.
              # Also here:
              # http://www.cafepy.com/article/python_attributes_and_methods/python_attributes_and_methods.html
              return [self, *bases.collect {|base| base.calculate_mro }].flatten.uniq
            end
          end

          @mro = calculate_mro()
          py_attributes[:__mro__] = @mro

          instance_eval(&init) if block_given?
        end
      end
    end # ObjectClass

    # Environment.python_class
    def self.python_class(bases, name, doc, &init)
      ObjectClass.create(bases, name, doc, &init)
    end

    # Environment.python_class_c
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
      py_reset_type(self) # make it self-referential

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
          return args[0].py_type
        else
          # TODO: construct a new type from the given information and return it.
          return new(*args)
        end
      end
    end

    ObjectBase.py_reset_type(Type)

    # Include function and re-open things so we can add some functions
    require 'typhon/environment/function'

    ObjectBase.reopen do
      extend FunctionTools
      python_method(:__init__) do |s, *args|
        # do nothing.
      end

      # These should be python_class_method, but that won't work
      # because ClassMethod relies on a valid __new__ and mro.
      python_method(:__new__) do |c, *args|
        PythonObject.new(c) do
          self.py_send(:__init__, *args)
          self
        end
      end

      python_method(:mro) do |c|
        c.calculate_mro(true)
      end
    end
  end
end
