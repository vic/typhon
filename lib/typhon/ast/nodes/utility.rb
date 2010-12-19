module Typhon
  module AST
    class PrintnlNode < Node
      def bytecode(g)
        pos(g)
        
        g.push_const(:Typhon)
        g.find_const(:Environment)
        @nodes.each do |node|
          node.bytecode(g)
        end
        g.send :__py_print, @nodes.count
      end
    end
  end
end