class Typhon
  class VERSION < Struct.new(:major, :minor, :patch, :commit)
   def to_s
    [major, minor, patch].join(".")
   end
  end

  VERSION = VERSION.new(0, 0, 1)
end

