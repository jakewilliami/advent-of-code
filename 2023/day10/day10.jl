# We were given a grid of characters that made up a complex pipe system,
# and, given a starting point, we had to traverse the system of pipes to
# find a cycle.
#
# Part 1 was straight forward and got us to find the farthest point from
# the start of the cycle.  I am actually quite chuffed with the solution
# to this, as I've historically struggled with recursion due to lack of
# practice, so to write the `traverse_pipe_system' with no hassle was nice.
#
# Part 2 was naturally the tricky one.  We have to now count all of the
# parts of the system that are enclosed by the pipe cycle.  I was immediately
# reminded of the lava problem from last year (day 18), and tried implementing
# a flood fill algorithm to solve the problem.  However, it wasn't quite
# working.  To get flood fill working, you would need to increase resolution
# of the (which I didn't think of at the time):
#   https://www.reddit.com/r/adventofcode/comments/18evyu9/comment/kcqgnoy/
#
# I also tried to take "inspiration" from some "is point in path" algorithms:
#   https://github.com/matplotlib/matplotlib/blob/v3.8.2/lib/matplotlib/path.py#L502
#   https://github.com/matplotlib/matplotlib/blob/v3.8.2/src/_path.h#L105
#
# But I found this convoluted.  Finally I realised (with some research
# into other solutions) that a "parity" solution here is perfect.
# Essentially, any space that had an odd number parity was enclosed in the
# cycle:
#   https://www.reddit.com/r/adventofcode/comments/18evyu9/comment/kcqgo61/


using AdventOfCode.Parsing, AdventOfCode.Multidimensional

parse_input(input_file::String) = readlines_into_char_matrix(input_file)


### Part 1 ###

const Index = CartesianIndex{2}

#=
Information on each pipe type was provided as follows
  | is a vertical pipe connecting north and south;
  - is a horizontal pipe connecting east and west;
  L is a 90-degree bend connecting north and east;
  J is a 90-degree bend connecting north and west;
  7 is a 90-degree bend connecting south and west;
  F is a 90-degree bend connecting south and east;
  . is ground; there is no pipe in this tile;
  S is the starting position of the animal; there is
    a pipe on this tile, but your sketch doesn't show
    what shape the pipe has.
=#

const PIPE_DIRS = Dict{Char, Set{Index}}(
    '|' => Set{Index}((INDEX_ABOVE, INDEX_BELOW)),
    '-' => Set{Index}((INDEX_LEFT, INDEX_RIGHT)),
    'L' => Set{Index}((INDEX_ABOVE, INDEX_RIGHT)),
    'J' => Set{Index}((INDEX_ABOVE, INDEX_LEFT)),
    '7' => Set{Index}((INDEX_BELOW, INDEX_LEFT)),
    'F' => Set{Index}((INDEX_BELOW, INDEX_RIGHT)),
    '.' => Set{Index}(),
)
const DIRS_TO_PIPE = Dict{Set{Index}, Char}(reverse(p) for p in PIPE_DIRS)

get_pipe_directions(c::Char) = PIPE_DIRS[c]
get_pipe_from_directions(ds::Set{Index}) = DIRS_TO_PIPE[ds]

# Infer pipe at starting position based on its surroundings
function infer_pipe_type(i::Index, data::Matrix{Char})
    I = Set{Index}()

    # For each cardinally adjacent element around index `i', look
    # at whether it connects to element at the present index
    for d in cardinal_directions(2)
        j = i + d
        hasindex(data, j) || continue
        t = get_pipe_directions(data[j])
        d′ = opposite_direction(d)
        d′ ∈ t && push!(I, d′)
    end

    # Now that we have the pipe's surrounding connections, we can
    # infer the pipe's type
    return get_pipe_from_directions(I)
end

# (Recursively) traverse the pipe system and construct a path
function traverse_pipe_system(i::Index, data::Matrix{Char}; path::Vector{Index} = Index[])
    hasindex(data, i) || return path
    push!(path, i)

    for d in get_pipe_directions(data[i])
        j = i + d
        j ∉ path && traverse_pipe_system(j, data, path = path)
    end

    return path
end

# Find the starting point (denoted with the character S) and mark return its
# index, meanwhile inferring the type that the pipe at the start should be
function mark_starting_point!(data::Matrix{Char})
    si = findfirst(==('S'), data)
    data[si] = infer_pipe_type(si, data)
    return si
end

# Mark the starting point in the system and walk from there till the path
# is understood
function get_cycle!(data::Matrix{Char})
    si = mark_starting_point!(data)
    path = traverse_pipe_system(si, data)
    return path
end

# Get the path of the system (from the starting point) and find the number
# of steps to get to the furthest position from the pipe (if the length of
# the path is |P|, then the furthest position in the path is simply ⌊|P|⌋
# points away from the starting position).
function part1(data::Matrix{Char})
    path = get_cycle!(data)
    return fld(length(path), 2)
end


### Part 2 ###

# Count every enclosed non-pipe
function part2(data::Matrix{Char})
    path = get_cycle!(data)
    res, is_enclosed = 0, false

    # If an odd number of vertical tiles have been seen in any given cell,
    # then any ground (`.') tiles are enclosed by pipes.  Refs:
    #   https://www.reddit.com/r/adventofcode/comments/18evyu9/comment/kcqgo61/
    #   https://www.reddit.com/r/adventofcode/comments/18evyu9/comment/kcqnzmq/
    for (ri, row) in enumerate(eachrow(data))
        is_enclosed = false
        for (ci, c) in enumerate(row)
            if CartesianIndex(ri, ci) ∈ path
                # `|' is a vertical pipe, however it is simple.  A "complex"
                # vertical pipe must have exactly one of `F` and `7'.  FJ
                # and L7 are complex pipes, but F7 and LJ are both U-bends
                # and should *not* be counted

                # Can equivalently check for `c ∈ "|LJ"`
                c ∈ "|F7" && (is_enclosed = !is_enclosed)
            else
                res += is_enclosed
            end
        end
    end

    return res
end

function main()
    data = parse_input("data10.txt")

    # Part 1
    part1_solution = part1(copy(data))
    @assert part1_solution == 6897
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(copy(data))
    @assert part2_solution == 367
    println("Part 2: $part2_solution")
end

main()
