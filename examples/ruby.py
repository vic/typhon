# -*- coding: utf-8 -*-

from __ruby__ import require
from __ruby__.Config.CONFIG import fetch as rb


require('rbconfig')
print rb("RUBY_INSTALL_NAME") # => rbx
