module Typhon
  module Environment
    class Dict
      include PythonObjectMixin

      def initialize(hash)
        @hash = hash
        py_init(DictType)
      end
    end

    python_class_c :DictType, [ObjectBase], 'dict', 'dict' do
    end
  end
end

class Hash
  def to_py
    Typhon::Environment::Dict.new(self)
  end
end
