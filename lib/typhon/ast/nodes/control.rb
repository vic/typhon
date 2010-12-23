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
      def bytecode(g)
        pos(g)
        @nodes.each do |node|
          node.bytecode(g)
        end
        g.push_nil if @nodes.empty?
      end
    end

    class PassNode
      def bytecode(g)
        g.push_nil
      end
    end
  end
end
