require 'typhon/environment/built_in'

module Typhon
  module Environment
    # A python source file is represented as a module object
    # top level expressions are executed on this context.
    class PythonModule < Module
      include BuiltIn
            
      # Initializes a new Python module object with +parent+ and
      # +name+. +name+ defaults to __main__, the main object scope.
      # +doc+ is a docstring if there was one, should be '' otherwise.
      def initialize(parent = nil, name = '__main__', doc = '')
        module_eval do
          __parent__ = parent
          __name__ = name
          __doc__ = doc
          __full_name__ = parent ? parent.__full_name__ + name : [name]
          __builtins__ = BuiltIn
        end
      end
      
      def __define_method__(name, &block)
        meta = class <<self; self; end
        meta.send(:define_method, name, &block)
      end
    end
    
    module BuiltIn
      PythonModule = Typhon::Environment::PythonModule
    end
  end
end
