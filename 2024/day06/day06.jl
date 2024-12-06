# We were given a grid of characters, where dots are empty space and octothorpes
# are obstacles.  There is one other character, the caret, which represents a
# guard looking upwards.  The guard walks in a straight line and if they encounter
# an obstacle, they turn 90° to the right and keep going.
#
# In part one, we just had to count the number of unique positions the guard goes
# to in her rounds.
#
# In part two, the goal was to make the guard go in loops.  We could place a single
# obstacle anywhere on the grid, except where the guard was, and count the number
# of paths we could make her loop.
#
# I did this while Max, my brother, was driving us to Hawke's Bay, so I feel as
# though I could have done part one much faster than I did due to difficulty typing.
# I also found part two very difficult to do and I took a while to do it because I
# had so many edge cases.  For a large part of the time I spent solving it, I had
# working test data but failing real data.
#
# The main bug I had was eagerly incrementing the guard's position by the direction,
# which failed to account for whether the (potentially newly-rotated direction) would
# hit an obstacle.  I ended up walking the guard over obstacles.
#
# I also note that to check whether a loop has been found, checking the guard's
# position is not enough; you have to check the direction as well, because going
# through a position that the guard has already been to in a different direction means
# they are not really looping.  And loops do not have to be squares; they can have
# more than four corners (nodes)...  Lots of edge cases!

using AdventOfCode.Parsing, AdventOfCode.Multidimensional


### Parse Input ###

parse_input(input_file::String) =
    readlines_into_char_matrix(input_file)

function find_guard(data::Matrix{Char})
    for i in CartesianIndices(data)
        if data[i] == '^'
            return i
        end
    end
end


### Part 1 ###

function part1(data::Matrix{Char})
    d = INDEX_UP
    i = find_guard(data)
    r = 0
    seen = Set{CartesianIndex{2}}((i,))

    # This might never stop if a loop is found, but the data are designed
    # such that there shouldn't be a loop with these starting features
    # (position and direction)
    while true
        c = tryindex(data, i + d)
        isnothing(c) && return length(seen)
        d = (c == '#' ? rotr90 : identity)(d)
        data[i + d] != '#' && (i += d)
        push!(seen, i)
    end
end


### Part 2 ###

possible_obstructions(data::Matrix{Char}) =
    Set{CartesianIndex{2}}(i for i in CartesianIndices(data) if data[i] ∉ ('#', '^'))

function modification_adds_loop(
    data::Matrix{Char},
    start_i::CartesianIndex{2},
    obstruction_i::CartesianIndex{2},
)
    i, d = start_i, INDEX_UP
    seen = Set{NTuple{2, CartesianIndex{2}}}()

    while true
        c = tryindex(data, i + d)
        isnothing(c) && return false

        if c == '#' || i + d == obstruction_i
            d = rotr90(d)
        end

        (i, d) ∈ seen && return true
        push!(seen, (i, d))

        # Only increment the index if the next position is not an obstruction
        # This test case really helped me:
        # <reddit.com/r/adventofcode/comments/1h7v3lw>
        if !(data[i + d] == '#' || i + d == obstruction_i)
            i += d
        end
    end
end

function part2(data::Matrix{Char})
    j = find_guard(data)
    sum(possible_obstructions(data)) do i
        modification_adds_loop(data, j, i)
    end
end

function main()
    data = parse_input("data06.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 4656
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 1575
    println("Part 2: $part2_solution")
end

main()
