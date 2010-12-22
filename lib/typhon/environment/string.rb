module Typhon
  module Environment
    class PythonString < String
      include PythonObjectMixin
      
      def initialize(obj = '')
        if (obj.is_a?(String))
          s = obj
        else
          s = obj.to_py[:__str__].invoke
        end
        super(s)
        py_init(PythonStringClass)
      end
      
      def inspect()
        self[:__repr__].invoke()
      end
    end
    
    python_class_c :PythonStringClass, [ObjectBase], 'str',
      "str(object) -> string\n" + "Return a nice string representation of the object.\n" +
      "If the argument is a string, the return value is the same object." do
      
      extend FunctionTools
      
      python_class_method(:__new__) do |c, obj|
        o = PythonString.new(obj || '')
      end
      
      python_method(:__str__) do |s|
        s
      end
      
      python_method(:__repr__) do |s|
        "\"#{s.gsub('"', '\"')}\""
      end
    end
    
    BuiltInModule.py_set(:str, PythonStringClass)
  end
end

class String
  def to_py()
    Typhon::Environment::PythonString.new(self)
  end
end