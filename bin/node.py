# This is a table of Python AST nodes as documented on
#   http://docs.python.org/library/compiler.html#module-compiler.ast
#
# The idea is this file can be evaled by both ruby and python programs
[
    [ 'Add',          [ 'left', 'right' ], ],
    [ 'And',          [ 'nodes' ], ],
    [ 'AssAttr',      [ 'expr', 'attrname', 'flags' ], ],
    [ 'AssList',      [ 'nodes' ], ],
    [ 'AssName',      [ 'name', 'flags' ], ],
    [ 'AssTuple',     [ 'nodes' ], ],
    [ 'Assert',       [ 'test', 'fail' ], ],
    [ 'Assign',       [ 'nodes', 'expr' ], ],
    [ 'AugAssign',    [ 'node', 'op', 'expr' ], ],
    [ 'Backquote',    [ 'expr' ], ],
    [ 'Bitand',       [ 'nodes' ], ],
    [ 'Bitor',        [ 'nodes' ], ],
    [ 'Bitxor',       [ 'nodes' ], ],
    [ 'Break',        [ ], ],
    [ 'CallFunc',     [ 'node', 'args', 'star_args', 'dstar_args' ], ],
    [ 'Class',        [ 'name', 'bases', 'doc', 'code' ], ],
    [ 'Compare',      [ 'expr', 'ops' ], ],
    [ 'Const',        [ 'value' ], ],
    [ 'Continue',     [ ], ],
    [ 'Decorators',   [ 'nodes' ], ],
    [ 'Dict',         [ 'items' ], ],
    [ 'Discard',      [ 'expr' ], ],
    [ 'Div',          [ 'left', 'right' ], ],
    [ 'Ellipsis',     [ ], ],
    [ 'Exec',         [ 'expr', 'locals', 'globals' ], ],
    [ 'FloorDiv',     [ 'left', 'right' ], ],
    [ 'For',          [ 'assign', 'list', 'body', 'else_' ], ],
    [ 'From',         [ 'modname', 'names' ], ],
    [ 'Function',     [ 'decorators', 'name', 'argnames', 'defaults', 'flags', 'doc', 'code' ], ],
    [ 'GenExpr',      [ 'code' ], ],
    [ 'GenExprFor',   [ 'assign', 'iter', 'ifs' ], ],
    [ 'GenExprIf',    [ 'test' ], ],
    [ 'GenExprInner', [ 'expr', 'quals' ], ],
    [ 'Getattr',      [ 'expr', 'attrname' ], ],
    [ 'Global',       [ 'names' ], ],
    [ 'If',           [ 'tests', 'else_' ], ],
    [ 'Import',       [ 'names' ], ],
    [ 'Invert',       [ 'expr' ], ],
    [ 'Keyword',      [ 'name', 'expr' ], ],
    [ 'Lambda',       [ 'argnames', 'defaults', 'flags', 'code' ], ],
    [ 'LeftShift',    [ 'left', 'right' ], ],
    [ 'List',         [ 'nodes' ], ],
    [ 'ListComp',     [ 'expr', 'quals' ], ],
    [ 'ListCompFor',  [ 'assign', 'list', 'ifs' ], ],
    [ 'ListCompIf',   [ 'test' ], ],
    [ 'Mod',          [ 'left', 'right' ], ],
    [ 'Module',       [ 'doc', 'node' ], ],
    [ 'Mul',          [ 'left', 'right' ], ],
    [ 'Name',         [ 'name' ], ],
    [ 'Not',          [ 'expr' ], ],
    [ 'Or',           [ 'nodes' ], ],
    [ 'Pass',         [ ], ],
    [ 'Power',        [ 'left', 'right' ], ],
    [ 'Print',        [ 'nodes', 'dest' ], ],
    [ 'Printnl',      [ 'nodes', 'dest' ], ],
    [ 'Raise',        [ 'expr1', 'expr2', 'expr3' ], ],
    [ 'Return',       [ 'value' ], ],
    [ 'RightShift',   [ 'left', 'right' ], ],
    [ 'Slice',        [ 'expr', 'flags', 'lower', 'upper' ], ],
    [ 'Sliceobj',     [ 'nodes' ], ],
    [ 'Stmt',         [ 'nodes' ], ],
    [ 'Sub',          [ 'left', 'right' ], ],
    [ 'Subscript',    [ 'expr', 'flags', 'subs' ], ],
    [ 'TryExcept',    [ 'body', 'handlers', 'else_' ], ],
    [ 'TryFinally',   [ 'body', 'final' ], ],
    [ 'Tuple',        [ 'nodes' ], ],
    [ 'UnaryAdd',     [ 'expr' ], ],
    [ 'UnarySub',     [ 'expr' ], ],
    [ 'While',        [ 'test', 'body', 'else_' ], ],
    [ 'With',         [ 'expr', 'vars', 'body' ], ],
    [ 'Yield',        [ 'value' ] ]
]
