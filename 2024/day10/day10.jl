# We are given a grid of integers.  Each integer, 1--9, represents an elevation.
# We start at any of the numbers 0, and move upwards by one step at a time.
#
# In part one, for each starting position, we must count the number of final
# nodes that it can lead to.  In part two, we had to count the total number of
# possible, unique paths to get to any of its final (leaf) nodes.
#
# I did okay, but not really okay compared to everyone else (I never used BFS
# enough to implement it off the top of my head when it comes to AoC).  I
# wasted a lot of time on part one as I misread the expected output, so I kept
# trying different solutions looking for a different answer even though I
# implemented it correctly the first time, so my time should have been much
# better.  That being said, in this trial and error, I accidentally implemented
# a solution for part two (unbeknownst to me), so once I read part two, I could
# undo until I had my previous solution.

using AdventOfCode.Parsing, AdventOfCode.Multidimensional
using DataStructures


### Part Input ###

parse_input(input_file::String) = readlines_into_int_matrix(input_file)

const Index = CartesianIndex{2}


### Part 1 ###

# Only allowed to move to the next square if it's a gradual increase
function elevation_allowed(curr::Int, next::Int)
    (next - curr) == 1 || return false
    return true
end

# Starting at index `s` (that is, the "trailhead"), count its score (i.e., its
# number of leaves [final nodes] after it branches off).  This is a BFS.
#
# This implementation was adapted from 2022, day 12.
function count_trailhead_score(data::Matrix{Int}, s::Index)
    Q, S, n = Queue{Index}(), Set{Index}(), 0
    enqueue!(Q, s)

    while !isempty(Q)
        i = dequeue!(Q)
        i ∈ S && continue
        push!(S, i)

        # If we have found a leaf (the end of the trail), we can increment
        # the trailhead's score
        if data[i] == 9
            n += 1
            continue
        end

        # Look for further paths in each cardinal/orthogonal direction
        for d in cardinal_directions(2)
            j = i + d
            hasindex(data, j) || continue

            # Only follow path if it's a gradual increase
            if elevation_allowed(data[i], data[j])
                enqueue!(Q, j)
            end
        end
    end

    return n
end

function part1(data)
    return sum(CartesianIndices(data)) do i
        data[i] == 0 || return 0
        count_trailhead_score(data, i)
    end
end


### Part 2 ###

# Determine the "rating" of the trailhead; that is, starting at index `s`, count
# the number of unique paths to get to a leaf node.  This is a BFS.
#
# Similar to part 1, but we also must keep track of the current path taken, so
# that we know.
function count_trailhead_rating(data::Matrix{Int}, s::Index)
    Q, n = Queue{Tuple{Index, Vector{Index}}}(), 0
    enqueue!(Q, (s, [s]))

    while !isempty(Q)
        i, p = dequeue!(Q)

        # If we have found a leaf (the end of the trail), we can increment
        # the trailhead's rating
        if data[i] == 9
            n += 1
            continue
        end

        # Look for further paths in each cardinal/orthogonal direction
        for d in cardinal_directions(2)
            j = i + d
            hasindex(data, j) || continue

            # Only follow path if it's a gradual increase and we haven't been
            # to this node before
            if elevation_allowed(data[i], data[j]) && j ∉ p
                # We must add this new node to our current path
                p′ = push!(deepcopy(p), j)
                enqueue!(Q, (j, p′))
            end
        end
    end

    return n
end

function part2(data)
    return sum(CartesianIndices(data)) do i
        data[i] == 0 || return 0
        count_trailhead_rating(data, i)
    end
end


### Main ###

function main()
    data = parse_input("data10.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 659
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 1463
    println("Part 2: $part2_solution")
end

main()
