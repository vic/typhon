require 'open3'

module Typhon
  class Parser
    class Error < StandardError; end

    def parse(code)
      cmd = ['python']
      cmd << File.expand_path('../../../bin/pyparse.py', __FILE__)
      stdio = Open3.popen3(*cmd) { |stdin, stdout, stderr| 
        stdin.puts code 
        stdin.close
        #raise Error, stderr.read unless stderr.eof? # has something in stderr
        eval stdout.read
      }
    end
  end
end
