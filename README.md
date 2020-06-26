# Pythonic::Itertools

Raku implementations of functions from the Python `itertools` library

## NOTES

I wrote this as a personal exercise, and the functions we're written with a specific goal of mimicking the semantics of the Python functions as much as possible, even though the semantics of Python don't always see eye to eye with the semantics of Raku.

Another selfish goal was to try to produce values that always show you partial results, rather than just `(...)`. This grew out of my minor annoyance of working with Python iterators, and constantly being greeted by something like this: `<itertools.permutations object at 0x7feae5133770>`

Which is to say, sometimes I might use a `gather/take` when a simple map might do.

See the test suite for some examples
