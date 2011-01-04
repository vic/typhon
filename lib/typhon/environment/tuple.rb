module Typhon
  module Environment
    class Tuple
      include PythonObjectMixin

      def initialize(rbx_tuple)
        @tuple = rbx_tuple
        py_init(TupleType)
      end
    end

    python_class_c :TupleType, [ObjectBase], 'tuple', 'tuple' do

    end
  end
end

class Rubinius::Tuple
  def to_py
    Typhon::Environment::Tuple.new(self)
  end
end

