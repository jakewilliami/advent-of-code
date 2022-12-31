# Today's problem gave us a grid of characters (which I parsed into a matrix), each
# character representing a height in a hill.  There were also the characters S (the starting
# character) and E (the goal position).
#
# Part 1 required us to find the optimal path from S to E with a constraint: you can only
# move to a position orthogonally adjacent if it is at most 1 elevation greater.  I solved
# this by constructing a graph of nodes (using Graphs.jl), with nodes between edges if the
# elevation allowed it, and performing an A* search on the graph from the start node to the
# end node.
#
# Part 2 was similar, except this time we had to find the optimal path from _any_ position
# with elevation 'a' (S also has elevation 'a').  I did the trivial thing: perform part 1 on
# all of the new starting positions.
#
# I guess you could say I got a little intimidated by this problem.  I did not study
# computer science, so this was the first problem this year that I did not exactly know how
#to solve.  I quickly reduced it to a path finding/graph theory problem, but I haven't
# really had experience solving such problems programmatically.  I chose A* because I knew
# it would work.  However, after I had finished this, I was looking at others' solutions,
# and realised that a simple breadth-frist search (BFS) would work.  My BFS solution is
# implemented below.  Overall, this has been really good experience for me to use more graph
# theory in programming.


using AdventOfCode.Multidimensional

using DataStructures
using Graphs
import Graphs: SimpleGraphs.SimpleEdge


### Part 1

function elevation_allowed(c1::Char, c2::Char)
    c1 == 'S' && (c1 = 'a')
    c2 == 'E' && (c2 = 'z')
    return (c2 - c1) <= 1
end


function mk_graph(data::Matrix{Char})
    G = SimpleDiGraph(prod(size(data)))
    I = LinearIndices(data)
    directions = cardinal_directions(2)

    # For each cartesian index
    for i in CartesianIndices(data)
        # Find adjacent nodes
        for d in directions
            j = i + d
            # Skip if index doesn't exist
            hasindex(data, j) || continue

            # If the next step has an allowed elevation compared to the current index
            if elevation_allowed(data[i], data[j])
                # We have to add the linear index as the graph is made up of integers
                add_edge!(G, I[i], I[j])
            end
        end
    end

    return G
end


function part1(data::Matrix{Char})
    start_i = findfirst(i -> data[i] == 'S', eachindex(data))
    end_i = findfirst(i -> data[i] == 'E', eachindex(data))

    G = mk_graph(data)

    sp = a_star(G, start_i, end_i)
    return length(sp)
end


### Part 2

function part2(data::Matrix{Char})
    start_is = findall(i -> data[i] ∈ ('S', 'a'), eachindex(data))
    end_i = findfirst(i -> data[i] == 'E', eachindex(data))

    G = mk_graph(data)

    paths = Vector{SimpleEdge{Int}}[a_star(G, start_i, end_i) for start_i in start_is]
    filter!(!isempty, paths)
    return minimum(length(p) for p in paths)
end


### Main

function main()
    data = readlines_into_char_matrix("data12.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 456
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 454
    println("Part 2: $part2_solution")
end

main()


### BFS

#=
Using BFS, rather than constructing a graph and using A*.

I first tried implementing this, but couldn't figure it out in any
reasonable amount of time.  (I know it's trivial to comp. sci. students!)
I implemented this after seeing a Python solution using this logic.

This BFS solution performs considerably faster.

julia> @btime part1($data);
  2.794 ms (22593 allocations: 1.86 MiB)

julia> @btime part1_bfs($data);
  785.353 μs (88 allocations: 846.50 KiB)

julia> @btime part2($data);
  392.626 ms (106554 allocations: 198.35 MiB)

julia> @btime part2_bfs($data);
  804.159 μs (92 allocations: 894.66 KiB
=#


function _bfs_core(data::Matrix{Char}, Q::Queue{Tuple{CartesianIndex{2}, Int}}, S::Set{CartesianIndex{2}})
    directions = cardinal_directions(2)
    while !isempty(Q)
        i, v = dequeue!(Q)
        i ∈ S && continue
        push!(S, i)
        if data[i] == 'E'
            return v
        end
        for d in directions
            j = i + d
            hasindex(data, j) || continue
            if elevation_allowed(data[i], data[j])
                enqueue!(Q, (j, v + 1))
            end
        end
    end
end


function part1_bfs(data::Matrix{Char})
    Q = Queue{Tuple{CartesianIndex{2}, Int}}()
    start_i = findfirst(i -> data[i] == 'S', CartesianIndices(data))
    enqueue!(Q, (start_i, 0))
    S = Set{CartesianIndex{2}}()

    return _bfs_core(data, Q, S)
end


function part2_bfs(data::Matrix{Char})
    Q = Queue{Tuple{CartesianIndex{2}, Int}}()
    for i in CartesianIndices(data)
        if data[i] ∈ ('S', 'a')
            enqueue!(Q, (i, 0))
        end
    end
    S = Set{CartesianIndex{2}}()

    return _bfs_core(data, Q, S)
end


function main_bfs()
    data = readlines_into_char_matrix("data12.txt")

    # Part 1
    part1_solution_bfs = part1_bfs(data)
    @assert part1_solution_bfs == 456

    # Part 2
    part2_solution_bfs = part2_bfs(data)
    @assert part2_solution_bfs == 454
end


main_bfs()
