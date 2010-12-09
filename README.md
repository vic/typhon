Typhon
======

  Typhon is a python implementation for the Rubinius VM.

Why?
----

Just For Fun!.

Also, the Rubinius VM is a very neat piece of software, and all
the cool kids are using it to implement other languages besides
ruby.

Maybe Rubinius VM does what parrot was originally intended to.

## Requirements

  - python 2
  - rubinius head
  - rake

## Status

  Im in search of a nice python parser that can be implemented
  in ruby or used as a c-extension. Right now, we use a simple
  python script that outputs a program AST using ruby literals
  then feed that to the typhon compiler to produce rubinius asm

## Roadmap

Here's the plan as its currently in my head:

- Have a script to use python compiler module and let it
 produce a sexp made of ruby literals.

- Read this sexp from ruby and build an AST in ruby land.

- Write the Typhon compiler in ruby, taking advantage of
 Rubinius' compiler infrastructure.

- Have the Typhon compiler produce rubinius bytecode.

- Lots of tests.

- Investigate if we pypy has a python parser in python,
if so, we could use that once we compile python programs
to teplace the sexp-script.

- Bootstrap. write the Typhon compiler in python.

## About Typhon

  The name was choosen as a funny anagram of 'Python'.

  Also Typhon seems to be a weird looking creature:
  http://felc.gdufs.edu.cn/jth/myth/Greek%20Online/Typhon.htm

## License

  BSD.

## Contributors

  - Victor Hugo Borja <vic.borja@gmail.com>

