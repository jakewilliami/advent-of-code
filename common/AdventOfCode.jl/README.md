# AdventOfCode.jl

Common helper functions used in various Advent of Code solutions.

To add this to a day's solution, create a project and add the module [as described here](https://discourse.julialang.org/t/26358/2).

## Library Documentation

Modules I have written that are nested within the `AdventOfCode` module to help with various common logic:
  - Parsing: helpful parser methods for AoC input.
  - Multidimensional: provides various multidimensional helper functions for working with indices and offsets.

### Parsing

  - `get_integers(s::String; negatives::Bool = false) -> Vector{Int}`: extract all integers from a string.
  - `readlines_into_char_matrix(file::String) -> Matrix{Char}`: read file as character matrix.
  - `readlines_into_int_matrix(file::String) -> Matrix{Int}`: read file as integer matrix.

### Multidimensional

#### Origin

  - `origin(n::Integer) -> CartesianIndex{n}`: the origin in ℝⁿ (can also use `𝟘`).

#### Indexing

  - `hasindex(M::AbstractArray{T}, i::CartesianIndex{N}) -> bool`: does the array have the specified index?
  - `tryindex(M::AbstractArray{T}, i::CartesianIndex{N}) -> Union{T, Nothing}`: gets the element of the array at a specified index, or nothing if it doesn't have that index.

#### Directions

  - `direction(i::CartesianIndex{N}) -> CartesianIndex{N}`: get the Cartesian direction offset of the specified index; e.g., `(-3, 3)` has the `(-1, 1)` direction.
  - `cardinal_directions(dim::I; include_origin::Bool = false) -> Vector{CartesianIndex}`: Find all direction offsets in the specified dimension (can also use `orthogonal_directions`).
  - `cartesian_directions(dim::I; include_origin::Bool = false) -> Vector{CartesianIndex}`: Find all direction offsets (including diagonal) in the specified dimension.

#### Adjacencies

  - `n_faces(n::Integer) -> Integer`: the number of faces of a point/square/[hyper]cube in ℝⁿ.
  - Number of adjacencies:
    - `n_cardinal_adjacencies(n::Integer) -> Integer`: the number of points cardinally adjacent to any given point in ℝⁿ.
    - `n_adjacencies(n::Integer) -> Integer`: the number of points adjacent to any given point in ℝⁿ (including diagonally).
  - `areadjacent(i::CartesianIndex{N}, j::CartesianIndex{N}) -> bool`: are two indices `i` and `j` adjacent?
  - Adjacent elements:
    - `cardinal_adjacencies(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{T}`: the cardinally adjacent elements to the specified index within the array (can also use `orthogonal_adjacencies`).
    - `cartesian_adjacencies(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{T}`: the adjacent elements (including diaginally) to the specified index within the array.
  - Adjacent indices:
    - `adjacent_cardinal_indicies(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{T}`: the cardinally adjacent indices to the specified index within the array (can also use `adjacent_orthogonal_indices`).
    - `adjacent_cartesian_indices(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{T}`: the adjacent indices (including diaginally) to the specified index within the array.
  - Adjacent elements with indices:
    - `cardinal_adjacencies_with_indices(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{Tuple{CartesianIndex{N}, T}}`: the cardinally adjacent elements and indices to the specified index within the array (can also use `orthogonal_adjacencies_with_indices`).
    - `cartesian_adjacencies_with_indices(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{Tuple{CartesianIndices{N}, T}}`: the adjacent elements and indices (including diaginally) to the specified index within the array.
  - Direction constants:
    - `INDEX_LEFT`, `INDEX_RIGHT`, `INDEX_ABOVE`, `INDEX_BELOW`
    - `INDEX_TOP_LEFT`, `INDEX_TOP_RIGHT`, `INDEX_BOTTOM_LEFT`, `INDEX_BOTTOM_RIGHT`

## Other

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
