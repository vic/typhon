module Typhon
  module AST
    class SubscriptNode < Node
      def bytecode(g)
        pos(g)
        
        @expr.bytecode(g)
        @subs.each do |sub|
          sub.bytecode(g)
        end
        g.send(:[], @subs.count) # in the end this is wrong, just this way temporarily to expose __dict__
      end
    end

    class CompareNode < Node
      def bytecode(g)
        pos(g)
        
        @expr.bytecode(g)
        @ops.each do |op, rhs|
          rhs.bytecode(g)
          g.send(op.to_sym, 1)
        end
      end
    end
    
    class AddNode < Node
      def bytecode(g)
        pos(g)
        
        @left.bytecode(g)
        @right.bytecode(g)
        g.send(:+, 1)
      end
    end
    
    class SubNode < Node
      def bytecode(g)
        pos(g)
        
        @left.bytecode(g)
        @right.bytecode(g)
        g.send(:-, 1)
      end
    end
    
    class MulNode < Node
      def bytecode(g)
        pos(g)
        
        @left.bytecode(g)
        @right.bytecode(g)
        g.send(:*, 1)
      end
    end
    
    class DivNode < Node
      def bytecode(g)
        pos(g)
        
        @left.bytecode(g)
        @right.bytecode(g)
        g.send(:/, 1)
      end
    end
    
    class ModNode < Node
      def bytecode(g)
        pos(g)
        
        @left.bytecode(g)
        @right.bytecode(g)
        g.send(:%, 1)
      end
    end
    
    class UnaryAddNode < Node
      def bytecode(g)
        pos(g)
        
        @expr.bytecode(g)
        g.send(:+, 0)
      end
    end
    class UnarySubNode < Node
      def bytecode(g)
        pos(g)
        
        @expr.bytecode(g)
        g.send(:-, 0)
      end
    end
  end
end