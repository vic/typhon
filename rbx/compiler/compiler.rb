class Typhon

  class Compiler < Rubinius::Compiler

    def self.compile_file(file)
      compiler = new :typhon_file, :compiled_file
      compiler.parser.input file

      compiler.parser.print
      compiler.run
    end

  end

end
