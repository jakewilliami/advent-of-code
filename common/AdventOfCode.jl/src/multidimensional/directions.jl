export Direction
export direction, is_direction
export is_diagonal, is_vertical, is_horizontal
export opposite_direction
export rotl90, rotr90, rot180
export cardinal_directions, orthogonal_directions, cartesian_directions
export INDEX_LEFT, INDEX_RIGHT, INDEX_ABOVE, INDEX_BELOW
export INDEX_WEST, INDEX_EAST, INDEX_NORTH, INDEX_SOUTH
export INDEX_UP, INDEX_DOWN
export INDEX_TOP_LEFT, INDEX_TOP_RIGHT, INDEX_BOTTOM_LEFT, INDEX_BOTTOM_RIGHT
export INDEX_NORTH_WEST, INDEX_NORTH_EAST, INDEX_SOUTH_WEST, INDEX_SOUTH_EAST

const INDEX_LEFT = INDEX_WEST                = CartesianIndex(0, -1)
const INDEX_RIGHT = INDEX_EAST               = CartesianIndex(0, 1)
const INDEX_ABOVE = INDEX_NORTH = INDEX_UP   = CartesianIndex(-1, 0)
const INDEX_BELOW = INDEX_SOUTH = INDEX_DOWN = CartesianIndex(1, 0)
const INDEX_TOP_LEFT = INDEX_NORTH_WEST      = INDEX_ABOVE + INDEX_LEFT
const INDEX_TOP_RIGHT = INDEX_NORTH_EAST     = INDEX_ABOVE + INDEX_RIGHT
const INDEX_BOTTOM_LEFT = INDEX_SOUTH_WEST   = INDEX_BELOW + INDEX_LEFT
const INDEX_BOTTOM_RIGHT = INDEX_SOUTH_EAST  = INDEX_BELOW + INDEX_RIGHT


const Direction{N} = CartesianIndex{N}


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


# Cardinal directions only differ from the origin in one dimension
_is_cardinal(d::CartesianIndex{N}) where {N} = isone(sum(map(abs, Tuple(d))))


"""
```julia
is_diagonal(d::CartesianIndex{2}) -> bool
```

Check if a 2D direction goes diagonally or not.

See also: [`is_vertical`](@ref) and [`is_horizontal`](@ref).
"""
function is_diagonal(d::CartesianIndex{2})
    is_direction(d) || error("$d is not a direction vector")
    return !_is_cardinal(d)
end


# Similar to _is_cardinal, but checks for arbitrary dimensions
function _direction_in_dims(d::CartesianIndex{N}; dims=:) where {N}
    dirs = ntuple(k -> dims == Colon() ? true : k ∈ dims, Val{N}())
    abs_d = map(abs, Tuple(d))
    return all((check ? isone : iszero)(m) for (m, check) in zip(abs_d, dirs))
end


"""
```julia
is_vertical(d::CartesianIndex{2}) -> bool
```

Check if a 2D direction goes up or down (vertically).

See also: [`is_diagonal`](@ref) and [`is_horizontal`](@ref).
"""
function is_vertical(d::CartesianIndex{2})
    is_direction(d) || error("$d is not a direction vector")
    _is_cardinal(d) || return false
    return _direction_in_dims(d, dims=1)
end


"""
```julia
is_horizontal(d::CartesianIndex{2}) -> bool
```

Check if a 2D direction goes left or right (horizontally).

See also: [`is_diagonal`](@ref) and [`is_vertical`](@ref).
"""
function is_horizontal(d::CartesianIndex{2})
    is_direction(d) || error("$d is not a direction vector")
    _is_cardinal(d) || return false
    return _direction_in_dims(d, dims=2)
end


"""
```julia
opposite_direction(d::CartesianIndex{N}) -> CartesianIndex{N}
rot180(d::CartesianIndex{2}) -> CartesianIndex{2}
```

Given some direction offset as a Cartesian index, find the opposite one.  This is equivalent to rotating 180 degrees in 2D space.

See also: [`direction`](@ref), [`is_direction`](@ref), [`rotl90`](@ref), and [`rotr90`](@ref).
"""
function opposite_direction(d::CartesianIndex{N}) where {N}
    is_direction(d) || error("$d is not a direction vector")
    # Reverse direction
    r = _mk_cartesian_index(-one(eltype(d)), N)
    return CartesianIndex(Tuple(d) .* Tuple(r))
end
Base.rot180(d::CartesianIndex{2}) = opposite_direction(d)


"""
```julia
rotl90(d::CartesianIndex{2}) -> CartesianIndex{N}
```

Rotate the 2D direction left 90°.

See also: [`rot180`](@ref), and [`rotr90`](@ref).
"""
function Base.rotl90(d::CartesianIndex{2})
    is_direction(d) || error("$d is not a direction vector")
    return CartesianIndex(reverse(Tuple(d)) .* (-1, 1))
end


"""
```julia
rotr90(d::CartesianIndex{2}) -> CartesianIndex{N}
```

Rotate the 2D direction right 90°.

See also: [`rot180`](@ref), and [`rotl90`](@ref).
"""
function Base.rotr90(d::CartesianIndex{2})
    is_direction(d) || error("$d is not a direction vector")
    return CartesianIndex(reverse(Tuple(d)) .* (1, -1))
end


# Get all cartesian directions as an iterator
function _cartesian_directions(dim::I; include_origin::Bool = false) where {I <: Integer}
    origin = Tuple(𝟘(dim))
    one_ = one(I)
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
    return CartesianIndex{dim}[i for i in dir_itr if _is_cardinal(i)]
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
