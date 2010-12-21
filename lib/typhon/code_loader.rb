module Typhon

  module CodeLoader

    # Takes a .py file name, compiles it if needed and executes it.
    # Sets the module name to be __main__, so this should be called
    # only on the main program. For loading other python modules from
    # it use the load_file method.
    def self.execute_file(name, compile_to = nil, print = Compiler::Print.new)
      cm = Compiler.compile_if_needed name, compile_to, print
      ss = ::Rubinius::StaticScope.new Typhon::Environment
      code = Object.new
      ::Rubinius.attach_method(:__run__, cm, ss, code)
      m = Typhon::Environment::PythonModule.new(nil, :__main__, "The main module")
      Typhon::Environment.set_python_module(m) do
        code.__run__
      end
    end
  end

end
