module Typhon
  module Environment
    BuiltInModule = PythonModule.new(nil, "__builtin__", "Built in objects and methods") do
      self[:module] = PythonModule
      self[:object] = ObjectBase
      self[:type] = Type
      self[:function] = Function
      self[:__builtin__] = self
    end
    [PythonModule, ObjectBase, Type, Function].each {|i| i.reset_module(BuiltInModule) }
    
    
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