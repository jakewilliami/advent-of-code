# AdventOfCode.jl

Common helper functions used in various Advent of Code solutions.

To add this to a day's solution, create a project and add the module [as described here](https://discourse.julialang.org/t/26358/2).

### Current Modules

Modules I have written that are nested within the `AdventOfCode` module to help with various common logic:
  - Multidimensional: provides various multidimensional helper functions for working with indices and offsets.
  - Parsing: helpful parser methods for AoC input.

### Commonly Used Packages

These are modules I have not written (packages) that I tend to find very useful in AoC solutions:
  - Standard library:
    - Statistics: for `mean` and `median` functions.
	- LinearAlgebra: for any sufficiently advanced matrix operations that aren't in `Base`.
  - External:
	- Combinatorics: for finding combinations and permutations of relatively small sets (useful in brute force solutions).
	- CircularList: a library written by Tom Kwong that implements a _circular_ doubly-linked list.
    - DataStructures: for structures such as `Queue` or `Stack`, and `DefaultDict`.
	- Graphs: when BFS is not sufficient and I don't want to implement Dijkstra's.
	- LP (Linear Programming): optimisation libraries including:
	  - JuMP: modeling language for mathematical optimisation.
	  - HiGHS: optimiser for linear solving.
	  - GLPK: another optimiser.
    - MultidimensionalTools: a library written by _moi_, useful for various multidimensional problems.
	- StatsBase: namely for its `countmap` function.
