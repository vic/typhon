module Typhon
  module AST
    class Arguments
      attr_reader :argnames, :defaults
      def initialize(argnames, defaults)
        @argnames = argnames
        @defaults = defaults
      end

      def required_args
        @argnames.length - @defaults.length
      end
      def total_args
        @argnames.length
      end
      def splat_index
        nil
      end

      def required_names
        @argnames[0..@argnames.count-@defaults.count]
      end

      def default_names
        if (defaults.count > 0)
          @argnames[-defaults.count..-1]
        else
          []
        end
      end
    end
    
    class ModuleArguments < Arguments
      def bytecode(g)
        @argnames.each do |name|
          g.state.scope.new_local(name.to_sym)
        end
        
        args_done = g.new_label
        # push missing default arguments until we hit one that's present.
        # note: this is probably not the most efficient way to do it, but it
        # at least avoids branching too much.
        @defaults.reverse.each_with_index do |default, i|
          g.passed_arg(total_args - i - 1)
          g.git(args_done)

          default.bytecode(g)
          g.set_local(total_args - i - 1)
          g.pop
        end
        args_done.set!
      end
    end
      
    class BlockArguments < Arguments
      def bytecode(g)
        return if (total_args == 0)

        # get the args into an array on the stack
        g.cast_for_splat_block_arg

        # if the function takes no args we need no bytecode
        args_done = g.new_label

        # because we treat all methods as blocks to capture closure state,
        # we need to pull in arguments manually.
        args_present = g.new_label

        # if the last arg was passed we're already good.
        g.passed_arg(@argnames.count - 1)
        g.git(args_present)

        # if the last required arg isn't passed, we have to blow up
        insufficient_args = g.new_label
        g.passed_arg(@argnames.count - @defaults.count - 1)
        g.gif(insufficient_args)

        # push missing default arguments until we hit one that's present.
        # note: this is probably not the most efficient way to do it, but it
        # at least avoids branching too much.
        @defaults.reverse.each_with_index do |default, i|
          g.passed_arg(total_args - i - 1)
          g.git(args_present)

          g.push_literal(-i - 1)
          default.bytecode(g)
          g.send(:insert, 2)
        end

        args_present.set!
        # once we're here we know we have all arguments on the stack
        @argnames.each do |name|
          var = g.state.scope.new_local(name.to_sym)
          g.shift_array
          g.set_local(var.reference.slot)
          g.pop
        end
        g.goto(args_done)

        insufficient_args.set!

        g.push_true #TODO: make this a real exception object.
        g.raise_exc

        args_done.set!
        g.pop # clear the array off the stack.
      end
    end
    
    class ExecutableNode < ClosedScope
      include Compiler::LocalVariables
      
      attr_reader :parent
      
      def compile_body(g, auto_return = false)
        if (@name)
          meth = new_generator(g, @name.to_sym, @arguments)
        else
          meth = new_block_generator(g, @arguments)
        end

        state = g.state
        @parent = state.scope
        meth.push_state self
        meth.state.push_super state.super
        meth.state.push_eval state.eval
  #        meth.definition_line(@line)

        if (@name)
          meth.state.push_name @name.to_sym
        end

        @arguments.bytecode(meth)
        @code.bytecode(meth)

        if (@name)
          meth.state.pop_name
        end

        meth.local_count = local_count
        meth.local_names = local_names

        if (auto_return)
          meth.ret
        else
          meth.pop
          meth.push_nil
          meth.ret
        end

        meth.close
        meth.pop_state

        return meth
      end
    end
    
    class DecoratorsNode < Node
      def bytecode(g)
        @nodes.each do |decorator|
          decorator.bytecode(g)
          g.swap
          g.send(:invoke, 1)
        end
      end
    end
      
    class FunctionNode < ExecutableNode 
      def bytecode(g)
        pos(g)
        
        case g.state.scope
        when ModuleNode, ClassNode
          @arguments = ModuleArguments.new(@argnames, @defaults)

          g.push_self
          g.push_literal(@name.to_sym)
          
          g.push_const(:Function)
          g.push_generator(compile_body(g, false))
          g.push_scope
          g.send(:new, 2)
          @decorators.bytecode(g) if @decorators
          
          g.send(:[]=, 2)
          
        when FunctionNode 
          @arguments = BlockArguments.new(@argnames, @defaults)

          g.push_const(:Function)
          g.create_block(compile_body(g, false))
          g.send_with_block(:new, 0)
          @decorators.bytecode(g) if @decorators
          g.set_local(g.state.scope.new_local(@name.to_sym).reference.slot)
          g.pop # set_local doesn't remove it from the stack.
        end
      end
    end
    
    class LambdaNode < ExecutableNode
      def bytecode(g)
        pos(g)
        
        @arguments = BlockArguments.new(@argnames, @defaults)
        
        g.push_const(:Function)
        g.create_block(compile_body(g, true))
        g.send_with_block(:new, 0)
      end
    end
    
    class ReturnNode < Node
      def bytecode(g)
        if (@value)
          @value.bytecode(g)
          g.ret
        else
          g.push_nil
          g.ret
        end
      end
    end

    class CallFuncNode < Node
      # Finds a normal variable within function scope
      def find_variable(g, name)
        name = name.to_sym
        scope = g.state.scope
        # First try to find it in a function scope.
        scope_depth = 0
        while (scope.kind_of?(FunctionNode))
          var = scope.variables[name]
          if (var)
            yield var.reference, scope_depth
            return
          end
          scope_depth += 1
          scope = scope.parent
        end
      end

      def bytecode(g)
        pos(g)
        
        # evaluate the name into an object we can call
        # and then pass off to invoke() to do the actual work.
        @node.bytecode(g)
        @args.each do |arg|
          arg.bytecode(g)
        end
        g.send(:invoke, @args.count)
      end
    end
  end
end