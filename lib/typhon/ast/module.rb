class Typhon
  class AST
    class Module

      def bytecode(g)
        pos(g)

        node.nodes.each { |n| n.bytecode(g) }
      end
    end
  end
end
