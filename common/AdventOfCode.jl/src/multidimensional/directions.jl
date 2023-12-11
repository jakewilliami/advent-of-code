export direction, is_direction
export opposite_direction
export cardinal_directions, orthogonal_directions, cartesian_directions
export INDEX_LEFT, INDEX_RIGHT, INDEX_ABOVE, INDEX_BELOW
export INDEX_TOP_LEFT, INDEX_TOP_RIGHT, INDEX_BOTTOM_LEFT, INDEX_BOTTOM_RIGHT

const INDEX_LEFT         = CartesianIndex(0, -1)
const INDEX_RIGHT        = CartesianIndex(0, 1)
const INDEX_ABOVE        = CartesianIndex(-1, 0)
const INDEX_BELOW        = CartesianIndex(1, 0)
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


"""
```julia
is_direction(i::CartesianIndex{N}) -> bool
```

An index is classified as a direction if it has no magnitude, only sign.

See also: [`direction`](@ref).
"""
is_direction(i::CartesianIndex{N}) where {N} = i == direction(i)  # all(∈(-1:1), i.I)


"""
```julia
opposite_direction(d::CartesianIndex{N}) -> CartesianIndex{N}
```

Given some direction offset as a Cartesian index, find the opposite one.

See also: [`direction`](@ref) and [`is_direction`](@ref).
"""
function opposite_direction(d::CartesianIndex{N}) where {N}
    @assert is_direction(d)
    # Reverse direction
    r = _mk_cartesian_index(-one(eltype(d)), N)
    return CartesianIndex(d.I .* r.I)
end


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
