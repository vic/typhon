module Typhon
  module AST
    class ClassNode < ClosedScope
      def bytecode(g)
        pos(g);
        @name = @name.to_sym
        
        g.push_const(:ObjectClass)
        @bases.each do |base|
          base.bytecode(g)
        end
        g.make_array(@bases.count)
        g.push_literal(@name)
        g.push_literal(@doc)
        g.send(:create, 3)
        
        @body = Body.new(@code, @line)
        attach_and_call(g, :__class_init__, false)
        
        # TODO: deal with function local classes (and are they lexical closures?)
        g.push_self
        g.swap
        g.push_literal(@name)
        g.swap
        g.send(:[]=, 2)
      end
    end
  end
end