module Typhon
  module AST
    class VarNode < Node
      # Finds a normal variable, doesn't go into BuiltIn, though.
      def find_normal_var(g, name)
        name = name.to_sym
        scope = g.state.scope
        # First try to find it in a function scope.
        scope_depth = 0
        while (scope.kind_of?(FunctionNode) || scope.kind_of?(ModuleNode))
          var = scope.variables[name]
          if (var)
            yield var.reference, scope_depth
            return
          end
          scope_depth += 1
          scope = scope.parent
        end
        # TODO: Then look in module scope.
      end
    end
    
    class NameNode < VarNode
      def bytecode(g)
        pos(g)
        find_normal_var(g, @name) do |ref, depth|
          if (depth > 0)
            g.push_local_depth(depth, ref.slot)
          else
            g.push_local(ref.slot)
          end
          return
        end
        
        # TODO: Figure out Builtins.
        #raise SyntaxError, "BOOM"
      end
    end
    
    class AssignNode < VarNode
      def bytecode(g)
        pos(g)

        # no matter what, we want the RHS on the stack.
        @expr.bytecode(g)

        # TODO: This is completely biased towards single assignment. Everything
        # else will probably fail spectacularly.
        name = @nodes[0].name.to_sym

        find_normal_var(g, name) do |ref, depth|
          if (depth > 0)
            g.set_local_depth(depth, ref.slot)
          else
            g.set_local(ref.slot)
          end
          return
        end
        # if we're here we didn't find anywhere to set it, so create it.
        g.set_local(g.state.scope.new_local(name).reference.slot)
      end
    end   
  end
end