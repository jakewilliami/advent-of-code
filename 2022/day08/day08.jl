# In today's problem, we were given a map; a grid of integers each representing the height
# of a tree within a forest.  This was easy to parse reusing some code I wrote in 2020 (now
# in my common AdventOfCode.jl package).
#
# Part 1 asked us to count the number of trees visible from outside of the grid (which is to
# say, how many trees have a direct line across which the trees are less than the height of
# the tree).
#
# The second part gave us a calculation of a "scenic score" (taking into account the first
# tree in each direction that blocks our line of sight), and find the tree with the highest
# scenic score.
#
# This was pretty straight-forward, as I had some nice functions that I could utilise from
# previous code, and as ever, Julia's multidimensional programming is very straight forward.


using AdventOfCode.Multidimensional


### Part 1

const DIRECTIONS = cardinal_directions(2)

# Increment an index further away from the origin, e.g., (1, -3) -> (2, -4)
_move_further_from_origin(i::CartesianIndex{N}) where {N} = i + direction(i)

# Construct a map of lists of values in the given matrix at each direction away from a specified index
function global_adjacencies(M::Matrix{T}, i::CartesianIndex{N}, direction_modifiers) where {T, N}
    D = Dict{CartesianIndex, Vector{T}}(s => T[] for s in direction_modifiers)

    dᵢ = 1
    while dᵢ <= length(DIRECTIONS)
        directional_shift = DIRECTIONS[dᵢ]
        j = i
        while true
            j += directional_shift

            v = tryindex(M, j)
            if isnothing(v)
                dᵢ += 1
                break
            end

            push!(D[DIRECTIONS[dᵢ]], v)
        end
    end

    return D
end

function part1(map::Matrix{T}) where {T <: Number}
    res= 0
    for i in CartesianIndices(map)
        A = global_adjacencies(map, i, DIRECTIONS)
        # Increment result if tree has a direct path in any cartesian direction
        res += any(isempty(A[d]) || all(map[i] > a for a in A[d]) for d in DIRECTIONS)
    end
    return res
end


### Part 2

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


### Main

function main()
    data = readlines_into_int_matrix("data08.txt")

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
