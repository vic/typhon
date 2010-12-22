require 'open3'

base = File.expand_path("../..", File.dirname(__FILE__))

Dir.glob(File.expand_path("*.out", File.dirname(__FILE__))) do |file|

  content = File.read file
  m = /#!\s*typhon\s+(.*)$/.match(content)
  next unless m
  cmd = m[1]
  content = content.sub(/.*?\n/, '')
  expect = Regexp.new(Object.new.instance_eval content.inspect)

  describe "Example output of typhon #{cmd}" do
    it "should match content of #{file}" do
      stdio = nil
      Dir.chdir base do
        stdio = Open3.popen3("./bin/typhon #{cmd}")
      end
      output = stdio[1].read
      output.should =~ expect
    end
  end

  describe "Example output of python #{cmd}" do
    it "should match content of #{file}" do
      stdio = nil
      Dir.chdir base do
        stdio = Open3.popen3("python #{cmd}")
      end
      output = stdio[1].read
      output.should =~ expect
    end
  end

end
