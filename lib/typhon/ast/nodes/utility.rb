module Typhon
  module AST
    class PrintnlNode < Node
      def bytecode(g)
        pos(g)
        
        g.push_self
        @nodes.each do |node|
          node.bytecode(g)
        end
        g.send :__print__, @nodes.count
      end
    end
  end
end