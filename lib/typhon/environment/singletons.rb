module Typhon
  module Environment
    python_class_c :NoneType, [ObjectBase], 'NoneType', "These aren't the droids you're looking for" do
      extend FunctionTools

      python_class_method(:__new__) do |c|
        return nil
      end

      python_method(:__repr__) do |c|
        return "None"
      end
      python_method(:__str__) do |c|
        return "None"
      end
    end

    BuiltInModule.py_set(:NoneType, NoneType)
    BuiltInModule.py_set(:None, nil)

    python_class_c :NotImplementedType, [ObjectBase], 'NotImplementedType', "What's that you want? Can't have." do
      extend FunctionTools

      python_class_method(:__new__) do |c|
        return NotImplemented
      end

      python_method(:__repr__) do |c|
        return "NotImplemented"
      end
      python_method(:__str__) do |c|
        return "NotImplemented"
      end
    end

    BuiltInModule.py_set(:NotImplementedType, NotImplementedType)

    class NotImplementedClass
      class << self
        alias :real_new :new
        def new()
          return @impl || real_new()
        end
      end

      include PythonSingleton
      py_init(NotImplementedType)

      def to_py
        return self
      end
    end

    NotImplemented = NotImplementedClass.new
    BuiltInModule.py_set(:NotImplemented, NotImplemented)
  end
end

class NilClass
  include Typhon::Environment::PythonSingleton
  py_init(Typhon::Environment::NoneType)

  def to_py
    return self
  end
end
