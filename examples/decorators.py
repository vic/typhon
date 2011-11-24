# -*- coding: utf-8 -*-

class test(object):

    @staticmethod
    def static(a,b,c):

      print a, b, c

    @classmethod
    def clsm(cls, a, b, c):

      print cls, a, b, c


test.static(1,2,3) # => "1 2 3"
test.clsm(1,2,3) # => "<type 'test'> 1 2 3"

test().static(1,2,3) # => "1 2 3"
test().clsm(1,2,3) # => "<type 'test'> 1 2 3"
