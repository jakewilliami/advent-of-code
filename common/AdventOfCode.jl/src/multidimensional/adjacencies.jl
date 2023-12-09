include("n_adjacencies.jl")

export areadjacent
export cardinal_adjacencies, orthogonal_adjacencies, cartesian_adjacencies
export adjacent_cardinal_indices, adjacent_orthogonal_indices, adjacent_cartesian_indices
export cardinal_adjacencies_with_indices, orthogonal_adjacencies_with_indices, cartesian_adjacencies_with_indices


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
