module Typhon

  module CodeLoader
    # This is really really evil. We want literals from a python
    # compiled file to actually be python objects, not ruby objects,
    # so we go through the CompileMethod's literal arrays (and all
    # child CompiledMethod objects' literals arrays) and replace
    # objects as appropriate.
    def self.pythonize_literals(cm)
      cm.literals.each_with_index do |i, idx|
        case i
        when String
          cm.literals[idx] = i.to_py
        when Rubinius::CompiledMethod
          pythonize_literals(i)
        end
      end
      cm
    end

    # Takes a .py file name, compiles it if needed and executes it.
    # Sets the module name to be __main__, so this should be called
    # only on the main program. For loading other python modules from
    # it use the load_module method.
    def self.execute_file(name, compile_to = nil, print = Compiler::Print.new)
      cm = pythonize_literals(Compiler.compile_if_needed(name, compile_to, print))
      ss = ::Rubinius::StaticScope.new Typhon::Environment
      code = Object.new
      ::Rubinius.attach_method(:__run__, cm, ss, code)
      m = Typhon::Environment::PythonModule.new(nil, :__main__,
                                                "The main module", name)
      Typhon::Environment.set_python_module(m) do
        code.__run__
      end
    end

    # Load the named module from from_module.
    # from_module is a python module object. we obtain the file it was
    # loaded from, to search for the new module.
    def self.load_module(name, from_module)
      directory = File.dirname(from_module.py_get(:__file__) || "")
      filename = File.expand_path("#{name.gsub(".", File::Separator)}.py", directory)
      # TODO: use system load-path to search for file if it doesnt
      # exist.
      cm = pythonize_literals(Compiler.compile_if_needed(filename))
      ss = ::Rubinius::StaticScope.new Typhon::Environment
      code = Object.new
      ::Rubinius.attach_method(:__run__, cm, ss, code)
      m = Typhon::Environment::PythonModule.new(nil, name.to_sym, name.to_s, filename)
      Typhon::Environment.set_python_module(m) do
        code.__run__
      end
    end

  end

end
