module Typhon
  module AST

    class Body < ClosedScope
      def initialize(statement, line)
        @statement = statement
        @line = line
      end

      def bytecode(g)
        pos(g)

        if @statement.empty?
          g.push_nil
        else
          @statement.bytecode(g)
        end

        g.push_self
      end
    end

    class ModuleBody < Body
      def module?
        true
      end
    end

    class ModuleNode < ClosedScope
      attr_reader :parent #always nil for now.

      def bytecode(g)
        pos(g)

        g.push_const(:PythonModule)
        # TODO: later this needs to take into account how the code was included
        # In ruby the module name is internal to the system, but in python it comes
        # from the import declaration that included it.
        g.push_literal(nil)
        g.push_literal('__main__')
        g.push_literal(@doc)
        g.send(:new, 3)

        @body = ModuleBody.new(@node, @line)
        attach_and_call(g, :__module_init__, true)
        g.ret # Actually want to return the module object to the enclosing scope.
      end
    end
  end
end
