class Typhon
  class AST
    class Module < Node
      name :Module

      def initialize(doc, body)
        @doc, @body = doc, body
      end
    end

    class Stmt < Node
      name :Stmt

      def initialize(stmt)
        @stmt = stmt
      end
    end

    class Printnl < Node
      name :Printnl

      def initialize(expr, out)
        @expr = expr
        @out = out
      end
    end

    class Const < Node
      name :Const

      def initialize(value)
        @value = value
      end
    end

  end
end
