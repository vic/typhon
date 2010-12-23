module Typhon
  module Environment
    BuiltInModule = PythonModule.new(nil, "__builtin__", "Built in objects and methods", nil) do
      py_set(:module, PythonModule)
      py_set(:object, ObjectBase)
      py_set(:type, Type)
      py_set(:function, Function)
      py_set(:boundfunction, BoundFunction)
      py_set(:instancemethod, InstanceMethod)
      py_set(:classmethod, ClassMethod)
      py_set(:staticmethod, StaticMethod)
      py_set(:__builtin__, self)

      extend FunctionTools

      python_method(:__debugger__) do
        require 'debugger'
        Debugger.start
      end
    end

    # stuff that was defined before this needs to be changed
    # to bind to the BuiltInModule. ie. they all are seen as
    # defined in the __builtin__ module.
    [PythonModule, ObjectBase, Type, Function,
     BoundFunction, InstanceMethod, ClassMethod,
     StaticMethod,].each {|i| i.reset_module(BuiltInModule) }

    def self.__py_print_to(out, *args)
      out.print(args.join(' ') + "\n")
    end

    def self.__py_print(*args)
      __py_print_to($stdout,*args)
    end

    def self.__py___getattribute__(s, name)
      raise NameError, "No such variable #{name}"
    end

    def self.__py___init__(*args)
    end
  end
end
