module Typhon
  module Environment
    def self.__py_print_to(out, *args)
      out.print(args.join(' ') + "\n")
    end
    def self.__py_print(*args)
      __py_print_to($stdout,*args)
    end
    def self.__py___getattribute__(s, name)
      raise NameError, "No such variable #{name}"
    end
    def self.__py___init__(*args)
    end
  end
end