Typhon Compiler
===============

This directory contains a Python compiler implemented in ruby
using Rubinius compiler chain.

Compiling Python
================

The main interface to the Typhon compiler is by using the methods implemented
in `compiler.rb`. `Typhon::Compiler` exposes functions to compile .py
files used as modules and python code string intended to be
evaled. The compiler is implemented in stages.

Stages
======

Compiling is made in stages, implemented in `stages.rb`.

## Parsing ##

The first step is to turn your python program (an string representing
valid python code) into a machine-representable format. This is called
_parsing_, and in current Typhon it's implemented by Python's own
parsing module. The `bin/pyparse.py` script is a tiny Python program
that simply outputs a _sexp_ representation of the source code. The
_sexp_ is made of only basic ruby literals, that is arrays, symbols,
strings, numbers and nil.

`parser.rb` exposes a simple `Typhon::Parser` module that just opens a
pipe to the `pyparse.py` program and returns the evaluated _sexp_.

This stage is implemented by `PyFile` and `PyCode` that essentially
just use `Typhon::Parser`.

## AST ##

The next step is turn the _sexp_ (an array of ruby literals) into
actual AST Nodes. An AST Node is a more logical representation of
what's being done in your program, for example, there's an AST Node
for every string literal, for import statements, for method
invocation, etc.

Once the AST (Abstract Syntax Tree) is complitely built, we are ready
to proceed with compilation.

This stage is implemented by `PyAST`

## AST Transformations ##

Next stage is doing AST transformations, that is, adapting the AST
tree for better suitting the purposes of python semantics.

All python programs are represented by a module object in python, and
because of this, the result of parsing any valid python code is a tree
having a root with type ModuleNode. However, in some cases, like
evaling a python expession with the _eval_ builtin function, we just
dont need nor want to create a new module for the code being
evaluated, instead, we want the code to be evaled on the current
context. For this end, Typhon has a `EvalExpr` stage that performs a
very simple transformation for an AST tree intended for eval.

In case of an eval, the `EvalExpr` stage simply removes the top
`ModuleNode` and makes sure the last expression returns a value
(unwraps any final `DiscardNode`).

If the AST tree was not intended for evaling, this stage does nothing.

## Bytecode Generator ##

This stage is where actual compilation takes place, it's implemented
in the `Generator` class. All it does is call the `bytecode` method on
the top of the AST tree. Every AST node is responsible for producing
the Rubinius bytecode for it's own.

See the _ast_ directory to find all AST nodes.

## Rest of Rubinius compiler chain ##

After the `Generator` stage, all we do is feed the produced generator
to Rubinius Encoder. So we rely on Rubinius doing bytecode analysis
and validation, also on writing compiled .rbc files to the file system
or producing an EvalExpression object for evals.
