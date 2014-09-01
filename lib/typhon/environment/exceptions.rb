module Typhon
  module Environment
    ExceptionsModule = PythonModule.new(nil, 'exceptions', <<-DOC, nil)
Python's standard exception class hierarchy.

Exceptions found here are defined both in the exceptions module and the
built-in namespace.  It is recommended that user-defined exceptions
inherit from Exception.  See the documentation for the exception
inheritance hierarchy.
DOC

    set_python_module(ExceptionsModule) do
      class BaseException < Exception
        include PythonObjectMixin

        attr_reader :args

        def self.factory
          BaseExceptionClass
        end

        def initialize(*args)
          super(args.first)
          @args = args
          py_init(self.class.factory, {:args => args, :message => ''.to_py})
        end

        def to_s
          self.py_send(:__str__)
        end
        def inspect
          self.py_send(:__repr__)
        end
      end

      python_class_c :BaseExceptionClass, [ObjectBase], 'BaseException', 'Common base class for all exceptions' do
        extend FunctionTools

        python_class_method(:__new__) do |c, *args|
          klass = c.py_cache[:derived_exception] || BaseException
          klass.new(*args)
        end

        python_method(:__repr__) do |s|
          "#{s.py_type.name}#{s.py_get(:args).inspect}"
        end

        python_method(:__str__) do |s|
          s.py_get(:args)
        end
      end

      ExceptionsModule.py_set(:BaseException, BaseExceptionClass)
      BuiltInModule.py_set(:BaseException, BaseExceptionClass)

      def self.make_exception(name, base, doc)
        class_name = :"#{name}Class"
        base_class_name = "#{base.name}Class".gsub('Typhon::Environment::', '')
        m = Typhon::Environment

        # create the ruby class
        k = m.const_set(name, Class.new(base))

        # create the python class (factory)
        c = m.const_set(class_name, python_class([m.const_get(base_class_name)], name, doc))
        c.py_cache[:derived_exception] = k

        # add tell the ruby class what python class it's from.
        k.singleton_class.send(:define_method, :factory) { c }

        ExceptionsModule.py_set(name, c)
        BuiltInModule.py_set(name, c)
      end

      make_exception(:SystemExit, BaseException, 'Request to exit from the interpreter.')
      make_exception(:KeyboardInterrupt, BaseException, 'Program interrupted by user.')

      make_exception(:Exception, BaseException, 'Common base class for all non-exit exceptions.')
        make_exception(:StopIteration, Exception, 'Signal the end from iterator.next().')
        make_exception(:GeneratorExit, Exception, 'Request that a generator exit.')

        make_exception(:StandardError, Exception, 'Base class for all standard Python exceptions that do not represent\ninterpreter exiting.')
          make_exception(:ImportError, StandardError, "Import can't find module, or can't find name in module.")
          make_exception(:ReferenceError, StandardError, 'Weak ref proxy used after referent went away.')
          make_exception(:EOFError, StandardError, 'Read beyond end of file.')
          make_exception(:SystemError, StandardError, 'Internal error in the Python interpreter.\n\nPlease report this to the Python maintainer, along with the traceback,\nthe Python version, and the hardware/OS platform and version.')
          make_exception(:AssertionError, StandardError, 'Assertion failed.')
          make_exception(:TypeError, StandardError, 'Inappropriate argument type.')
          make_exception(:MemoryError, StandardError, 'Out of memory.')
          make_exception(:AttributeError, StandardError, 'Attribute not found.')

          make_exception(:ArithmeticError, StandardError, 'Base class for arithmetic errors.')
            make_exception(:FloatingPointError, ArithmeticError, 'Floating point operation failed.')
            make_exception(:ZeroDivisionError, ArithmeticError, 'Second argument to a division or modulo operation was zero.')
            make_exception(:OverflowError, ArithmeticError, 'Result too large to be represented.')

          make_exception(:RuntimeError, StandardError, 'Unspecified run-time error.')
            make_exception(:NotImplementedError, RuntimeError, "Method or function hasn't been implemented yet.")

          make_exception(:SyntaxError, StandardError, 'Invalid syntax.')
            make_exception(:IndentationError, SyntaxError, 'Improper indentation.')
              make_exception(:TabError, IndentationError, 'Improper mixture of spaces and tabs.')

          make_exception(:ValueError, StandardError, 'Inappropriate argument value (of correct type).')
            make_exception(:UnicodeError, ValueError, 'Unicode related error.')
              make_exception(:UnicodeTranslateError, UnicodeError, 'Unicode translation error.')
              make_exception(:UnicodeEncodeError, UnicodeError, 'Unicode encoding error.')
              make_exception(:UnicodeDecodeError, UnicodeError, 'Unicode decoding error.')

          make_exception(:EnvironmentError, StandardError, 'Base class for I/O related errors.')
            make_exception(:OSError, EnvironmentError, 'OS system call failed.')
            make_exception(:IOError, EnvironmentError, 'I/O operation failed.')

          make_exception(:LookupError, StandardError, 'Base class for lookup errors.')
            make_exception(:KeyError, LookupError, 'Mapping key not found.')
            make_exception(:IndexError, LookupError, 'Sequence index out of range.')

          make_exception(:NameError, StandardError, 'Name not found globally.')
            make_exception(:UnboundLocalError, NameError, 'Local name referenced but not bound to a value.')

        make_exception(:Warning, Exception, 'Base class for warning categories.')
          make_exception(:DeprecationWarning, Warning, 'Base class for warnings about deprecated features.')
          make_exception(:PendingDeprecationWarning, Warning, 'Base class for warnings about features which will be deprecated\nin the future.')
          make_exception(:UnicodeWarning, Warning, 'Base class for warnings about Unicode related problems, mostly\nrelated to conversion problems.')
          make_exception(:FutureWarning, Warning, 'Base class for warnings about constructs that will change semantically\nin the future.')
          make_exception(:ImportWarning, Warning, 'Base class for warnings about probable mistakes in module imports')
          make_exception(:RuntimeWarning, Warning, 'Base class for warnings about dubious runtime behavior.')
          make_exception(:UserWarning, Warning, 'Base class for warnings generated by user code.')
          make_exception(:SyntaxWarning, Warning, 'Base class for warnings about dubious syntax.')
    end
  end
end
