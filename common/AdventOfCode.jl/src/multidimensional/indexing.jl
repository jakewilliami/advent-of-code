export hasindex, tryindex

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
