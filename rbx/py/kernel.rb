class Typhon

  # Implementation of python core objects.
  class Py

    # Mixin defining core python functions. All python objects
    # have this builtin functions available regardless of their class.
    module Kernel

      include self

      def id
        object_id
      end

      def str(object)
        "" + object.py_str
      end

      def print(object, dest = STDOUT)
        dest.puts str(object)
      end

    end
  end
end
