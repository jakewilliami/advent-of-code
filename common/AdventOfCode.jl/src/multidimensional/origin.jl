export origin, 𝟘

"""
```julia
origin(n::Integer) -> CartesianIndex{n}
𝟘(n::Integer) -> CartesianIndex{n}
```

The origin in ℝⁿ.

You can type 𝟘 by typing `\\bbzero<tab>`.
"""
origin(n::I) where {I <: Integer} = _mk_cartesian_index(zero(Int), n)
const 𝟘 = origin
