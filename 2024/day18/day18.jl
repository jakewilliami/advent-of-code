# Very simple day today.  Had to start late because I was busy at 6, but did
# both parts in 20 minutes.  We are given a list of Cartesian indices that
# represent indices in memory that we are not allowed to touch.  We have to
# get from index (0, 0) to index (70, 70) without leaving the bounding box
# it creates.  In part 1, we have to do this after 1 KB has been corrupted.
# In part 2, we have to find the first byte at which the exit path has been
# blocked.  I did this with brute force and it runs in just over a second.
# I suppose it's a rest day, as it were, in preparation for the next ones...

using AdventOfCode.Multidimensional
using DataStructures


### Parse Input ###

const Index = CartesianIndex{2}

function parse_input(input_file::String)
    L = split.(strip.(readlines(input_file)), ',')
    L′ = Tuple{Int, Int}[Tuple(parse.(Int, l)) for l in L]
    return Index[Index(y, x) for (x, y) in L′]
end


### Part 1 ###

# Find path through max with N disallowed squares from
function find_path(data::Vector{Index}, N::Int)
    si, ei = 𝟘(2), CartesianIndex(70, 70)
    R = si:ei

    # Initialise disallowed set and BFS queue
    disallowed = Set{Index}(data[1:N])
    Q = Queue{Tuple{Index, Direction{2}, Int}}()
    S = Set{Index}()

    # Instantiate queue with the four directions
    for d in cardinal_directions(2)
        enqueue!(Q, (si, d, 0))
    end

    # Find shortest path using BFS
    while !isempty(Q)
        i, d, s = dequeue!(Q)

        # Return the number steps we have reached the end
        i == ei && return s

        # Memoise positions that have already been seen
        i ∈ S && continue
        push!(S, i)

        # Check adjacencies
        for d in cardinal_directions(2)
            j = i + d

            # Only allow if the next index is not "corrupted" (i.e., not
            # disallowed), and in the grid
            if j ∉ disallowed && j ∈ R
                enqueue!(Q, (j, d, s + 1))
            end
        end
    end
end

part1(data::Vector{Index}) = find_path(data, 1024)


### Part 2 ###

function part2(data::Vector{Index})
    # Orange jacket meme:
    # Top text: binary search
    # Bottom text: brute force
    N = 1024
    while N ≤ length(data)
        n = find_path(data, N)
        if isnothing(n)
            y, x = Tuple(data[N])
            return "$x,$y"
        end
        N += 1
    end
end


### Main ###

function main()
    data = parse_input("data18.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 320
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == "34,40"
    println("Part 2: $part2_solution")
end

main()
