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

      python_method(:eval) do |code|
        bnd = Binding.setup(Rubinius::VariableScope.of_sender,
                            Rubinius::CompiledMethod.of_sender,
                            Rubinius::StaticScope.of_sender)
        CodeLoader.execute_code code, bnd, py_from_module
      end
    end

    # stuff that was defined before this needs to be changed
    # to bind to the BuiltInModule. ie. they all are seen as
    # defined in the __builtin__ module.
    [PythonModule, ObjectBase, Type, Function,
     BoundFunction, InstanceMethod, ClassMethod,
     StaticMethod,].each {|i| i.reset_module(BuiltInModule) }

    def self.__py_print_to(out, *args)
      args = args.map do |a|
        PythonString.new(a)
      end
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
