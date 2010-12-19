require 'typhon/environment/type'

module Typhon
  module Environment
    python_class_c :PythonModule, Environment, [ObjectBase], 'module',
      "A python source file is represented as a module object " +
      "top level expressions are executed on this context." do
        
      extend FunctionTools
      # Initializes a new Python module object with +parent+ and
      # +name+. +name+ defaults to __main__, the main object scope.
      # +doc+ is a docstring if there was one, should be '' otherwise.
      python_method(:__init__) do |s, parent, name, doc|
        s[:__parent__] = parent
        s[:__name__] = name
        s[:__doc__] = doc
        s[:__full_name__] = parent ? parent.__full_name__ + name : [name]
        s[:__builtins__] = Typhon::Environment
      end

      python_method(:__call__) do |parent, name, doc|
        PythonObject.new(PythonModule) do
          self[:__init__].invoke(self, parent, name, doc)
        end
      end

      def __define_method__(name, &block)
        metaclass.send(:define_method, name, &block)
      end
    end

    module BuiltIn
      PythonModule = Typhon::Environment::PythonModule
    end
  end
end
