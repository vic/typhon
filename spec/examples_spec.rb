require 'open3'
require 'strscan'

base = File.expand_path("..", File.dirname(__FILE__))

Dir.glob(File.expand_path("**/*.out", File.dirname(__FILE__))) do |file|

  scanner = StringScanner.new(File.read file)
  runner_re = /^#!\s*(typhon|python)\s+(.*)(\n|\r\n)/
  runners = {}

  runners[scanner[1]] = scanner[2] while scanner.scan runner_re
  next if runners.empty?

  content = scanner.rest

  # Allow regexp literals inside the file content so we can match
  # things like memory addresses or anything that can vary
  content = content.gsub('(', '\(').gsub(')', '\)').
            inspect.gsub(/\\#\{\/(.*?)\/\}/) do |regex|
    regex[1..-1].gsub('\\\\', '\\')
  end

  expect = Regexp.new(Object.new.instance_eval content)

  runners.each do |program, cmd|
    describe "Output of `#{program} #{cmd}`" do
      it "should match content of #{file}" do
        stdio = nil
        program = "./bin/typhon" if program == "typhon"
        Dir.chdir base do
          stdio = Open3.popen3("#{program} #{cmd}")
        end
        output = stdio[1].read
        output.should =~ expect
      end
    end
  end
end
