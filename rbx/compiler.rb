base = File.dirname __FILE__

require base + '/compiler/compiler'
require base + '/compiler/stages'

if __FILE__ == $0
  require base + '/compiler/command'
  Typhon::Compiler::Command.run ARGV
end
