module Multidimensional

# Origin
export origin, 𝟘
# Indexing
export hasindex, tryindex
# Directions
export direction
export cardinal_directions, orthogonal_directions, cartesian_directions
export INDEX_LEFT, INDEX_RIGHT, INDEX_ABOVE, INDEX_BELOW
export INDEX_TOP_LEFT, INDEX_TOP_RIGHT, INDEX_BOTTOM_LEFT, INDEX_BOTTOM_RIGHT
# Adjacencies
export n_cardinal_adjacencies, n_faces, n_adjacencies, areadjacent
export cardinal_adjacencies, orthogonal_adjacencies, cartesian_adjacencies
export adjacent_cardinal_indices, adjacent_orthogonal_indices, adjacent_cartesian_indices
export cardinal_adjacencies_with_indices, orthogonal_adjacencies_with_indices, cartesian_adjacencies_with_indices


### Origin

"""
```julia
origin(n::Integer) -> CartesianIndex{n}
𝟘(n::Integer) -> CartesianIndex{n}
```

The origin in ℝⁿ.

You can type 𝟘 by typing `\\bbzero<tab>`.
"""
origin(n::I) where {I <: Integer} = CartesianIndex(ntuple(_ -> zero(Int), n))
const 𝟘 = origin

### Indexing

"""
```julia
hasindex(M::AbstractArray{T}, i::CartesianIndex{N}) -> bool
```

Does the array `M` have index `i`?
"""
hasindex(M::AbstractArray{T}, i::CartesianIndex{N}) where {T, N} = checkbounds(Bool, M, i)


"""
```julia
tryindex(M::AbstractArray{T}, i::CartesianIndex{N}) -> Union{T, Nothing}
```

Returns the index, or `nothing` if the index is unavailable.

See also: [`hasindex`](@ref).
"""
tryindex(M::AbstractArray{T}, i::CartesianIndex{N}) where {T, N} = hasindex(M, i) ? M[i] : nothing


### Directions


const INDEX_LEFT         = CartesianIndex(0, -1)
const INDEX_RIGHT        = CartesianIndex(0, 1)
const INDEX_ABOVE        = CartesianIndex(1, 0)
const INDEX_BELOW        = CartesianIndex(-1, 0)
const INDEX_TOP_LEFT     = INDEX_ABOVE + INDEX_LEFT
const INDEX_TOP_RIGHT    = INDEX_ABOVE + INDEX_RIGHT
const INDEX_BOTTOM_LEFT  = INDEX_BELOW + INDEX_LEFT
const INDEX_BOTTOM_RIGHT = INDEX_BELOW + INDEX_RIGHT


"""
```julia
direction(i::CartesianIndex{N}) -> CartesianIndex{N}
```

Get the Cartesian direction offset of the given index.

For example, in ℝ², `(-3, 4)` points in the `(-1, 1)` (the "top right" direction).

See also: [`cartesian_directions`](@ref) and [`cardinal_directions`](@ref).
"""
direction(i::CartesianIndex{N}) where {N} = CartesianIndex{N}(map(sign, Tuple(i)))


function _cartesian_directions(dim::I; include_origin::Bool = false) where {I <: Integer}
    origin = Tuple(𝟘(dim))
    one_ = one(Int)
    dir_itr = Base.Iterators.product((-one_:one_ for i in one_:dim)...)
    fltr(t::NTuple{N,Int}) where {N} = include_origin ? true : t ≠ origin
    return (CartesianIndex(t) for t in dir_itr if fltr(t))
end


"""
```julia
cardinal_directions(dim::I; include_origin::Bool = false) -> Vector{CartesianIndex}
orthogonal_directions(dim::I; include_origin::Bool = false) -> Vector{CartesianIndex}
```

Find all cardinal/orthogonal direction offsets in the specified dimension.

Optionally, include the origin (e.g., `(0, 0, 0)`) if `include_origin` is set to true (this is the identity direction).

For example, in ℝ², `(-1, 0)` represents the "up" direction, and `(0, 1)` would represent the "right" direction.
If you had some `CartesianIndex` `i` whose surroundings in an array you want to check, you can iterate over the
results of this function.

See also: [`cartesian_directions`](@ref).
"""
function cardinal_directions(dim::I; include_origin::Bool = false) where {I <: Integer}
    dir_itr = _cartesian_directions(dim, include_origin = include_origin)

    # The cardinal directions is a coordinate with exactly one offset (all other
    # dimensions are zero)
    fltr(i::CartesianIndex{N}) where {N} = isone(sum(map(abs, Tuple(i))))

    return CartesianIndex{dim}[i for i in dir_itr if fltr(i)]
end
const orthogonal_directions = cardinal_directions


"""
```julia
cartesian_directions(dim::Integer; include_origin::Bool = false) -> Vector{CartesianIndex}
```

Find all direction offsets (including diagonals) in the specified dimension.

Optionally, include the origin (e.g., `(0, 0, 0)`) if `include_origin` is set to true (this is the identity direction).

For example, in ℝ², `(-1, 0)` represents the "up" direction, and `(1, -1)` would represent the "bottom left" direction.
If you had some `CartesianIndex` `i` whose surroundings in an array you want to check, you can iterate over the
results of this function.

See also: [`cardinal_directions`](@ref).
"""
cartesian_directions(dim::I; include_origin::Bool = false) where {I <: Integer} =
    collect(_cartesian_directions(dim, include_origin = include_origin))


### Adjacencies

"""
```julia
n_cardinal_adjacencies(n::Integer) -> Integer
```

The number of elements _cardinally_ adjacent to any given element in an infinite lattice/[hyper]matrix for a given ℝⁿ.

See also: [`n_adjacencies`](@ref) and [`n_faces`](@ref).
"""
n_cardinal_adjacencies(n::I) where {I <: Integer} = 2n


"""
```julia
n_faces(n::Integer) -> Integer
```

The number of faces of a structure for a given ℝⁿ.

See also: [`n_cardinal_adjacencies`](@ref).
"""
n_faces(n::I) where {I <: Integer} = n_cardinal_adjacencies(n)


"""
```julia
n_adjacencies(n::Integer) -> Integer
```

The number of elements adjacent to any given element in an infinite lattice/[hyper]matrix for a given ℝⁿ.

See also: [`n_cardinal_adjacencies`](@ref).
"""
n_adjacencies(n::I) where {I <: Integer} = 3^n - 1


"""
```julia
areadjacent(i::CartesianIndex{N}, j::CartesianIndex{N}) -> bool
```

Are `i` and `j` adjacent in n-dimensional Cartesian space?
"""
areadjacent(i::CartesianIndex{N}, j::CartesianIndex{N}) where {N} =
    !any(>(1), map(abs, Tuple(i - j)))


_adjacent_indices(i::CartesianIndex{N}, dir_fn::Function) where {N} =
    CartesianIndex{N}[i + d for d in dir_fn(N)]
_adjacent_indices(M::AbstractArray{T}, i::CartesianIndex{N}, dir_fn::Function) where {T, N} =
    CartesianIndex{N}[j for j in _adjacent_indices(i, dir_fn) if hasindex(M, j)]


_adjacencies_with_indices(M::AbstractArray{T}, i::CartesianIndex{N}, dir_fn::Function) where {T, N} =
    Tuple{CartesianIndex{N}, T}[(j, M[j]) for j in _adjacent_indices(M, i, dir_fn)]
_adjacencies(M::AbstractArray{T}, i::CartesianIndex{N}, dir_fn::Function) where {T, N} =
    T[x for (_i, x) in _adjacencies_with_indices(M, i, dir_fn)]


"""
```julia
adjacent_cardinal_indices(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{CartesianIndex{N}}
adjacent_orthogonal_indices(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{CartesianIndex{N}}
```

Return the cardinally adjacent indices in array `M` at the specified index `i`.

See also: [`cardinal_adjacencies`](@ref), [`cardinal_adjacencies_with_indices`](@ref), and [`adjacent_cartesian_indices`](@ref).
"""
adjacent_cardinal_indices(M::AbstractArray{T}, i::CartesianIndex{N}) where {T, N} =
    _adjacent_indices(M, i, cardinal_directions)
const adjacent_orthogonal_indices = adjacent_cardinal_indices


"""
```julia
cardinal_adjacencies_with_indices(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{Tuple{CartesianIndex{N}, T}}
orthogonal_adjacencies_with_indices(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{Tuple{CartesianIndex{N}, T}}
```

Returns a vector of cardinally adjacent elements in array `M` at the specified index `i`.  Each element of the return vector is a tuple whose first item is the index of the corresponding element.

See also: [`cardinal_adjacencies`](@ref) and [`cartesian_adjacencies`](@ref).
"""
cardinal_adjacencies_with_indices(M::AbstractArray{T}, i::CartesianIndex{N}) where {T, N} =
    _adjacencies_with_indices(M, i, cardinal_directions)
const orthogonal_adjacencies_with_indices = cardinal_adjacencies_with_indices


"""
```julia
cardinal_adjacencies(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{T}
orthogonal_adjacencies(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{T}
```

Returns a vector of cardinally adjacent elements in array `M` at the specified index `i`.

See also: [`cardinal_adjacencies_with_indices`](@ref) and [`cartesian_adjacencies`](@ref).
"""
cardinal_adjacencies(M::AbstractArray{T}, i::CartesianIndex{N}) where {T, N} =
    _adjacencies(M, i, cardinal_directions)
const orthogonal_adjacencies = cardinal_adjacencies


"""
```julia
adjacent_cartesian_indices(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{CartesianIndex{N}}
```

Return the adjacent indices (including diagonally) in array `M` at the specified index `i`.

See also: [`cartesian_adjacencies`](@ref), [`cartesian_adjacencies_with_indices`](@ref), and [`adjacent_cardinal_indices`](@ref).
"""
adjacent_cartesian_indices(M::AbstractArray{T}, i::CartesianIndex{N}) where {T, N} =
    _adjacent_indices(M, i, cartesian_directions)


"""
```julia
cartesian_adjacencies_with_indices(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{Tuple{CartesianIndex{N}, T}}
```

Returns a vector of adjacent elements (including diagonally) in array `M` at the specified index `i`.  Each element of the return vector is a tuple whose first item is the index of the corresponding element.

See also: [`cartesian_adjacencies`](@ref) and [`cartesian_adjacencies`](@ref).
"""
cartesian_adjacencies_with_indices(M::AbstractArray{T}, i::CartesianIndex{N}) where {T, N} =
    _adjacencies_with_indices(M, i, cartesian_directions)


"""
```julia
cartesian_adjacencies(M::AbstractArray{T}, i::CartesianIndex{N}) -> Vector{T}
```

Returns a vector of adjacent elements (including diagonally) in array `M` at the specified index `i`.

See also: [`cartesian_adjacencies_with_indices`](@ref) and [`cartesian_adjacencies`](@ref).
"""
cartesian_adjacencies(M::AbstractArray{T}, i::CartesianIndex{N}) where {T, N} =
    _adjacencies(M, i, cartesian_directions)


end  # end module
