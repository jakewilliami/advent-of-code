# We are given a matrix of characters.  The characters represent a
# plane of rocks.  '.' characters are empty space; '#' characters are
# square rocks that are heavy and can't move; and (most interestingly)
# 'O' characters are circular rocks that roll around.  The platform that
# the rocks are on will tilt and the circular rocks will move unless
# they are stopped by square rocks or the edge of the platform
#
# Part 1 required simulating the rocks moving north as far as they can,
# and then calculating a score based on the end state.  I'm not sure
# if there is a clever solution for this so I simply simulated it within
# the matrix (in-place, which is why I have to copy the input data).
#
# Part 2 was similar to part 1, where we had to simulate rocks sliding
# in a certain direction.  I figured the direction would be dynamic so I
# implemented it dynamically in part 1.  In this part of the problem, we
# have to simulate the rocks sliding in all cardinal directions n times.
# The complication arises from the fact that n is 1 billion.  The solution
# here is to find a repeating pattern so that we can reduce the number of
# iterations we are required to simulate.

using AdventOfCode.Parsing, AdventOfCode.Multidimensional

function parse_input(input_file::String)
    M = readlines_into_char_matrix(input_file)
    @assert all(c -> c in ("O#."), M)
    return M
end


### Part 1 ###

const Direction = CartesianIndex{2}

# Simulate circular rocks ('O') sliding in direction d
# Returns a boolean to indicate whether rocks were moved or not
function _simulate_rocks_sliding!(M::Matrix{Char}, d::Direction)
    moved = false

    for i in CartesianIndices(M)
        c1, c2 = M[i], tryindex(M, i + d)

        # We only move circular rocks
        c1 == 'O' || continue

        # Can't move in a direction that doesn't exist
        isnothing(c2) && continue

        # If the space at direction d from the current index is
        # empty, the rock can move there
        if c2 == '.'
            M[i] = '.'
            M[i + d] = c1
            moved = true
        end
    end

    return moved
end

# Simulate circular rocks sliding in direction d until they're in a state
# where they can't slide any further in that direction
function simulate_rocks_sliding!(M::Matrix{Char}, d::Direction)
    while true _simulate_rocks_sliding!(M, d) || break end
    return M
end

# Calculate the score of the current plane of rocks
function score_plane(M::Matrix{Char})
    res = 0

    for (i, row) in enumerate(eachrow(M))
        j = size(M, 1) - i + 1
        res += j * sum(c == 'O' for c in row)
    end

    return res
end

# Simulate rocks sliding north and calculate the score
function part1(M::Matrix{Char})
    simulate_rocks_sliding!(M, INDEX_ABOVE)
    return score_plane(M)
end


### Part 2 ###

# Simulate rocks sliding completely in all cardinal directions once
function simulate_rocks_sliding_cycle!(M::Matrix{Char})
    for d in (INDEX_ABOVE, INDEX_LEFT, INDEX_BELOW, INDEX_RIGHT)
        simulate_rocks_sliding!(M, d)
    end
    return M
end

# Simulate rocks sliding completely in all cardinal directions N times
function simulate_rocks_sliding_cycle!(M::Matrix{Char}, n::Int)
    seen = UInt[hash(M)]
    si = ei = 0

    # As `n' is possibly very large, the idea is to keep track of the
    # states we've seen after each cycle of sliding rocks.  The hope is
    # that we find a cycle in less than n iterations, so then we can
    # just simulate the remaining iterations up to n
    for i in 1:n
        simulate_rocks_sliding_cycle!(M)
        h = hash(M)

        if h in seen
            si = findfirst(==(h), seen) - 1
            ei = i
            break
        else
            push!(seen, h)
        end
    end

    # If we have seen n states then we have our answer without finding
    # any cycles
    length(seen) >= n && return M

    # If we got here, we found a cycle.  Find its length and calculate
    # the number of cycles that remain to reach `n'
    cycle_length = ei - si
    remaining_cycles = n - si

    # Simulate the cycle of sliding rocks for the remaining iterations
    for i in 1:mod(remaining_cycles, cycle_length)
        simulate_rocks_sliding_cycle!(M)
    end

    return M
end

# Simulate rocks sliding completely in all cardinal directions 1 billion times,
# and then calculate its final score
function part2(M::Matrix{Char})
    simulate_rocks_sliding_cycle!(M, 1_000_000_000)
    return score_plane(M)
end

function main()
    data = parse_input("data14.txt")

    # Part 1
    part1_solution = part1(copy(data))
    @assert part1_solution == 109665
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(copy(data))
    @assert part2_solution == 96061
    println("Part 2: $part2_solution")
end

main()
