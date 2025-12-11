# Description: what was the problem; how did I solve it; and (optionally)
# any thoughts on the problem or how I did.

# ]add https://github.com/jakewilliami/AdventOfCode.jl Statistics LinearAlgebra Combinatorics DataStructures StatsBase IntervalSets OrderedCollections MultidimensionalTools  # TODO: IterTools, ProgressMeter, BenchmarkTools, Memoization
# using AdventOfCode.Parsing, AdventOfCode.Multidimensional
using Memoization
# using BenchmarkTools
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections
# using MultidimensionalTools


### Parse Input ###

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    L = [(String(a), String.(split(b))) for (a, b) in split.(L, ": ")]
    return Dict{String, Vector{String}}(a => b for (a, b) in L)
    return L
    # L = get_integers.(L)
    return L
end


### Part 1 ###

# Each line gives the name of a device followed by a list of the devices to which its outputs are attached
function part1(data)
    count = 0

    Q = Queue{String}()
    enqueue!(Q, "you")

    while !isempty(Q)
        s = dequeue!(Q)

        if s == "out"
            count += 1
            continue
        end

        for s′ in data[s]
            enqueue!(Q, s′)
        end
    end

    return count
end


### Part 2 ###

function count_paths_with(data, start, goal, req1, req2)
    count = 0

    # queue holds (node, seen_req1::Bool, seen_req2::Bool)
    Q = Queue{Tuple{String,Bool,Bool}}()
    enqueue!(Q, (start, false, false))

    while !isempty(Q)
        (node, seen1, seen2) = dequeue!(Q)

        # update seen state
        seen1 |= (node == req1)
        seen2 |= (node == req2)

        # if we reached b AND visited both
        if node == goal
            count += seen1 && seen2
            continue
        end

        # continue exploring
        for nxt in data[node]
            enqueue!(Q, (nxt, seen1, seen2))
        end
    end

    return count
end

# "a topological order is a linear ordering of nodes where every edge u -> v goes from earlier in the order to later"
function topo_order(data)
    initial_state = Dict(n => 0 for n in keys(data))
    indeg = Accumulator{String, Int}(initial_state)
    for v in Iterators.flatten(values(data))
    # for (_, outs) in data
        # for v in outs
            inc!(indeg, v)
            # indeg[v] = get(indeg, v, 0) + 1
        # end
    end

    # println(indeg)
    # for (n, d) in indeg
        # println("$n $d")
        # break
    # end

    Q = Queue{String}()
    for (n, d) in indeg
        iszero(d) && enqueue!(Q, n)
    end

    order = String[]

    while !isempty(Q)
        u = dequeue!(Q)
        push!(order, u)
        for v in get(data, u, String[])
            dec!(indeg, v)
            # indeg[v] -= 1
            if iszero(indeg[v])
                enqueue!(Q, v)
            end
        end
    end

    return order
end

function count_paths_from(data, topo, src)
    # paths = Dict(n => 0 for n in keys(data))
    paths = Accumulator{String, Int}()
    # paths[src] = 1
    inc!(paths, src)

    # DP forward along topo order
    for u in topo
        for v in get(data, u, [])
            # paths[v] += get(paths, u, [])
            inc!(paths, v, paths[u])
        end
    end

    return paths
end

function count_paths_through(data, a, b, c, d)
    topo = topo_order(data)

    # Paths starting at a, c, d
    Pa = count_paths_from(data, topo, a)
    Pc = count_paths_from(data, topo, c)
    Pd = count_paths_from(data, topo, d)

    case1 = Pa[c] * Pc[d] * Pd[b]   # a → c → d → b
    case2 = Pa[d] * Pd[c] * Pc[b]   # a → d → c → b

    return case1 + case2
end


# https://github.com/jonathanpaulson/AdventOfCode/blob/826497f7/2025/11.py#L21-L31
@memoize function solve(s, data; dac=false, fft=false)
    s == "out" && return dac && fft
    sum(data[s]) do s′
        solve(
            s′,
            data,
            dac = dac || s′ == "dac",
            fft = fft || s′ == "fft",
        )
    end
end

function part2(data)
    # start: svr
    # stop: out
    # visit also: dac and fft
    # count_paths_with(data, "svr", "out", "dac", "fft")
    count_paths_through(data, "svr", "out", "dac", "fft")

end

function part22(data)
    solve("svr", data)
end
### Main ###

function main()
    data = parse_input("data11.txt")
    # data = parse_input("data11.test.txt")
    # data = parse_input("data11.test2.txt")
    # println(data)

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 494
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 296006754704850
    println("Part 2: $part2_solution")

    # @show @benchmark part2($data)
    # @benchmark part22($data)
end

main()
