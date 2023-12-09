export n_cardinal_adjacencies, n_faces, n_adjacencies

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
