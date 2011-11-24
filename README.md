Typhon is twisted Python.  
======


  <img src="https://raw.github.com/vic/typhon/master/etc/typhon-logo.png" title="Typhon is twisted Python" />


  A Python implementation for the Rubinius VM.

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

     # Get usage help
     $ ./bin/typhon --help

     # Run the hello world example
     $ ./bin/typhon examples/hello.py

     # If you want to run all the specs
     $ rake spec

     # Try -C --print-all on your python script.
     # This will most likely blow up and show you
     # a hint of what is needed to be implemented.
     $ ./bin/typhon -C --print-all your_script.py

     # You can use the --print-all switches with
     # the REPL like this:
     $ ./bin/typhon --print-all


## Status

  We have many simple python programs in the examples/ directory
  that run successfully. Of course there might be a lot of things
  missing, but that's were we need your help. Add an example, report
  an issue, or even better, submit a patch or pull request.

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

  DONE.

  We have Rubinius compiler stages at rbx/compiler/stages.rb
  Currently the parsing stage simply uses pyparse.py and
  evals the resulting sexp to later convert it to actual AST
  node instances.

- Have the Typhon compiler produce Rubinius bytecode.

  IN PROGRESS.

  We add bytecode methods to AST nodes as they are being used.

- Lots of tests.

  IN PROGRESS.

  Currently we use the scripts from examples/ directory to test
  that `typhon` and `python` programs produce the same output.

  Try running the example specs with

    $ mspec spec/examples_spec.rb

  Of course we need more specs without having to rely on stdout
  output. We're into it. Anyways ensuring all the files under
  examples/ work is always a good-thing(tm).

- Investigate if the pypy project has a Python parser in Python,
  if so, we could use that once we compile python programs
  to replace the bin/pyparse.py script.

- Bootstrap. write the Typhon compiler in Python.

## Contributing

Main repository is located at [http://github.com/vic/typhon](http://github.com/vic/typhon)
report any issues you find there.

The Typhon developers hang out in the
[#typhon-rbx](irc://irc.freenode.net/typhon-rbx) IRC channel on
[freenode](http://webchat.freenode.net?nick=snake%23%23%23%23&channels=typhon-rbx)
network.
If more people gets interested we might start a mailing-list.

Typhon is on its early days, if you want to help, you're more than welcome.
We follow the same commit bit policy than Rubinius and Pugs, if you get your first patch
accepted you get commit bit.

## Coding conventions.

Set your editor to use soft-tabs at two spaces for ruby code, no
hard-tabs for python code.
Configure your editor to automatically remove trailing whitespace and
be sure to leave an empty new-line at the end of file.

Try keep source code as readable as possible, that is, use proper
indentation, an empty new-line between method definitions, skip parens in ruby
where it makes sense (most if expressions), add source comments with
links to python design/algorithm documents if applicable, add
TODO/FIXME tags if needed.

## Logo

The Typhon logo has been kindly contributed by Christoph Grabo.
The logo is a derived work of the original Python logo and is 
distributed under a creative common license CC BY-NC-SA 3.0.

## About Typhon

  The name was chosen as an anagram of Python.

  In greek mithology, [Typhon](http://felc.gdufs.edu.cn/jth/myth/Greek%20Online/Typhon.htm) is one of the largest and most fearsome of all creatures.

  Theres a cool t-shirt showing what Typhon is all about:
  [snakes on rbx-head](http://twinsrpnt.com/blog/?p=180)

## License

  Modified BSD License. See LICENSE file.

## Contributors

  - Christoph Grabo
  - Graham Batty
  - Thiago Avelino
  - Victor Hugo Borja <vic.borja@gmail.com>  
