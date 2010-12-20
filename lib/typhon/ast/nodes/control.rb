module Typhon
  module AST
    class DiscardNode < Node
      def bytecode(g)
        pos(g)

        @expr.bytecode(g)
        g.pop # ignore whatever it did.
      end
    end

    class StmtNode < ClosedScope
      def empty?
        @nodes.empty?
      end

      def bytecode(g)
        pos(g)
        @nodes.each do |node|
          node.bytecode(g)
        end
      end
    end
  end
end
