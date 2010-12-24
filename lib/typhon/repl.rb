require 'readline'

module Typhon
  class ReadEvalPrintLoop
    def initialize(compiler_print = Compiler::Print.new, show_lineno = false)
      @compiler_print = compiler_print
      @show_lineno = show_lineno
    end

    def prompt(lineno = 1, level = 1, print_line = false)
      line = ("%03i " % [line] if print_line).to_s
      prompt = if level > 1; "..."; else ">>>"; end
      space = " " * level
      [line, prompt, space].join
    end

    def header
      puts VERSION.full_string
      puts 'Type "help", "copyright", "credits" or "license" for more information.'
    end

    def main(print = Compiler::Print.new)
      trap("INT") { exit 0 }

      bnd = Object.new
      def bnd.bnd; binding; end
      bnd = bnd.bnd
      mod = Environment::PythonModule.new(nil, :__repl__, "REPL", "(repl)")

      lineno = 1
      level = 1
      header
      while line = Readline.readline(prompt(lineno, level, @show_lineno), true)

        Readline::HISTORY.pop() if double_or_empty?(line)

        begin
          p CodeLoader.execute_code line, bnd, mod, @compiler_print
        rescue => e
          puts e.message
        end

        lineno += 1
      end
    end

    def double_or_empty?(line)
      line =~ /^\s*$/ || Readline::HISTORY.to_a[-2] == line
    end
  end
end
