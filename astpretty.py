"""Python AST pretty-printer.

This module exports a function that can be used to print a human-readable
version of the AST.

Modified by Victor Hugo Borja <vic.borja@gmail.com> to produce ruby compatible sexp.
"""
__author__ = 'Martin Blais <blais@furius.ca>'

import sys
from compiler.ast import Node

__all__ = ('printAst',)


def printAst(ast, indent='  ', stream=sys.stdout, initlevel=0):
    "Pretty-print an AST to the given output stream."
    rec_node(ast, initlevel, indent, stream.write)
    stream.write('\n')

def rec_node(node, level, indent, write):
    "Recurse through a node, pretty-printing it."
    pfx = indent * level
    if isinstance(node, Node):
        write(pfx)
        write('[')
        write(':' + node.__class__.__name__)

        if node.getChildren():
            write(', ')

        if any(isinstance(child, Node) for child in node.getChildren()):
            for i, child in enumerate(node.getChildren()):
                if i != 0:
                    write(',')
                write('\n')
                rec_node(child, level+1, indent, write)
            write('\n')
            write(pfx)
        else:
            # None of the children as nodes, simply join their repr on a single
            # line.
            write(', '.join(leaf(child) for child in node.getChildren()))

        write(']')

    else:
        write(pfx)
        write(leaf(node))

def leaf(node):
    if None == node:
        return 'nil'
    return repr(node)

def main():
    import optparse
    parser = optparse.OptionParser(__doc__.strip())
    opts, args = parser.parse_args()

    import compiler, traceback

    try:
        if args:
            ast = compiler.parseFile(args[0])
        else:
            ast = compiler.parse(sys.stdin.read())
        printAst(ast, initlevel=0)
    except SyntaxError, e:
        traceback.print_exc()

if __name__ == '__main__':
    main()


