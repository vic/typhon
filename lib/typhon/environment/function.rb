module Typhon
  module Environment
    python_class_c :Function, [ObjectBase], 'function', 'function object' do
      # we special case this one because all other code-paths involve calling python.
      def invoke(cm = nil, scope = nil, &block)
        PythonObject.new(Function) do
          self[:__call__] = self
          if (cm)
            Rubinius.attach_method(:invoke, cm, scope, self)
          else
            _meta.send(:define_method, :invoke, &block)
          end
        end
      end
      alias :new :invoke
    end
    
    python_class_c :BoundFunction, [ObjectBase], 'boundfunction', 'binds a function to the extra arguments passed in (they go before the normal arguments)' do
      def invoke(fobj, *extra)
        PythonObject.new(BoundFunction) do
          self[:__call__] = self
          self[:__extra__] = extra
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
        self.attributes[name] = Function.new(cm, scope, &block)
      end
      
      def python_class_method(name, cm = nil, scope = nil, &block)
        self.attributes[name] = ClassMethod.invoke(Function.new(cm, scope, &block))
      end
    end
    
    python_class_c :InstanceMethod, [ObjectBase], 'instancemethod', 'instance method' do
      extend FunctionTools
      
      python_method(:__init__) do |s, func|
        s[:__func__] = func
      end
      
      python_method(:__get__) do |s, obj|
        c = s.cache
        if (!c[:func] || c[:obj] != obj)
          c[:func] = BoundFunction.new(s[:__func__], c[:obj] = obj)
        end
        c[:func]
      end
    end
    
    python_class_c :ClassMethod, [ObjectBase], 'classmethod', 'class method (binds to obj.type)' do
      extend FunctionTools
      
      python_method(:__init__) do |s, func|
        s[:__func__] = func
      end
      
      python_method(:__get__) do |s, obj, type|
        c = s.cache
        if (!c[:func] || c[:type] != type)
          c[:func] = BoundFunction.new(s[:__func__], c[:type] = type)
        end
        c[:func]
      end
    end
    
    python_class_c :StaticMethod, [ObjectBase], 'staticmethod', "static method (doesn't bind to anything)" do
      extend FunctionTools
      
      python_method(:__init__) do |s, func|
        s[:__func__] = func
      end
      
      python_method(:__get__) do |s, obj, type|
        s[:__func__]
      end
    end
    
    Function.reopen do
      extend FunctionTools
      
      python_method(:__get__) do |s, obj, type|
        c = s.cache
        if (!c[:func] || c[:obj] != (obj || type))
          c[:func] = BoundFunction.new(s, c[:obj] = (obj || type))
        end
        c[:func]
      end
    end
  end
end