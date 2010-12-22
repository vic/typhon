Typhon
======

  Typhon is a Python implementation for the Rubinius VM.

Why?
----

Just For Fun!.

Python is one of the most popular dynamic languagues out there,
it has many projects made on it and has an outstanding number of
libraries available. 
So I guess having an implementation for it on Rubinius would make
Rubinius an strong player on VM field.

Also, the Rubinius VM is a very neat piece of software, and all
the cool kids are using it to implement other languages besides
ruby.

Maybe Rubinius VM does what Parrot was originally intended to.
( Running many dynamic languages )

## Requirements

  - python 2
  - rubinius head
  - rake

## Try it

     # Set rubinius as your current ruby.
     $ rvm use rbx
     # Compile the hello world example
     $ ./bin/typhon examples/hello.py

## Status

  Im in search of a nice Python parser that can be implemented
  in Ruby or used as a c-extension. Right now, we use a simple
  Python script that outputs a program AST using Ruby literals
  then feed that to the Typhon compiler to produce Rubinius asm

## Roadmap

Here's the plan as its currently in my head:

- Have a script to use Python compiler module and let it
 produce a sexp made of Ruby literals.

  DONE.

  bin/pyparse.py takes a Python script and outputs the AST as
  an array of ruby literals. The table of nodes and its attributes
  are read from bin/node.py. The output is just a sexp.

- Read this sexp from Ruby and build an AST in Ruby land.

  DONE.

  rbx/ast/node.rb Typhon::AST.from_sexp takes the sexp and just
  creates a tree of Python AST nodes in Ruby land. The table of
  nodes is the same pyparse.py uses, bin/node.py


- Write the Typhon compiler in Ruby, taking advantage of
 Rubinius' compiler infrastructure.

  IN PROGRESS.

  We have Rubinius compiler stages at rbx/compiler/stages.rb
  Currently the parsing stage simply uses pyparse.py and
  evals the resulting sexp to later convert it to actual AST
  node instances.

- Have the Typhon compiler produce Rubinius bytecode.

- Lots of tests.

- Investigate if we pypy has a Python parser in Python,
if so, we could use that once we compile python programs
to teplace the sexp-script.

- Bootstrap. write the Typhon compiler in Python.

## Contributing

Main repository is located at [http://github.com/vic/typhon](http://github.com/vic/typhon)
report any issues you find there. 

If more people gets interested we might start a mailing-list and freenode channel.

Typhon is on its early days, if you want to help, you're more than welcome.
We follow the same commit bit policy than Rubinius and Pugs, if you get your first patch 
accepted you get commit bit.

We need a logo, but i'm really bad at design stuff, so if you
have designing skills, I'd been thinking a cool logo for
Typhon could be a tornado of two or three little Python snakes :)

## About Typhon

  The name was choosen as a funny anagram of Python.

  In greek mithology, [Typhon](http://felc.gdufs.edu.cn/jth/myth/Greek%20Online/Typhon.htm) is one of the largest and most fearsome of all creatures. 

  Theres a cool t-shirt showing what Typhon is all about: 
  [snakes on rbx-head](http://twinsrpnt.com/blog/?p=179)

## License

  BSD.

## Contributors

  - Graham Batty
  - Victor Hugo Borja <vic.borja@gmail.com>

