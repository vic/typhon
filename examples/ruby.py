from __ruby__ import require

require('rbconfig')
from __ruby__.Config.CONFIG import fetch as rb

print rb("RUBY_INSTALL_NAME") # => rbx
