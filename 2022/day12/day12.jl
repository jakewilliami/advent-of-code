using AdventOfCode.Multidimensional

using Graphs


parse_input(f::String) = reduce(vcat, permutedims(collect(s)) for s in readlines(f))


function is_viable_elevation(c1::Char, c2::Char)
    if c1 == 'S'
        c1 = 'a'
    end
    if c2 == 'E'
        c2 = 'z'
    end
    return (c2 - c1) <= 1
end


function mk_graph(data)
    G = SimpleDiGraph(prod(size(data)))
    I = LinearIndices(data)

    for i in CartesianIndices(data)
        dirs = cardinal_directions(2)
        if i == CartesianIndex(38, 7)
            println([i + d for d in dirs if hasindex(data, i + d) && is_viable_elevation(data[i], data[i + d])])
        end
        for d in dirs
            j = i + d
            hasindex(data, j) || continue
            if is_viable_elevation(data[i], data[j])
                add_edge!(G, I[i], I[j])
            end
        end
    end

    return G
end


function part1(data)
    I = LinearIndices(data)
    start_i = findfirst(i -> data[i] == 'S', eachindex(data))
    end_i = findfirst(i -> data[i] == 'E', eachindex(data))

    G = mk_graph(data)

    sp = a_star(G, start_i, end_i)
    return length(sp)
end


function part2(data)
    start_is = findall(i -> data[i] == 'S' || data[i] == 'a', eachindex(data))
    println("NAS: ", length(start_is))
    end_i = findfirst(i -> data[i] == 'E', eachindex(data))

    G = mk_graph(data)


    splen = prod(size(data))
    for start_i in start_is
        y = yen_k_shortest_paths(G, start_i, end_i).paths
        isempty(y) && continue
        sp = only(y)
        if length(sp) < splen
            splen = length(sp)
        end
        if length(sp) < 10
            println(findfirst(==(start_i), LinearIndices(data)), " <- ", data[start_i], " -...-> ", findfirst(==(end_i), LinearIndices(data)))
        end
    end

    return splen - 1
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
