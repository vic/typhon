module Typhon
  class AST

    Nodes = Hash.new

    # Converts a ruby sexp (array literals) into Typhon AST
    def self.from_sexp(sexp)
      return nil if sexp.nil? || sexp.empty?
      name = :"#{sexp.first}Node"
      type = Nodes[name]
      raise "Unknown sexp type: #{name}" unless type
      convert = lambda do |e|
        if e.kind_of?(Array) && e.first.kind_of?(Symbol)
          from_sexp(e)
        elsif e.kind_of?(Array)
          e.map(&convert)
        else
          e
        end
      end
      args = sexp[1..-1].map(&convert)
      type.new(*args)
    end

    def self.node(name, *attributes)
      name_sym = :"#{name}Node"
      begin
        cls = self.const_get(name_sym)
      rescue NameError
      end
      cls = cls || ::Class.new(Node)
      
      self.const_set(name_sym, cls)
      Nodes[name_sym] = cls
      names = ['line'] + attributes
      attrs = names.map { |a| '@' + a }

      cls.attr_accessor *names
      cls.module_eval <<-INIT
        def initialize(#{names.join(', ')})
          #{attrs.join(', ')} = #{names.join(', ')}
        end
      INIT
    end

    Node = Rubinius::AST::Node
    ClosedScope = Rubinius::AST::ClosedScope

    class DiscardNode < Node
      def bytecode(g)
        pos(g)
        
        @expr.bytecode(g)
        g.pop # ignore whatever it did.
      end
    end
    
    class ConstNode < Node
      def bytecode(g)
        pos(g)
        
        g.push_literal(@value)
      end
    end
    
    class ListNode < Node
      def bytecode(g)
        pos(g)
        
        @nodes.each do |node|
          node.bytecode(g)
        end
        g.make_array(@nodes.size)
      end
    end
    
    class TupleNode < Node
      def bytecode(g)
        pos(g)
        
        @nodes.each do |node|
          node.bytecode(g)
        end
        g.make_array(@nodes.size)
        # TODO: This needs to actually make a frozen list of some sort. Tuples are immutable.
      end
    end
    
    class DictNode < Node
      def bytecode(g)
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
    
    class PrintnlNode < Node
      def bytecode(g)
        pos(g)
        
        g.push_cpath_top
        g.find_const :STDOUT
        @nodes.each do |node|
          node.bytecode(g)
        end
        g.send :puts, @nodes.count
      end
    end
    
    class Body < ClosedScope
      def initialize(statement, line)
        @statement = statement
        @line = line
      end
      
      def bytecode(g)
        pos(g)
        
#        g.definition_line(@line)
        @statement.bytecode(g)
      end
    end
    
    class ModuleBody < Body
      def module?
        true
      end
    end
    
    class ModuleNode < ClosedScope
      def bytecode(g)
        pos(g)
        
        g.push_rubinius
        # TODO: later this needs to take into account how the code was included
        # In ruby the module name is internal to the system, but in python it comes
        # from the import declaration that included it.
        g.push_literal :'Py__main__' 
        g.push_scope
        g.send :open_module, 2
        
        @body = ModuleBody.new(@node, @line)
        attach_and_call(g, :__module_init__, true)
      end
    end
    
    class StmtNode < ClosedScope
      def bytecode(g)
        pos(g)
        @nodes.each do |node|
          node.bytecode(g)
        end
      end
    end
    
    class FunctionNode < ClosedScope
      include Compiler::LocalVariables
      
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
        
        def default_names
          @argnames[-defaults.count..-1]
        end
        
        def bytecode(g)
          @argnames.each do |arg|
            g.state.scope.new_local(arg.to_sym)
          end
          
          default_names.each_with_index do |name, i|
            done = g.new_label
            
            ref = g.state.scope.variables[name.to_sym].reference
            g.passed_arg(ref.slot)
            g.git(done)
            @defaults[i].bytecode(g)
            g.set_local(ref.slot)
            g.pop
            
            done.set!
          end
        end
      end
      
      def compile_body(g)
        meth = new_generator(g, @name.to_sym, @arguments)

        meth.push_state self
        meth.state.push_super self
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
        
        g.push_rubinius
        g.push_literal @name.to_sym
        g.push_generator compile_body(g)
        g.push_scope
        # to add an actual method to a class, it actually goes like:
        #g.push_variables
        #g.send :method_visibility, 0
        #g.send :add_defn_method, 4
        g.push_self
        g.send :attach_method, 4
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
    
    class NameNode < Node
      def bytecode(g)
        pos(g)
        ref = g.state.scope.variables[name.to_sym].reference
        g.push_local ref.slot
      end
    end
    
    # Nodes classes. Read from node.py
    nodes = eval File.read(File.expand_path("../../../bin/node.py", File.dirname(__FILE__)))
    nodes.each { |n| node n.first, *n.last }
  end
end
