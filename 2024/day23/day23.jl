# Another nice problem today.  We were given a list of connections between pairs
# of computers.  We can simply construct this into an undirected graph using a
# popular graph theory library and find the answer from that.
#
# In part 1, we had to find how many groups of three computers are each connected
# to each other.  This is simple enough with a naïve algorithm, brute forcing all
# groups of three.  (As per the problem, these trianges would only count if at least
# one computer in the group started with the letter t.)
#
# In part 2, we had to find a similar subgroup of computers that are all connected
# to one another (these are called cliques in graph theory), but we had to find the
# *largest* clique.  I used a recursive algorithm that took 5 and a half hours to
# run, but it gave me the right answer.

using Graphs


### Parse Input ###

const Connection = NTuple{2, Symbol}

function parse_input(input_file::String)
    L = Tuple.(split.(strip.(readlines(input_file)), '-'))
    L′ = Connection[Symbol.((a, b)) for (a, b) in L]
    return L′
end


### Part 1 ###

# Graphs.jl only supports graphs whose vertices are integers.  To account
# for this and know what the findings of graph traversal means, we need to
# know how the computers map to vertices
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
    return V
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

    # Create graph from adj matrix
    return SimpleGraph(M)
end

function find_loops_of_three(G, V)
    loops = Set{Set{Symbol}}()

    for v in vertices(G)
        neighbours = neighbors(G, v)

        # We have a clique of 3 if we find two neighbours of v who are
        # also connected
        for i in 1:length(neighbours)
            for j in (i + 1):length(neighbours)
                a, b = neighbours[i], neighbours[j]
                has_edge(G, a, b) || continue

                # Must start with t
                t = (V[v], V[a], V[b])
                any(x -> startswith(String(x), 't'), t) || continue
                push!(loops, Set(t))
            end
        end
    end

    return loops
end

function part1(data::Vector{Connection})
    G = make_graph(data)
    V = Dict{Int, Symbol}(reverse(p) for p in make_vertex_map(data))
    return length(find_loops_of_three(G, V))
end


### Part 2 ###

password(V::Set{Symbol}) = join(sort(String.(V)), ',')

function part2(data::Vector{Connection})
    G = make_graph(data)
    V = Dict{Int, Symbol}(reverse(p) for p in make_vertex_map(data))

    # Find the maximal clique (a subset of vertices in the graph that are all
    # connected to each other) by looking for k-cliques (using the clique percolation
    # algorithm defined in Graphs.jl) starting at k = 0 and increasing k until there
    # is just one maximal clique and the next k-clique doesn't exist.  This wouldn't
    # work for all graphs, but it works in this problem because of how the inputs
    # are structured.  Graphs.jl also has `maximal_cliques` but I couldn't get that
    # to give me the correct output.
    k = 0
    while true
        C = clique_percolation(G, k = k)
        if length(C) == 1 && isempty(clique_percolation(G, k = k + 1))
            return password(Set{Symbol}(V[i] for i in only(C)))
        end
        k += 1
    end
end


### Main ###

function main()
    data = parse_input("data23.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 1046
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == "de,id,ke,ls,po,sn,tf,tl,tm,uj,un,xw,yz"
    println("Part 2: $part2_solution")
end

main()
