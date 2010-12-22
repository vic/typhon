This directoy contains small sample output (.out) files to test files inside the
examples/ directoy.

We need better and proper Typhon tests, but right now we could start
by making sure the examples work and we dont make regressions while improving Typhon.

By convention each file is named after the corresponding .py file in the examples/
directory being tested. Though this is not mandatory.

The first line should start with a comment like

    #! typhon examples/hello.py

Indicating the current file is the stdout output as expected from running
`typhon examples/hello.py` command. Everything after `#! typhon` is
given as arguments to the bin/typhon program.
And the whole line will be removed from expected output.

For example, to test the output of running the examples/foo/bar.py file
with two command line arguments, you should have the first line in the
.out file set to:

    #! typhon examples/foo/bar.y firstArg secondArg

Files not having that comment as first line will just be ignored.

Typhon is expected to be compatible as possible with the `python`
program. Because of this all tests run with `typhon` will be also run
with `python` and the output is expected to be equal.

Also, some examples output memory locations like 0x0AF30 in that cases
.out files can use ruby regexes like: #{/0x\d+/}.
