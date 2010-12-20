module Typhon
  module Environment
    python_class_c :Function, nil, [ObjectBase], 'function', 'function object' do
      # we special case this one because all other code-paths involve calling python.
      def invoke(mod, cm = nil, scope = nil, &block)
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
      alias :new :invoke
    end
    
    module FunctionTools
      def python_method(name, cm = nil, scope = nil, &block)
        self.attributes[name] = Function.new(cm, scope, &block)
      end
    end
  end
end