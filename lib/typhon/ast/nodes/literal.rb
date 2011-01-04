module Typhon
  module AST
    class ConstNode < Node
      def bytecode(g)
        pos(g)

        if (@value.respond_to?(:to_py))
          g.push_literal(@value.to_py)
        else
          g.push_literal(@value)
        end
      end
    end

    class TupleNode < Node
      def bytecode(g)
        pos(g)

        g.push_rubinius
        g.find_const :Tuple
        g.push_literal @nodes.size
        g.send :new, 1

        @nodes.each_with_index do |node, index|
          g.dup
          g.push_literal index
          node.bytecode(g)
          g.send :put, 2
          g.pop
        end
     end
    end

    class ListNode < TupleNode
      def bytecode(g)
        pos(g)

        @nodes.each do |node|
          node.bytecode(g)
        end
        g.make_array(@nodes.size)
      end
    end

    class DictNode < Node
      def bytecode(g)
        pos(g)

        g.push_cpath_top
        g.find_const :Hash
        g.push @items.size
        g.send :new_from_literal, 1

        @items.each do |node|
          g.dup
          key, value = node
          key.bytecode(g)
          value.bytecode(g)
          g.send(:[]=, 2)
          g.pop
        end
        # ...
      end
    end
  end
end
