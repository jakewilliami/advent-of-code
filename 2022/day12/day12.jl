using AdventOfCode.Multidimensional

using Graphs
import Graphs: SimpleGraphs.SimpleEdge


parse_input(f::String) = reduce(vcat, permutedims(collect(s)) for s in readlines(f))


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


function part2(data::Matrix{Char})
    start_is = findall(i -> data[i] ∈ ('S', 'a'), eachindex(data))
    end_i = findfirst(i -> data[i] == 'E', eachindex(data))

    G = mk_graph(data)

    paths = Vector{SimpleEdge{Int}}[a_star(G, start_i, end_i) for start_i in start_is]
    filter!(!isempty, paths)
    return minimum(length(p) for p in paths)
end


function main()
    data = parse_input("data12.txt")

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
