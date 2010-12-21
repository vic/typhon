module Typhon

  class Compiler < Rubinius::Compiler

    def self.compiled_filename(filename)
      if filename =~ /.py$/
        filename + ".rbc"
      else
        filename + ".compiled.rbc"
      end
    end

    def self.compile_if_needed(file, output = nil, print = Print.new)
      compiled = output || compiled_filename(file)
      needed = !File.exists?(compiled) ||
        File.stat(compiled).mtime < File.stat(file).mtime
      if needed
        compile_file(file, compiled, print)
      else
        Rubinius::CodeLoader.new(compiled).load_compiled_file(compiled, 0)
      end
    end


    def self.compile_file(file, output = nil, print = Print.new)
      compiler = new :typhon_file, :compiled_file
      parser = compiler.parser

      parser.input file

      compiler.generator.root Rubinius::AST::Script
      compiler.writer.name = output || compiled_filename(file)

      parser.print = print
      compiler.packager.print.bytecode = true if print.asm?

      begin
        compiler.run
      rescue Exception => e
        compiler_error "Error trying to compile python: #{file}", e
      end
    end

    class Error < StandardError
    end

    class Print < Struct.new(:sexp, :ast, :asm)
      def sexp?
        @sexp
      end

      def ast?
        @ast
      end

      def asm?
        @asm
      end
    end

  end

end
