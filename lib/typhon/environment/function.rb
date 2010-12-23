module Typhon
  module Environment
    python_class_c :Function, [ObjectBase], 'function', 'function object' do
      # we special case this one because all other code-paths involve calling python.
      def invoke(cm = nil, scope = nil, &block)
        PythonObject.new(Function) do
          self.py_set(:__call__, self)
          if cm
            Rubinius.attach_method(:invoke, cm, scope, self)
          else
            metaclass.send(:define_method, :invoke, &block)
          end
        end
      end
      alias :new :invoke
    end

    python_class_c :BoundFunction, [ObjectBase], 'boundfunction', 'binds a function to the extra arguments passed in (they go before the normal arguments)' do
      def invoke(fobj, *extra)
        PythonObject.new(BoundFunction) do
          self.py_set(:__call__, self)
          self.py_set(:__extra__, extra)
          @extra = extra
          @fobj = fobj
          def self.invoke(*args)
            all_args = @extra + args
            @fobj.invoke(*all_args)
          end
        end
      end
      alias :new :invoke
    end

    module FunctionTools
      def python_method(name, cm = nil, scope = nil, &block)
        self.py_attributes[name] = Function.new(cm, scope, &block)
      end

      def python_class_method(name, cm = nil, scope = nil, &block)
        self.py_attributes[name] = ClassMethod.invoke(Function.new(cm, scope, &block))
      end
    end

    python_class_c :InstanceMethod, [ObjectBase], 'instancemethod', 'instance method' do
      extend FunctionTools

      python_method(:__init__) do |s, func|
        s.py_set(:__func__, func)
      end

      python_method(:__get__) do |s, obj|
        c = s.py_cache
        if !c[:func] || c[:obj] != obj
          c[:func] = BoundFunction.new(s.py_get(:__func__), c[:obj] = obj)
        end
        c[:func]
      end
    end

    python_class_c :ClassMethod, [ObjectBase], 'classmethod', 'class method (binds to obj.py_type)' do
      extend FunctionTools

      python_method(:__init__) do |s, func|
        s.py_set(:__func__, func)
      end

      python_method(:__get__) do |s, obj, type|
        c = s.py_cache
        if !c[:func] || c[:type] != type
          c[:func] = BoundFunction.new(s.py_get(:__func__), c[:type] = type)
        end
        c[:func]
      end
    end

    python_class_c :StaticMethod, [ObjectBase], 'staticmethod', "static method (doesn't bind to anything)" do
      extend FunctionTools

      python_method(:__init__) do |s, func|
        s.py_set(:__func__, func)
      end

      python_method(:__get__) do |s, obj, type|
        s.py_get(:__func__)
      end
    end

    Function.reopen do
      extend FunctionTools

      python_method(:__get__) do |s, obj, type|
        c = s.py_cache
        if !c[:func] || c[:obj] != (obj || type)
          c[:func] = BoundFunction.new(s, c[:obj] = (obj || type))
        end
        c[:func]
      end
    end
  end
end
