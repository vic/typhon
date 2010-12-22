require 'typhon/environment/type'

module Typhon
  module Environment
    python_class_c :PythonModule, [ObjectBase], 'module',
      "A python source file is represented as a module object " +
      "top level expressions are executed on this context." do
        
      extend FunctionTools
      # Initializes a new Python module object with +parent+ and
      # +name+. +name+ defaults to __main__, the main object scope.
      # +doc+ is a docstring if there was one, should be '' otherwise.
      python_method(:__init__) do |s, parent, name, doc|
        s.py_set(:__parent__, parent)
        s.py_set(:__name__, name)
        s.py_set(:__doc__, doc)
      end
    end
    
    def self.set_python_module(m, &block)
      Thread.current[:python_module], m = m, Thread.current[:python_module]
      begin
        yield
      ensure
        Thread.current[:python_module], m = m, Thread.current[:python_module]
      end
    end
    def self.get_python_module()
      Thread.current[:python_module]
    end
  end
end
