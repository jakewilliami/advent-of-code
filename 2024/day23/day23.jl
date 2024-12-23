using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    L′ = [Symbol.(Tuple(split(l, '-'))) for l in L]
    @assert all(t -> length(t) == 2, L′)
    # L = get_integers.(L)
    return L′
end

const Connection = NTuple{2, Symbol}

using Graphs
# import Graphs.SimpleGraphs: SimpleGraph

function make_vertex_map(C::Vector{Connection})
    V = Dict{Symbol, Int}()
    i = 1
    for c in C
        for v in c
            !haskey(V, v) || continue
            V[v] = i
            i += 1
        end
    end
    V
end

function make_graph(C::Vector{Connection})
    V = make_vertex_map(C)

    # Create adjacency matrix
    N = length(V)
    M = falses(N, N)
    for (a, b) in C
        i, j = V[a], V[b]
        M[i, j] = M[j, i] = true
    end
    # println(M)

    # Create graph from adj matrix
    SimpleGraph(M)
end

function find_loops_of_three(G, V)
    loops = Set{Set{Symbol}}()

    for v in vertices(G)
        neighbours = neighbors(G, v)
        # println("v=$v, n=$neighbours")
        #=if length(neighbours) == 2
            a, b = neighbours
            push!(loops, v, a, b)
        end
        continue=#
        # println(neighbours)
        for i in 1:length(neighbours)
            for j in (i + 1):length(neighbours)
                a, b = neighbours[i], neighbours[j]
                # println("$a, $b, has_edge=$(has_edge(G, a, b))")
                has_edge(G, a, b) || continue
                @assert has_edge(G, v, a)
                @assert has_edge(G, v, b)
                # println("here")
                # must start with t
                t = (V[v], V[a], V[b])
                any(x -> startswith(String(x), 't'), t) || continue
                push!(loops, Set(t))
            end
        end
    end

    loops
end

function part1(data::Vector{Connection})
    G = make_graph(data)
    # println(G)
    V = Dict{Int, Symbol}(reverse(p) for p in make_vertex_map(data))
    return length(find_loops_of_three(G, V))
end

# pretty sure these are called cliques in graph theory
function find_largest_clique(G, V)
    largest_clique = Set{Symbol}()
    n = nv(G)

    function backtrack(current_clique, candidates)
        if length(current_clique) > length(largest_clique)
            largest_clique = Set(current_clique)
        end

        isempty(candidates) && return
        for v in candidates
            new_clique = push!(copy(current_clique), V[v])
            new_candidates = filter(u -> has_edge(G, v, u), candidates)
            backtrack(new_clique, new_candidates)
        end
    end

    for (i, v) in enumerate(vertices(G))
        println("$i/$(length(vertices(G)))")
        backtrack(Set((V[v],)), filter(u -> has_edge(G, v, u), vertices(G)))
    end

    return largest_clique
end

function password(V::Set{Symbol})
    join(sort(String.(V)), ',')
end

function part2(data::Vector{Connection})
    G = make_graph(data)
    V = Dict{Int, Symbol}(reverse(p) for p in make_vertex_map(data))
    return password(find_largest_clique(G, V))
end

function main()
    data = parse_input("data23.txt")
    # data = parse_input("data23.test.txt")

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution ==
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()
