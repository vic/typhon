module Typhon
  module Environment
    class PythonString < String
      include PythonObjectMixin

      def initialize(obj = '')
        if !obj.is_a?(String) && obj.respond_to?(:to_py)
          obj = obj.to_py
          case obj.py_type
          when Type
            # python appears to ignore __str__ on type objects, 
            # otherwise a type that defined __str__ for its instances
            # couldn't be represented because types and their instances
            # share a namespace.
            obj = obj.nice_type_string 
          end
          obj = obj.py_send(:__str__)
        end
        super(obj)
        py_init(PythonStringClass)
      end

      def inspect
        self.py_send(:__repr__)
      end
    end

    python_class_c :PythonStringClass, [ObjectBase], 'str',
      "str(object) -> string\n" + "Return a nice string representation of the object.\n" +
      "If the argument is a string, the return value is the same object." do

      extend FunctionTools

      python_class_method(:__new__) do |c, obj|
        return obj if obj.is_a?(PythonString)
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
  def to_py
    Typhon::Environment::PythonString.new(self)
  end
end
