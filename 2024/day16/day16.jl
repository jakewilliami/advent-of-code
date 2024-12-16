# We were given a grid with a start and and end.  We had to find our way
# through a maze that had walls in it, and each action we could take would
# increase or decrease our score.  In part 1 we had to find the best score
# we could make to get through the maze, and in part two, we had to find
# all positions in the paths that gave us this score.
#
# While the problem statement is not so complicated, the problem was deceiv-
# ingly difficult for me.  I ended up implementing a simple BFS in 10 minutes
# *and* getting the right answer for *both* test inputs.  "Easy," I thought...
# It was wrong for my puzzle input.
#
# I realised that my BFS was greedy in a sense, and that I needed to store
# the best possible avenues on the top of the stack when searching through
# the grid.  I don't know exactly what this is; is it Dijkstra's?  I ended up
# looking at some others' code, which helped a lot.  I discovered a binary
# heap structure which is like a stack that gives you the "best" at the top,
# based on some ordering.  In part two, I used a clever trick (not my own
# design) of storing the best possible score from the start at each index
# in the grid.  Overall fun and interesting and I learned, but a little
# disapppointed that I couldn't immediately solve it without some hints...

using AdventOfCode.Parsing, AdventOfCode.Multidimensional
using DataStructures


### Parse Input ###

const Index = CartesianIndex{2}

parse_input(input_file::String) =
    readlines_into_char_matrix(input_file)


### Part 1 ###

function find_start(M)
    for i in CartesianIndices(M)
        if M[i] == 'S'
            return i
        end
    end
end

# Binary heap idea from:
# <https://github.com/jonathanpaulson/AdventOfCode/blob/46c09b4d/2024/16.py>
#
# I knew I needed a data structure that stored better paths on top (as BFS
# was greedy), but I didn't know what it was called as I don't recall ever
# using one.
function part1(M)
    # Store and sort by score at the end of the state tuple
    Q = MutableBinaryHeap{Tuple{Index, Direction{2}, Int}}(Base.By(last))
    push!(Q, (find_start(M), INDEX_EAST, 0))
    S = Set{Tuple{Index, Direction{2}}}()
    best = typemax(Int)

    while !isempty(Q)
        i, d, s = pop!(Q)

        if M[i] == 'E' && s < best
            # If we've reached the end of the maze and out final score is
            # better than any we've previously found, update the best known
            # score
            best = s
        end

        (i, d) ∈ S && continue
        push!(S, (i, d))

        # We have three options:
        #   1. Move forward at the cost of 1, as long as it's not into a wall;
        #   2. Rotate 90 degrees clockwise at the cost of 1000; and
        #   3. Rotate 90 degrees anticlockwise at the cost of 1000.
        j = i + d
        if hasindex(M, j) && M[j] != '#'
            push!(Q, (j, d, s + 1))
        end
        push!(Q, (i, rotr90(d), s + 1000))
        push!(Q, (i, rotl90(d), s + 1000))
    end

    return best
end


### Part 2 ###

# The "seen" matrix idea comes from:
# <https://github.com/michel-kraemer/adventofcode-rust/blob/0300ade9/2024/day16/src/main.rs>
# <https://www.reddit.com/r/adventofcode/comments/1hfboft/comment/m2auven>
#
# Which keeps track of the best score at each position in the grid.
function part2(M)
    # Just like we did in part 1, except we need to keep track of the path as well
    Q = MutableBinaryHeap{Tuple{Index, Direction{2}, Vector{Index}, Int}}(Base.By(last))
    push!(Q, (find_start(M), INDEX_EAST, [], 0))
    S = fill(typemax(Int) - 1000, size(M))
    best = typemax(Int)

    # Keep track of all the best paths
    BP = Set{Index}()

    while !isempty(Q)
        i, d, P, s = pop!(Q)

        if M[i] == 'E' && s ≤ best
            best = s

            # We have reached the end of the maze, and it's better than
            # or equal to our best score.  Update the set of best points
            # to sit in the maze.
            union!(BP, P)
        end

        # Iterate over the options we have
        for (d′, m) in ((d, 1), (rotr90(d), 1000), (rotl90(d), 1000))
            j = i + d′
            s′ = s + m

            prev_dy, prev_dx = Tuple(d)
            dy, dx = Tuple(d′)
            if hasindex(M, j) && M[j] != '#' &&
                #  we might have stepped on a path where we were just about to turn,
                # so continue and see how it goes
                s′ ≤ (S[j] + 1000)

                S[j] = s′
                push!(Q, (j, d′, push!(deepcopy(P), j), s′))
            end
        end
    end

    # Return the number of best spots to sit, including the start
    return length(BP) + 1
end


### Main ###

function main()
    data = parse_input("data16.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 89460
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 504
    println("Part 2: $part2_solution")
end

main()
