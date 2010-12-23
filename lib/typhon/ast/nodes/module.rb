module Typhon
  module AST

    class Body < ClosedScope
      def initialize(statement, line)
        @statement = statement
        @line = line
      end

      def bytecode(g)
        pos(g)

        @statement.bytecode(g)
        g.pop unless @statement.discard?
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

        g.push_const(:Typhon)
        g.find_const(:Environment)
        g.send(:get_python_module, 0)

        if (@doc)
          g.dup
          g.push_literal(:__doc__)
          g.push_literal(@doc)
          g.send(:py_set, 2)
          g.pop
        end

        @body = ModuleBody.new(@node, @line)
        attach_and_call(g, :__module_init__, false)
        g.ret # Actually want to return the module object to the enclosing scope.
      end
    end

    class ImportNode < Node
      def bytecode(g)
        pos(g)
        @names.each do |mod, name|
          name ||= mod.split(".").last
          g.push_const :Typhon
          g.find_const :CodeLoader
          g.push_literal mod
          g.push_self
          g.send :load_module, 2

          g.push_self
          g.swap
          g.push_literal name.to_sym
          g.swap
          g.send :py_set, 2
        end
      end
    end

    class FromNode < Node
      def bytecode(g)
        pos(g)
        g.push_const :Typhon
        g.find_const :CodeLoader
        g.push_literal @modname
        g.push_self
        @names.each do |pair|
          g.push_literal pair.first.to_sym
          g.push_literal(pair.last && pair.last.to_sym)
        end
        g.make_array(@names.size * 2)
        g.send :import_from_module, 3
      end
    end

  end
end
