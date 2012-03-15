module Typhon
  module Environment
    class Tuple
      include PythonObjectMixin

      attr_reader :tuple

      def initialize(rbx_tuple)
        @tuple = rbx_tuple
        py_init(TupleType)
      end
    end

    python_class_c :TupleType, [ObjectBase], 'tuple', 'tuple' do

      extend FunctionTools

      python_method(:__str__) do |t|
        '(' + t.tuple.map { |i| i.to_py.py_send(:__repr__) }.join(', ') + ')'
      end

    end
  end
end

class Rubinius::Tuple
  def to_py
    Typhon::Environment::Tuple.new(self)
  end
end

