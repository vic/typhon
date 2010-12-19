module Typhon
  module AST
    class VarNode < Node
      # Finds a normal variable, doesn't go into BuiltIn, though.
      def find_normal_var(g, name)
        name = name.to_sym
        scope = g.state.scope
        # First try to find it in a function scope.
        scope_depth = 0
        while (scope.kind_of?(ExecutableNode))
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
        find_normal_var(g, @name.to_sym) do |ref, depth|
          if (depth > 0)
            g.push_local_depth(depth, ref.slot)
          else
            g.push_local(ref.slot)
          end
          return
        end
        
        g.push_self
        if (g.state.scope.kind_of?(FunctionNode))
          g.send(:module, 0) # in function scope we need to pull the module out.
        end
        g.push_literal(@name.to_sym)
        g.send(:[], 1)
      end
    end
    
    class AssignNode < VarNode
      def bytecode(g)
        pos(g)

        # TODO: This is completely biased towards single assignment. Everything
        # else will probably fail spectacularly.
        name = @nodes[0].name.to_sym

        case g.state.scope
        when FunctionNode
          @expr.bytecode(g)

          find_normal_var(g, name) do |ref, depth|
            if (depth > 0)
              g.set_local_depth(depth, ref.slot)
            else
              g.set_local(ref.slot)
            end
            g.pop
            return
          end
          # if we're here we didn't find anywhere to set it, so create it.
          g.set_local(g.state.scope.new_local(name).reference.slot)
          g.pop
        when ModuleNode
          g.push_self
          g.push_literal(name)
          @expr.bytecode(g)
          g.send(:[]=, 2)
        end
      end
    end   
  end
end