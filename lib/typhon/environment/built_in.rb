module Typhon
  module Environment
    module BuiltIn
      def __print_to__(out, *args)
        out.print(args.join(' ') + "\n")
      end
      def __print__(*args)
        __print_to__($stdout,*args)
      end
    end
  end
end
