require 'typhon/environment/type'

module Typhon
  module Environment
    python_class_c :PythonModule, nil, [ObjectBase], 'module',
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
      end
    end
  end
end
