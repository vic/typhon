require 'pp'

class Typhon
  class Stage


    # This stage takes a tree of Typhon::AST nodes and
    # simply calls the bytecode method on them.
    class Generator < Rubinius::Compiler::Stage
      next_stage Rubinius::Compiler::Encoder
      attr_accessor :variable_scope

      def initialize(compiler, last)
        super
        @compiler = compiler
        @variable_scope = nil
        compiler.generator = self
      end

      def root(root)
        @root = root
      end

      def run
        root = @root.new @input
        root.file = @compiler.parser.filename

        @output = Rubinius::Generator.new
        root.variable_scope = @variable_scope
        root.bytecode @output
        @output.close
        run_next
      end

    end

    # This stage takes a ruby array as produced by bin/astpretty.py
    # and produces a tree of Typhon::AST nodes.
    class PyAST < Rubinius::Compiler::Stage
      next_stage Generator

      def initialize(compiler, last)
        @compiler = compiler
        super
      end

      def run
        @output = Typhon::AST.from_sexp(@input)
        pp(@output) if @compiler.parser.print?
        run_next
      end
    end

    # This stage takes python code and produces a ruby array
    # containing representation of the python source.
    # We are currently using python's own parser, so we just
    # read the sexp as its printed by bin/astpretty.py
    class PyCode < Rubinius::Compiler::Stage

      stage :typhon_code
      next_stage PyAST
      attr_reader :filename, :line

      def initialize(compiler, last)
        super
        compiler.parser = self
      end

      def print?
        @print
      end

      def print
        @print = true
      end

      def input(code, filename = "eval", line = 1)
        @code = code
        @filename = filename
        @line = line
      end

      def run
        @output = Parser.new.parse(@code)
        pp(@output) if @print
        run_next
      end
    end

    # This stage takes a python filename and produces a ruby array
    # containing representation of the python source.
    # We are currently using python's own parser, so we just
    # read the sexp as its printed by bin/astpretty.py
    class PyFile < Rubinius::Compiler::Stage

      stage :typhon_file
      next_stage PyAST
      attr_reader :filename, :line

      def initialize(compiler, last)
        super
        compiler.parser = self
      end

      def print?
        @print
      end

      def print
        @print = true
      end

      def input(filename, line = 1)
        @filename = filename
        @line = line
      end

      def run
        @output = Parser.new.parse(File.read(@filename))
        pp(@output) if @print
        run_next
      end
    end

  end
end
