class Typhon

  # Implementation of python core objects.
  class Py

    # Mixin defining core python functions. All python objects
    # have this builtin functions available regardless of their class.
    module Kernel

      def id
        object_id
      end

    end
  end
end
