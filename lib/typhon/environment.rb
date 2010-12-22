require 'typhon/environment/python_object'
require 'typhon/environment/type'
#require 'typhon/environment/function' # included part-way through type so it can define functions.
require 'typhon/environment/module'
require 'typhon/environment/built_ins'

Typhon::Environment.set_python_module(Typhon::Environment::BuiltInModule) do
  require 'typhon/environment/exceptions'
  require 'typhon/environment/string'
end