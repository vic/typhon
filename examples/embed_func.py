z = 'watevah'

def blah(a,k='b'):
 def blorp(b):
  print(b) #3
  print(a) #4
  print(z) #5
  print(__name__) #6
  
 l = lambda x: x
 #def l(x): return x
   
 print(l("zoom!")) #1
 
 print(a,k) #2
 blorp("boom")

blah("floom")
