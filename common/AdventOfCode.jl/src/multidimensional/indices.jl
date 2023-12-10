export CartesianIndicesRowWise

# https://github.com/JuliaLang/julia/blob/84cfe04e/base/multidimensional.jl#L267-L465
# NOTE: use CartesianIndices or eachindex when you can, as RowWise will be slower.  Should only use for convenience
# Resource:
#   https://github.com/JuliaLang/julia/blob/84cfe04e/base/multidimensional.jl#L267-L269
struct CartesianIndicesRowWise{N, R <: NTuple{N, OrdinalRange{Int, Int}}} <: AbstractArray{CartesianIndex{N}, N}
    inner::CartesianIndices{N, R}
end

# Only constructor methods needed for now
CartesianIndicesRowWise(A::AbstractArray) = CartesianIndicesRowWise(CartesianIndices(A))

# Pretty show in REPL
# Resource:
#   https://github.com/JuliaLang/julia/blob/84cfe04e/base/multidimensional.jl#L288-L295
_xform_index(i) = i
_xform_index(i::Base.OneTo) = i.stop
function Base.show(io::IO, iter::CartesianIndicesRowWise)
    print(io, "CartesianIndicesRowWise(")
    show(io, map(_xform_index, iter.inner.indices))
    print(io, ")")
end
Base.show(io::IO, ::MIME"text/plain", iter::CartesianIndicesRowWise) = show(io, iter)

# Some array/iter base functions.  As this struct is a light wrapper around the real CartesianIndices
# so we can just call to these methods on the inner CartesianIndices struct
# Resources:
#   https://github.com/JuliaLang/julia/blob/84cfe04e/base/multidimensional.jl#L358-L396
#   https://github.com/JuliaLang/julia/blob/84cfe04e/base/multidimensional.jl#L457-L465
Base.axes(iter::CartesianIndicesRowWise) = axes(iter.inner)
Base.size(iter::CartesianIndicesRowWise) = size(iter.inner)
Base.length(iter::CartesianIndicesRowWise) = length(iter.inner)
Base.getindex(iter::CartesianIndicesRowWise, i) = getindex(iter.inner, i)
Base.step(iter::CartesianIndicesRowWise) = step(iter.inner)
Base.first(iter::CartesianIndicesRowWise) = first(iter.inner)
Base.last(iter::CartesianIndicesRowWise)  = last(iter.inner)
Base.ndims(R::CartesianIndicesRowWise) = ndims(R.inner)

# Custom row-wise iteration!
# Note: I am using 2D language in variables because brain is smol
# Resource:
#   https://github.com/JuliaLang/julia/blob/84cfe04e/base/multidimensional.jl#L414-L425
function Base.iterate(iter::CartesianIndicesRowWise)
    iterfirst = first(iter)
    all(map(∈, iterfirst.I, iter.inner.indices)) || return nothing
    return iterfirst, iterfirst
end

function Base.iterate(iter::CartesianIndicesRowWise, state)
    valid, t = __inc(state.I, iter.inner.indices)
    valid || return nothing
    I = CartesianIndex(t...)
    return I, I
end

# Resource:
#   https://github.com/JuliaLang/julia/blob/84cfe04e/base/multidimensional.jl#L437-L452
# Remember index order: (row, ..., column)
__inc(::Tuple{}, ::Tuple{}) = false, ()
function __inc(state::Tuple{Int}, indices::Tuple{OrdinalRange{Int, Int}})
    cols = last(indices)
    ncols = last(cols)
    col = last(state)
    I = col + step(cols)
    valid = col != ncols
    return valid, (I,)
end
function __inc(state::Tuple{Int, Int, Vararg{Int}}, indices::Tuple{OrdinalRange{Int, Int}, OrdinalRange{Int, Int}, Vararg{OrdinalRange{Int, Int}}})
    cols = last(indices)
    ncols = last(cols)
    col = last(state)
    I = col + step(cols)
    col != ncols && return true, (Base.front(state)..., I)
    valid, I = __inc(Base.front(state), Base.front(indices))
    return valid, (I..., first(cols))
end
