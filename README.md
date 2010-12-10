Typhon
======

  Typhon is a Python implementation for the Rubinius VM.

Why?
----

Just For Fun!.

Also, the Rubinius VM is a very neat piece of software, and all
the cool kids are using it to implement other languages besides
ruby.

Maybe Rubinius VM does what Parrot was originally intended to.

## Requirements

  - python 2
  - rubinius head
  - rake

## Try it

     # Set rubinius as your current ruby.
     $ rvm use rbx
     # Compile the hello world example
     $ rbx rbx/compiler.rb examples/hello.py

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

Typhon is on its early days, so if you want to help, just ask,
and I'll give you commit bit.

We need a logo, but i'm really bad at design stuff, so if you
have designing skills, I'd been thinking a cool logo for
Thyphon could be a tornado of two or three little Python snakes :)

## About Typhon

  The name was choosen as a funny anagram of Python.

  Also Typhon seems to be a weird looking creature:
  [http://felc.gdufs.edu.cn/jth/myth/Greek%20Online/Typhon.htm](http://felc.gdufs.edu.cn/jth/myth/Greek%20Online/Typhon.htm)


## License

  BSD.

## Contributors

  - Victor Hugo Borja <vic.borja@gmail.com>

