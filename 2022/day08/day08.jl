# Parse input

parse_input(f::String) =
    reduce(vcat, permutedims(parse.(Int, collect(s))) for s in readlines(f))


# Indexing stuff

function tryindex(M::Matrix{T}, i::CartesianIndex{N}) where {T, N}
    try
        return getindex(M, i)
    catch
        return nothing
    end
end
tryindices(M::Matrix{T}, is::CartesianIndex{N}...) where {T, N} =
    Union{T, Nothing}[tryindex(M, i) for i in is]

# Get a list of cartesian direction modifiers
function cartesian_directions(dim::Int; exclude_diag::Bool = true)
    T = Int
    𝟎 = ntuple(_ -> zero(T), dim)
    dir_itr = Base.Iterators.product([-one(T):one(T) for i in one(T):dim]...)

    # The sum of the absolute values of the elements in a diagonal coordinate
    # is always equal to the number of dimensions because, in a diagonal coordinate,
    # all the elements have a value of either 1 or -1
    fltr(t) = exclude_diag ? sum(abs.(t)) != dim : true

    return CartesianIndex{dim}[CartesianIndex(t) for t in dir_itr if t ≠ 𝟎 && fltr(t)]
end

# Increment an index further away from the origin, e.g., (1, -3) -> (2, -4)
_move_further_from_origin(t::NTuple{N, T}) where {N, T} =
    @. (abs(t) + 1) * sign(t)
_move_further_from_origin(i::CartesianIndex{N}) where {N} =
    CartesianIndex(_move_further_from_origin(i.I))

# Construct a map of lists of values in the given matrix at each direction away from a specified index
function global_adjacencies(M::Matrix{T}, i::CartesianIndex{N}, direction_modifiers) where {T, N}
    D = Dict{CartesianIndex, Vector{T}}(s => T[] for s in direction_modifiers)

    dᵢ = 1
    while dᵢ <= length(DIRECTIONS)
        directional_shift = DIRECTIONS[dᵢ]
        j = i
        while true
            j += directional_shift

            if isnothing(tryindex(M, j))
                dᵢ += 1
                break
            end

            push!(D[DIRECTIONS[dᵢ]], M[j])
        end
    end

    return D
end


# Part 1

function part1(map::Matrix{T}) where {T <: Number}
    res= 0
    for i in CartesianIndices(map)
        A = global_adjacencies(map, i, DIRECTIONS)
        # Increment result if tree has a direct path in any cartesian direction
        res += any(isempty(A[d]) || all(map[i] > a for a in A[d]) for d in DIRECTIONS)
    end
    return res
end


# Part 2

function part2(map::Matrix{T}) where {T <: Number}
    scenic_scores = Vector{T}(undef, prod(size(map)))

    for (k, i) in enumerate(CartesianIndices(map))
        A = global_adjacencies(map, i, DIRECTIONS)

        p = 1
        for d in DIRECTIONS
            # Find the first tree that blocks our view
            j = findfirst(>=(map[i]), A[d])
            # If there is no such tree, we have the length of the whole row
            q = isnothing(j) ? length(A[d]) : j
            # Add to scenic score
            p *= q
        end
        scenic_scores[k] = p
    end

    return maximum(scenic_scores)
end


# Main

const DIRECTIONS = cartesian_directions(2)

function main()
    data = parse_input("data08.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 1715
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 374400
    println("Part 2: $part2_solution")
end

main()
