require 'open3'

class Typhon
  class Parser
    class Error < StandardError; end

    def parse(code)
      cmd = ['python']
      cmd << File.expand_path('../../bin/pyparse.py', __FILE__)
      stdio = Open3.popen3(*cmd) { |stdin| stdin.puts code }
      raise Error, stdio[2].read unless stdio[2].eof? # has something in stderr
      eval stdio[1].read
    end
  end
end
