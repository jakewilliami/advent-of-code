const LEFT = (0, -1)
const DOWN = (1, 0)
const RIGHT = (0, 1)
const UP = (-1, 0)

const DIRECTIONS = CartesianIndex.((UP, DOWN, LEFT, RIGHT))


# Parse input

parse_input(f::String) = reduce(vcat, permutedims(parse.(Int, collect(s))) for s in readlines(f))


# Part 1

function tryindex(M::Matrix{T}, inds::NTuple{N, Int}...) where {T, N}
    indices = Vector{Union{T, Nothing}}()

    for idx in inds
        try
            push!(indices, getindex(M, idx...))
        catch
            push!(indices, nothing)
        end
    end

    return indices
end

function adjacencies(M::Matrix{T}, idx::NTuple{N, Int}) where {T, N}
    𝟎 = ntuple(_ -> zero(Int), N)
    i = CartesianIndex(idx...)
    return T[k for k in tryindex(M, ((i + j).I for j in DIRECTIONS)...) if !isnothing(k)]
end


function global_adjacencies(M::Matrix{T}, idx::NTuple{N, Int}) where {T, N}
    D = Dict{CartesianIndex, Vector{T}}(s => T[] for s in DIRECTIONS)

    dᵢ = 1
    while dᵢ <= length(DIRECTIONS)
        directional_shift = DIRECTIONS[dᵢ].I
        while true
            adj_index = idx .+ directional_shift

            if nothing ∈ tryindex(M, adj_index)
                dᵢ += 1
                break
            end

            push!(D[DIRECTIONS[dᵢ]], M[adj_index...])
            directional_shift = (abs.(directional_shift) .+ 1) .* sign.(directional_shift)
        end
    end

    return D
end

function part1(map::Matrix{T}) where {T <: Number}
    res= 0
    for i in CartesianIndices(map)
        A = global_adjacencies(map, i.I)
        res += any(isempty(A[d]) || all(map[i] > a for a in A[d]) for d in DIRECTIONS)
    end
    return res
end


# Part 2

function part2(map::Matrix{T}) where {T <: Number}
    scenic_scores = Vector{T}(undef, prod(size(map)))

    for (k, i) in enumerate(CartesianIndices(map))
        p = 1
        for d in DIRECTIONS
            A = global_adjacencies(map, i.I)
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
