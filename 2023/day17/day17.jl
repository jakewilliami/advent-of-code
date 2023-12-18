# Today's problem requires us to parse a matrix of integers.  It is a path-finding problem.
#
# In the first part, we have to make our way from the top left to the bottom right of the
# matrix, with the lowest cost (each node entered increments the cost).  However, for some
# added complexity, we can only go in the same direction 3 times before having to turn.  And
# we can't turn backwards; only forward, left, or right.
#
# Part 2 was a very similar problem but ramped up requirements: we MUST travel in the same
# direction AT LEAST 4 times, and AT MOST 10 times.
#
# It was an interesting problem today.  I started implementing the solution using BFS, which
# I have grown to understand somewhat since last year's Aoc.  However, I believe BFS only
# works when each edge in the graph has equal weighting (which this does not).  As such, after
# a little bit of research, I realised we need to use a "priority queue" (equivalently, `heapq'
# in Python, but *not* equivalent to DataStructures.jl's `BinaryMinHeap').  It was interesting
# to use such a data structure, as I had never used it before, however it was difficult to
# debug the problem.
#
# The path-finding code between part 1 and 2 are identical, but the function allows a predicate
# to determine whether the next location in the path should be skipped or not (based on the
# problems requirements).


using AdventOfCode.Parsing, AdventOfCode.Multidimensional
using DataStructures

parse_input(input_file::String) = readlines_into_int_matrix(input_file)


### Part 1 ###

const Direction = CartesianIndex{2}

# Only left/right/forward turns are allowed
allowed_turns(d::Direction) = (rotl90(d), rotr90(d), d)

# A state to keep track of when path-finding
struct PathState
    pos::CartesianIndex{2}
    dir::CartesianIndex{2}
    moves_since_last_turn::Int
end

const INVALID_PATH_STATE = PathState(origin(2), origin(2), 0)
const DEFAULT_PATH_STATE = PathState(CartesianIndex{2}(), CartesianIndex{2}(), 1)

# Increment moves since last turn.  If the new direction is distinct from the previous,
# this will reset to 1
function _inc_moves_since_last_turn(path_state::PathState, new_dir::Direction)
    moves_since_last_turn = 1
    if path_state.dir == new_dir
        moves_since_last_turn = path_state.moves_since_last_turn + 1
    end
    return moves_since_last_turn
end

# Main logic for path finding.  Allows a function to be given
function _find_path(data::Matrix{Int}, end_i::CartesianIndex{2}; skip_fn = function(_...) false, DEFAULT_PATH_STATE end)
    # Must use a priority queue to find the minimum cumulative heat-loss
    Q = PriorityQueue{PathState, Int}()
    S = Set{PathState}()

    # Initialise the search queue with the two starting directions from the start position
    for d in (INDEX_RIGHT, INDEX_BELOW)
        i = CartesianIndex{2}() + d
        enqueue!(Q, PathState(i, d, 1), data[i])
    end


    # Keep finding paths while we have avenues to explore
    while !isempty(Q)
        path_state, v = dequeue_pair!(Q)

        # Memoise the path state
        path_state ∈ S && continue
        push!(S, path_state)

        # Stop if we have reached the end of the path
        path_state.pos == end_i && return v

        # Explore other possible directions
        for new_dir in allowed_turns(path_state.dir)
            # Conditionally skip this direction/new index
            skip_this_state, new_path_state = skip_fn(path_state, new_dir, Q)
            skip_this_state && continue

            # If we got here, queue this new direction/index
            enqueue!(Q, new_path_state, v + data[new_path_state.pos])
        end
    end
end

function part1(data::Matrix{Int})
    function _skip(path_state::PathState, dir::Direction, Q::PriorityQueue{PathState, Int})
        invalid = true, INVALID_PATH_STATE
        moves_since_last_turn = _inc_moves_since_last_turn(path_state, dir)

        # We can only move 3 times in the same direction
        moves_since_last_turn <= 3 || return invalid

        # Do not go there if the index doesn't exist
        j = path_state.pos + dir
        hasindex(data, j) || return invalid

        # If the new path state is already in the queue, we need not go there
        new_path_state = PathState(j, dir, moves_since_last_turn)
        new_path_state ∈ keys(Q) && return invalid

        # If we get here, the new path state is valid
        return false, new_path_state
    end

    return _find_path(data, last(CartesianIndices(data)), skip_fn = _skip)
end


### Part 2 ###

function part2(data::Matrix{Int})
    end_i = last(CartesianIndices(data))

    function _skip(path_state::PathState, dir::Direction, Q::PriorityQueue{PathState, Int})
        invalid = true, INVALID_PATH_STATE
        moves_since_last_turn = _inc_moves_since_last_turn(path_state, dir)

        # We can only move 10 times in the same direction
        # TODO
        (moves_since_last_turn <= 10 &&
            (path_state.dir == dir ||
            path_state.moves_since_last_turn >= 4)) ||
        return invalid

        # Do not go there if the index doesn't exist
        j = path_state.pos + dir
        hasindex(data, j) || return invalid

        # "even before it can stop at the end"
        (j == end_i && moves_since_last_turn < 4) && return invalid

        # If the new path state is already in the queue, we need not go there
        new_path_state = PathState(j, dir, moves_since_last_turn)
        new_path_state ∈ keys(Q) && return invalid

        # If we get here, the new path state is valid
        return false, new_path_state
    end

    return _find_path(data, end_i, skip_fn = _skip)
end

function main()
    data = parse_input("data17.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 771
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 930
    println("Part 2: $part2_solution")
end

main()
