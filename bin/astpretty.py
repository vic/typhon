"""Python AST printer.

This file prints a python source AST as an array of ruby literals.

Based on astpretty.py by Martin Blais <blais@firius.ca>
Modified by Victor Hugo Borja <vic.borja@gmail.com> to produce ruby compatible sexp.
"""

import compiler, traceback, sys
from compiler.ast import Node
from os.path import dirname, join

alist = join(dirname(__file__), "node.py")
alist = eval( open(alist).read() )

nodes = dict(alist)

def rec_node(node, write):
    if isinstance(node, Node):
        name = node.__class__.__name__
        write('[')
        write(':' + name)
        if node.lineno:
            write(',' + str(node.lineno))
        else:
            write(',nil')

        write(',')

        for i, attr in enumerate(nodes[name]):
            if i != 0:
                write(',')
            child = getattr(node, attr)
            rec_node(child, write)

        write(']')
    elif None == node:
      write("nil")
    elif isinstance(node, list) or isinstance(node, tuple):
      write('[')
      for i, child in enumerate(node):
          if i != 0:
              write(',')
          rec_node(child, write)
      write(']')
    else:
      write(repr(node))

def main():
    import optparse
    oparse = optparse.OptionParser(__doc__.strip())
    opts, args = oparse.parse_args()
    try:
        if args:
            ast = compiler.parseFile(args[0])
        else:
            ast = compiler.parse(sys.stdin.read())
        rec_node(ast, sys.stdout.write)
        sys.stdout.write('\n')
    except SyntaxError, e:
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()
