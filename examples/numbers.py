print "boom"

x = 1
y = 100000*100000 # current parser blows up on long numbers.
z = 10000

__debugger__()
print x.__class__, y.__class__, z.__class__

print x + 10
print z - 5
print y
print y * 100000
print y.__add__(100)

print "shackalacka"