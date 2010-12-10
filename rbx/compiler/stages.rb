require 'open3'

class Typhon
  class Stage


    # This stage takes a ruby array as produced by bin/astpretty.py
    # and produces a tree of Typhon::AST nodes.
    class PyAST < Rubinius::Compiler::Stage
      next_stage Rubinius::Compiler::Encoder

      def initialize(compiler, last)
        super
        compiler.parser = self
      end

      def run
      end
    end

    # This stage takes a python filename and produces a ruby array
    # containing representation of the python source.
    # We are currently using python's own parser, so we just
    # read the sexp as its printed by bin/astpretty.py
    class PyFile < Rubinius::Compiler::Stage

      stage :typhon_file
      next_stage PyAST

      def initialize(compiler, last)
        super
        compiler.parser = self
      end

      def print
        @print = true
      end

      def input(filename, line = 1)
        @filename = filename
        @line = line
      end

      def run
        cmd = ['python']
        cmd << File.expand_path('../../bin/astpretty.py', File.dirname(__FILE__))
        cmd << @filename
        stdio = Open3.popen3(*cmd)
        unless stdio[2].eof? # has something in stderr
          raise stdio[2].read
        end
        @output = eval stdio[1].read
        p @output if @print
        run_next
      end

    end

  end
end
