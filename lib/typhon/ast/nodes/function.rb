module Typhon
  module AST
    class FunctionNode < ClosedScope
      include Compiler::LocalVariables

      attr_reader :parent

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

      def compile_body(g)
        meth = new_generator(g, @name.to_sym, @arguments)

        state = g.state
        @parent = state.scope
        meth.push_state self
        meth.state.push_super state.super
        meth.state.push_eval state.eval
  #        meth.definition_line(@line)

        meth.state.push_name @name.to_sym

        @arguments.bytecode(meth)
        @code.bytecode(meth)

        meth.state.pop_name

        meth.local_count = local_count
        meth.local_names = local_names

        meth.ret
        meth.close
        meth.pop_state

        return meth
      end

      def bytecode(g)
        pos(g)

        @arguments = Arguments.new(@argnames,@defaults)

        g.push_self
        g.push_literal @name.to_sym
        g.create_block compile_body(g)
        g.allow_private
        g.send_with_block(:__define_method__, 1)

        # to add an actual method to a class, it actually goes like:
        #g.push_variables
        #g.send :method_visibility, 0
        #g.send :add_defn_method, 4
      end
    end

    class CallFuncNode < Node
      def bytecode(g)
        pos(g)

        g.push_self
        @args.each do |arg|
          arg.bytecode(g)
        end
        # TODO: deal with splats and such as well.
        g.send @node.name.to_sym, @args.count
      end
    end
  end
end