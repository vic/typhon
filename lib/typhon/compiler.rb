base = File.dirname(__FILE__) + '/compiler/'

require base + 'compiler'
require base + 'stages'
require base + '../ast'

if __FILE__ == $0
  require base + 'command'
  Typhon::Compiler::Command.run ARGV
end
