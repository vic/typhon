require 'optparse'

class Typhon
  class Compiler

    class Command

      def self.run(argv)
        raise "Expected one python source file as argument" if argv.empty?
        Compiler.compile_file(argv.first)
      end

    end

  end
end
