module Multidimensional

export readlines_into_char_matrix, readlines_into_int_matrix
export n_cardinal_adjacencies, n_faces, n_adjacencies, areadjacent
export 𝟘
export hasindex, tryindex, tryindices
export cardinal_directions, cartesian_directions, direction


# Read

_lines_into_matrix(lines, f::Function = identity) =
    reduce(vcat, permutedims(f.(collect(s))) for s in lines if !isempty(strip(s)))


"""
```julia
readlines_into_char_matrix(file::String) -> Matrix{Char}
```

Create a matrix of characters given a file, in which each line represents a row, and each character, a respective element in that row.

For example, given the file
```
abcde
fghij
```

This function will produce the matrix
```julia
2×5 Matrix{Char}:
 'a'  'b'  'c'  'd'  'e'
 'f'  'g'  'h'  'i'  'j'
```

See also: [`readlines_into_int_matrix`](@ref).
"""
readlines_into_char_matrix(file::String) = _lines_into_matrix(eachline(file))


"""
```julia
readlines_into_char_matrix(file::String) -> Matrix{Int}
```

Create a matrix of integers (one per character) given a file, in which the line index represents the row, and the character index, the column.

For example, given the file
```
01234
56789
```

This function will produce the matrix
```julia
2×5 Matrix{Int64}:
 0  1  2  3  4
 5  6  7  8  9
```

See also: [`readlines_into_char_matrix`](@ref).
"""
readlines_into_int_matrix(file::String) =
    _lines_into_matrix(eachline(file), c -> parse(Int, c))


### Adjacencies

"""
```julia
n_cardinal_adjacencies(n::Integer) -> Integer
```

The number of elements _cardinally_ adjacent to any given element in an infinite lattice/[hyper]matrix for a given ℝⁿ.

See also: [`n_adjacencies`](@ref) and [`n_faces`](@ref).
"""
n_cardinal_adjacencies(n::I) where {I<:Integer} = 2n


"""
```julia
n_faces(n::Integer) -> Integer
```

The number of faces of a structure for a given ℝⁿ.

See also: [`n_cardinal_adjacencies`](@ref).
"""
n_faces(n::I) where {I<:Integer} = n_cardinal_adjacencies(n)


"""
```julia
n_adjacencies(n::Integer) -> Integer
```

The number of elements adjacent to any given element in an infinite lattice/[hyper]matrix for a given ℝⁿ.

See also: [`n_cardinal_adjacencies`](@ref).
"""
n_adjacencies(n::I) where {I<:Integer} = 3^n - 1


"""
```julia
areadjacent(i::CartesianIndex{N}, j::CartesianIndex{N}) -> bool
```

Are `i` and `j` adjacent in n-dimensional Cartesian space?
"""
areadjacent(i::CartesianIndex{N}, j::CartesianIndex{N}) where {N} =
    !any(>(1), map(abs, Tuple(i - j)))


### Origin

"""
```julia
𝟘(n::Integer) -> CartesianIndex{n}
```

The origin in ℝⁿ.

You can type 𝟘 by typing `\\bbzero<tab>`.
"""
𝟘(n::I) where {I<:Integer} = CartesianIndex(ntuple(_ -> zero(Int), n))


### Indexing

"""
```julia
hasindex(M::AbstractArray{T}, i::CartesianIndex{N}) -> bool
```

Does the array `M` have index `i`?

See also: [`
"""
hasindex(M::AbstractArray{T}, i::CartesianIndex{N}) where {T,N} = checkbounds(Bool, M, i)


"""
```julia
tryindex(M::AbstractArray{T}, i::CartesianIndex{N}) -> Union{T, Nothing}
```

Returns the index, or `nothing` if the index is unavailable.

See also: [`hasindex`](@ref) and [`tryindices`](@ref).
"""
tryindex(M::AbstractArray, i::CartesianIndex) where {T,N} = hasindex(M, i) ? M[i] : nothing


### Cartesian directions


"""
```julia
direction(i::CartesianIndex{N}) -> CartesianIndex{N}
```

Get the Cartesian direction offset of the given index.

For example, in ℝ², `(-3, 4)` points in the `(-1, 1)` (the "top right" direction).

See also: [`cartesian_directions`](@ref) and [`cardinal_directions`](@ref).
"""
direction(i::CartesianIndex{N}) where {N} = CartesianIndex{N}(map(sign, Tuple(i)))


function _cartesian_directions(dim::I; include_origin::Bool = false) where {I<:Integer}
    origin = Tuple(𝟘(dim))
    one_ = one(Int)
    dir_itr = Base.Iterators.product((-one_:one_ for i in one_:dim)...)
    fltr(t::NTuple{N,Int}) where {N} = include_origin ? true : t ≠ origin
    return (CartesianIndex(t) for t in dir_itr if fltr(t))
end


"""
```julia
cardinal_directions(dim::I; include_origin::Bool = false) -> Vector{CartesianIndex}
```

Find all cardinal direction offsets in the specified dimension.

Optionally, include the origin (e.g., `(0, 0, 0)`) if `include_origin` is set to true (this is the identity direction).

For example, in ℝ², `(-1, 0)` represents the "up" direction, and `(0, 1)` would represent the "right" direction.
If you had some `CartesianIndex` `i` whose surroundings in an array you want to check, you can iterate over the
results of this function.

See also: [`cartesian_directions`](@ref).
"""
function cardinal_directions(dim::I; include_origin::Bool = false) where {I<:Integer}
    dir_itr = _cartesian_directions(dim, include_origin = include_origin)

    # The cardinal directions is a coordinate with exactly one offset (all other
    # dimensions are zero)
    fltr(i::CartesianIndex{N}) where {N} = isone(sum(map(abs, Tuple(i))))

    return CartesianIndex{dim}[i for i in dir_itr if fltr(i)]
end


"""
```julia
cartesian_directions(dim::Integer; include_origin::Bool = false) -> Vector{CartesianIndex}
```

Find all direction offsets in the specified dimension.

Optionally, include the origin (e.g., `(0, 0, 0)`) if `include_origin` is set to true (this is the identity direction).

For example, in ℝ², `(-1, 0)` represents the "up" direction, and `(1, -1)` would represent the "bottom left" direction.
If you had some `CartesianIndex` `i` whose surroundings in an array you want to check, you can iterate over the
results of this function.

See also: [`cardinal_directions`](@ref).
"""
cartesian_directions(dim::I; include_origin::Bool = false) where {I<:Integer} =
    collect(_cartesian_directions(dim, include_origin = include_origin))


end  # end module
