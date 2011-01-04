module Typhon
  module Environment
    class List
      include PythonObjectMixin

      def initialize(rb_list)
        @list = rb_list
        py_init(ListType)
      end
    end

    python_class_c :ListType, [ObjectBase], 'list', 'list' do
    end
  end
end

class Array
  def to_py
    Typhon::Environment::List.new(self)
  end
end
