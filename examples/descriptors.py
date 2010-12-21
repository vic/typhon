class DataDesc(object):
  def __get__(self, obj, type):
    print "datadesc", self, obj, type
  def __set__(self, obj, val):
    print "datadesc", self, obj, val

class Desc(object):
  def __get__(self, obj, type):
    print "desc", self, obj, type

class test(object):
  dd = DataDesc()
  d = Desc()

#__debugger__()
test.dd
test.d

test().dd
test().d
