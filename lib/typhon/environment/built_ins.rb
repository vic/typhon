module Typhon
  module Environment
    BuiltInModule = PythonModule.new(nil, "__builtin__", "Built in objects and methods") do
      self[:module] = PythonModule
      self[:object] = ObjectBase
      self[:type] = Type
      self[:function] = Function
      self[:boundfunction] = BoundFunction
      self[:instancemethod] = InstanceMethod
      self[:classmethod] = ClassMethod
      self[:staticmethod] = StaticMethod
      self[:__builtin__] = self
      self[:None] = nil

      extend FunctionTools
      python_method(:__debugger__) do
        require 'debugger'
        Debugger.start
      end
    end
    # stuff that was defined before this needs to be changed to bind to the BuiltInModule.
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
