class Typhon

  class Compiler < Rubinius::Compiler
    def self.compiled_filename(filename)
      if filename =~ /.py$/
        filename + ".rbc"
      else
        filename + ".compiled.rbc"
      end
    end


    def self.compile_file(file, print = true)
      compiler = new :typhon_file, :compiled_file
      parser = compiler.parser

      parser.input file

      compiler.generator.root Rubinius::AST::Script
      compiler.writer.name = compiled_filename(file)

      if print
        parser.print
        compiler.packager.print.bytecode = true
      end

      begin
        compiler.run
      rescue Exception => e
        compiler_error "Error trying to compile python: #{file}", e
      end
    end

  end

end
