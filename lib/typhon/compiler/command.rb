require 'typhon/environment'

module Typhon
  class Compiler

    class Command

      def self.run(argv)
        raise "Expected one python source file as argument" if argv.empty?
        print_debug = argv.include?('-d')
        argv.delete('-d')
        cm = Compiler.compile_file(argv.first, print_debug)
        ss = ::Rubinius::StaticScope.new Typhon::Environment
        code = Object.new
        ::Rubinius.attach_method(:__run__, cm, ss, code)
        code.__run__
      end

    end

  end
end
