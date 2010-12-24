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

        case g.state.scope
        when Node, ClosedScope
          g.push_self
          g.send(:py_from_module, 0)
        else # something else, like Rubinius::AST::EvalNode
          g.push_const(:Typhon)
          g.find_const(:Environment)
          g.send(:get_python_module, 0)
        end

        g.push_literal(@name.to_sym)
        g.push_const(:BuiltInModule)
        g.send(:py_lookup, 2)
      end
    end

    class AssignNode < VarNode
      def bytecode(g)
        pos(g)

        # TODO: This is completely biased towards single assignment. Everything
        # else will probably fail spectacularly.
        case @nodes[0]
        when AssNameNode
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
          when ModuleNode, ClassNode
            g.push_self
            g.push_literal(name)
            @expr.bytecode(g)
            g.send(:py_set, 2)
          end
        when AssAttrNode
          # evaluate the object on which the attribute must be set
          @nodes[0].expr.bytecode(g)
          g.push_literal(@nodes[0].attrname.to_sym)
          @expr.bytecode(g)
          g.send(:py_set, 2)
        end
      end
    end

    class GetattrNode < Node
      def bytecode(g)
        pos(g)

        @expr.bytecode(g)
        g.push_literal(@attrname.to_sym)
        g.send(:py_get, 1)
      end
    end
  end
end
