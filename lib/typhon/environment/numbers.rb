# This requires some special explanation. Normally I wouldn't
# want to reopen the Integer classes like this, but I can't really
# see any way around it since creation of them is disabled (and
# officially they are technically singletons anyways). As such,
# they have to be turned into python objects directly.

module Typhon
  module Environment
    def self.define_math_methods(c)
      c.python_method(:__abs__)   {|s|    s.abs }
      c.python_method(:__add__)   {|s, o| s + o }
      c.python_method(:__sub__)   {|s, o| s - o }
      c.python_method(:__div__)   {|s, o| s / o }
      c.python_method(:__truediv__) {|s, o| s.to_f / o.to_f }
      c.python_method(:__divmod__){|s, o| s.divmod(o).to_py }
      c.python_method(:__float__) {|s| s.to_f }
      c.python_method(:__floordiv__) {|s, o| s / o }
      c.python_method(:__long__)  {|s| s.to_i }
      c.python_method(:__mod__)   {|s, o| s % o }
      c.python_method(:__mul__)   {|s, o| s * o }
      c.python_method(:__neg__)   {|s| -s }
      c.python_method(:__nonzero__){|s| s != 0 }
      c.python_method(:__pos__)   {|s| +s }
      c.python_method(:__pow__)   {|s, o| s.pow(o) }
      # Note: reverse functions skipped because I'm not sure
      # what the semantics of those will even look like. Should be
      # figured out later.
      c.python_method(:__coerce__) do |s, o|
        # make them a common type: http://pyref.infogami.com/__coerce__
      end
    end
    
    python_class_c :Int, [ObjectBase], 'int', "int(x[, base]) -> integer\n\n" +
      "Convert a string or number to an integer, if possible.  A floating point\n" +
      "argument will be truncated towards zero (this does not include a string\n" +
      "representation of a floating point number!)  When converting a string, use\n" +
      "the optional base.  It is an error to supply a base when converting a\n" +
      "non-string. If the argument is outside the integer range a long object\n" +
      "will be returned instead." do
      
      extend FunctionTools
      
      python_class_method(:__new__) do |c, x, base|
        case x
        when Integer, Float
          if (!base.nil?)
            raise TypeError.new("Base argument makes no sense in integer initialization from numeric")
          end
          return x.to_i
        when String
          return x.to_i(base || 10)
        else
          raise TypeError.new("Could not initialize integer from #{x}")
        end
      end
      
      Environment.define_math_methods(self)
      
      python_method(:__and__) {|s, o| s && o }
      python_method(:__cmp__) {|s, o| s <=> o }
      python_method(:__hex__) {|s| s.to_s(16).to_py }
      python_method(:__index__) {|s| s }
      #python_method(:__invert__) {|s| s }
      python_method(:__lshift__) {|s, o| s << o }
      python_method(:__rshift__) {|s, o| s >> o }
      python_method(:__oct__) {|s| s.to_s(8).to_py }
      python_method(:__or__) {|s, o| s | o }
      python_method(:__and__) {|s, o| s & o }
      python_method(:__xor__) {|s, o| s ^ o }
      # Again, reverse methods are excluded for now.
      
      python_method(:__str__) {|s| s.to_s }
      python_method(:__repr__) {|s| s.to_s }
    end
    BuiltInModule[:int] = Int
    
    python_class_c :Long, [ObjectBase], 'long', "ong(x[, base]) -> integer\n\n" + 
      "Convert a string or number to a long integer, if possible.  A floating\n" +
      "point argument will be truncated towards zero (this does not include a\n" +
      "string representation of a floating point number!)  When converting a\n" +
      "string, use the optional base.  It is an error to supply a base when\n" +
      "converting a non-string." do
      
      extend FunctionTools
      
      python_class_method(:__new__) do |c, x, base|
        case x
        when Integer, Float
          if (!base.nil?)
            raise TypeError.new("Base argument makes no sense in integer initialization from numeric")
          end
          return x.to_i
        when String
          return x.to_i(base || 10)
        else
          raise TypeError.new("Could not initialize integer from #{x}")
        end
      end
      
      Environment.define_math_methods(self)
      
      python_method(:__str__) {|s| s.to_s }
      python_method(:__repr__) {|s| s.to_s + "L" }
    end

    python_class_c :PythonFloat, [ObjectBase], 'float', "float(x) -> floating point number\n\n" +
      "Convert a string or number to a floating point number, if possible." do
      
      extend FunctionTools
      
      python_class_method(:__new__) do |c, x|
        case x
        when Integer, Float, String
          return x.to_f
        else
          raise TypeError.new("Don't know how to initialize float from #{x}")
        end
      end

      Environment.define_math_methods(self)

      python_method(:__str__) {|s| s.to_s }
      python_method(:__repr__) {|s| s.to_s }
    end
    BuiltInModule[:float] = PythonFloat
  end
end

class Fixnum
  include Typhon::Environment::PythonSingleton
  python_initialize(Typhon::Environment::Int)
  
  def to_py()
    return self
  end
end

class Bignum
  include Typhon::Environment::PythonSingleton
  python_initialize(Typhon::Environment::Long)
  
  def to_py()
    return self
  end
end

class Float
  include Typhon::Environment::PythonSingleton
  python_initialize(Typhon::Environment::PythonFloat)
  
  def to_py()
    return self
  end
end