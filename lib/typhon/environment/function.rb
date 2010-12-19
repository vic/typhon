module Typhon
  module Environment
    python_class_c :Function, Environment, [ObjectBase], 'function', 'function object' do
      
      def new(mod, cm = nil, scope = nil, &block)
        PythonObject.new(Function) do
          @mod = mod
          def self.module; @mod; end
          if (cm)
            Rubinius.attach_method(:invoke, cm, scope, self)
          else
            _meta.send(:define_method, :invoke, &block)
          end
        end
      end
    end
    
    module FunctionTools
      def python_method(name, cm = nil, scope = nil, &block)
        self.attributes[name] = Function.new(cm, scope, &block)
      end
    end
  end
end