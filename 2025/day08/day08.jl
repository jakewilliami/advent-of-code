# I'm ashamed to say that this might very well be the messiest solution I've ever written
# I was in too deep and just needed to get it running without much consideration for efficiency

# Description: what was the problem; how did I solve it; and (optionally)
# any thoughts on the problem or how I did.

# ]add https://github.com/jakewilliami/AdventOfCode.jl Statistics LinearAlgebra Combinatorics DataStructures StatsBase IntervalSets OrderedCollections MultidimensionalTools  # TODO: IterTools, ProgressMeter, BenchmarkTools, Memoization
# using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using ProgressMeter
using Base.Iterators
# using Statistics
using LinearAlgebra # needed
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections
# using MultidimensionalTools


### Parse Input ###

const Index = CartesianIndex

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    L = [parse.(Int, split(l, ',')) for l in L]
    # TODO: is this right order?
    return [CartesianIndex(a, b, c) for (a, b, c) in L]
    # L = get_integers.(L)
    return L
end


### Part 1 ###

struct ST  # set tuple
    p::Set{Index}
end

ST(a::Index, b::Index) = ST(Set{Index}((a, b)))
Base.iterate(s::ST) = Base.iterate(sort(collect(s.p)))
Base.iterate(s::ST, state) = Base.iterate(sort(collect(s.p)), state)
Base.:(==)(a::ST, b::ST) = a.p == b.p

eucl(i, j) = norm(Tuple(i - j))
manh(i, j) = norm(Tuple(i - j), 1)

function find_closest(data, i)
    @assert !isempty(data)
    best = typemax(Float64)
    bestmatch = nothing
    for j in data
        j == i && continue
        d = eucl(i, j)
        if d < best
            bestmatch = j
        end
    end
    @assert !isnothing(bestmatch)
    return bestmatch
end

function find_circuit(circuits, i)
    for (k, circuit) in enumerate(circuits)
        # println(any(i == j for j in circuit), i, circuit)
        if any(i == j for j in circuit)
            return k
        end
    end
    return nothing
end

function find_circuit(circuits, i, j)
    # first check if both indices are in separate circuits; then we need to join the circuit
    found = [false, false]
    ks = [0, 0]
    for (k, circuit) in enumerate(circuits)
        if any(i == x for x in circuit)
            @assert !found[1]
            found[1] = true
            ks[1] = k
        end
        if any(j == x for x in circuit)
            @assert !found[2]
            found[2] = true
            ks[2] = k
        end
    end

    # now the simple condition where one
    if sum(found) == 1
        @assert any(iszero, ks)
        @assert sum(!iszero, ks) == 1
        return sum(ks)
    end

    if sum(found) == 2
        if ks[1] == ks[2]
            return ks[1]
        end
        return ks
    end

    #=for (k, circuit) in enumerate(circuits)
        if any(i == x || j == x for x in circuit)
            return k
        end
    end
    return nothing=#
    return nothing
end

function distances(data)
    D = Dict{ST, Float64}()
    for i in 1:length(data)
        for j in i+1:length(data)
            a, b = data[i], data[j]
            d = eucl(a, b)
            D[ST(a, b)] = d
        end
    end
    return D
end

function part1(data)
    data = deepcopy(data)
    res = []
    circuits = []
    dists = distances(data)
    n1,n2 = 1000, 3
    p = false
    smallest = sort([(i, k, v) for (i, (k, v)) in enumerate(dists)], by = x -> last(x))

    #=for (ind, i) in enumerate(data)
        j = find_closest(data, i)
        k = find_circuit(circuits, j)
        if isnothing(k)
            # then we have a new circuit
            push!(circuits, [i, j])
        else
            push!(circuits[k], j)
        end
    end=#
    for (_ind, (i, j), d) in smallest[1:n1]
        p && println("$d $i $j")
        #=k = find_circuit(circuits, i)
        if isnothing(k)
            # then we have a new circuit
            k2 = find_circuit(circuits, j)
            if isnothing(k2)
            # s = Set{Index}()
            # push!(s, i); push!(s, j)
            # push!(circuits, s)
                push!(circuits, Set{Index}((i, j)))
            else
                push!(circuits[k2], i)
                push!(circuits[k2], j)
            end
        else
            k2 = find_circuit(circuits, j)
            if isnothing(k2)
                push!(circuits, Set{Index}((i, j)))
            else
                push!(circuits[k], i)
                push!(circuits[k], j)
            end
        end=#
        k = find_circuit(circuits, i, j)
        if isnothing(k)
            push!(circuits, Set{Index}((i, j)))
        else
            if k isa Int
                push!(circuits[k], i)
                push!(circuits[k], j)
            else
                @assert k isa Vector{Int} typeof(k)
                k1, k2 = k
                for x in circuits[k2]
                    push!(circuits[k1], x)
                end
                deleteat!(circuits, k2)
                # append!(circuits[k1], circuits[k2])
            end
        end
        p && println("    !! $k ($(countmap(map(length, circuits)))): $circuits\n")
        # println("  $circuits")
    end

    for (_ind, (i, j), _d) in smallest[n1+1:end]
        # println("@@ $i $j")
        # push!(circuits, Set{Index}((i, j)))
    end

    for i in data
        if !any(i ∈ c for c in circuits)
            push!(circuits, Set{Index}((i,)))
        end
    end

    # return circuits
     return prod(sort(map(length, circuits), rev=true)[1:n2])
end


### Part 2 ###

function init(data, n1)
    data = deepcopy(data)
    res = []
    circuits = []
    dists = distances(data)
    n2 = 3
    p = false
    smallest = sort([(i, k, v) for (i, (k, v)) in enumerate(dists)], by = x -> last(x))

    for (_ind, (i, j), d) in smallest[1:n1]
        p && println("$d $i $j")
        k = find_circuit(circuits, i, j)
        if isnothing(k)
            push!(circuits, Set{Index}((i, j)))
        else
            if k isa Int
                push!(circuits[k], i)
                push!(circuits[k], j)
            else
                @assert k isa Vector{Int} typeof(k)
                k1, k2 = k
                for x in circuits[k2]
                    push!(circuits[k1], x)
                end
                deleteat!(circuits, k2)
            end
        end
        p && println("    !! $k ($(countmap(map(length, circuits)))): $circuits\n")
    end

    for i in data
        if !any(i ∈ c for c in circuits)
            push!(circuits, Set{Index}((i,)))
        end
    end

    return circuits
end

function flt(cs)
    a = []
    for x in Base.Iterators.map(sort ∘ collect, cs)
        for v in x
            push!(a, v)
        end
    end
    return a
end
# flt(cs) = Base.Iterators.flatten(Base.Iterators.map(sort ∘ collect, cs))

# flat = flt(circuits)
# dists = distances(flat)
function next_joinable_circuits(circuits)
    dists = DISTS
    smallest = SMALLEST

    for s in smallest
        i, j = s
        same_circuit = false
        for circuit in circuits
            if i ∈ circuit && j ∈ circuit
                same_circuit = true
                break
            end
        end
        if !same_circuit
            return s
        end
    end

    # find the smallest distance between two junctions in different circuits
    #
    # to do this, we should remove connections within each circuit
    # println("start")
    is = []
    for circuit in circuits
        circuit = sort(collect(circuit))
        for i in 1:length(circuit)
            for j in i+1:length(circuit)
                a, b = circuit[i], circuit[j]
                s = ST(a, b)
                # if s ∉ is
                push!(is, s)
                # end
            end
        end
    end
    # println("stop")

    for i in smallest
        if i ∉ is
            return i
        end
    end
    error("unreachable")

    smallest = [i for i in smallest if i ∉ is]
    return smallest[1]

    to_delete = []
    for i in is
        # println(i)
        # println(smallest)
        j = findfirst(==(i), smallest)
        @assert !isnothing(j)
        push!(to_delete, j)
    end
    deleteat!(smallest, sort(unique(to_delete)))

    return smallest[1]

    return
    for i in 1:length(circuits)
        for j in i+1:length(circuits)
            ca, cb = circuits[i], circuits[j]
            for a in ca
                for b in cb
                    # if
                end
            end
        end
    end
end

# flat = flt(circuits)
# dists = distances(flat)
# smallest = sort([(k, v) for (k, v) in dists], by = x -> last(x))
# smallest = [x for (x, _) in smallest]
function join_two!(circuits, m = false)
    dists = DISTS
    smallest = SMALLEST

    # step 1: find the smallest distance between two junctions that don't share
    # the same circuit
    n = next_joinable_circuits(circuits)
    m && return n
    i, j = n

    # step 2: find thier circuits and join
    k1, k2 = find_circuit(circuits, i), find_circuit(circuits, j)

    # step 3: join them
    for x in circuits[k2]
        push!(circuits[k1], x)
    end
    deleteat!(circuits, k2)

    return circuits
end

function join_one_pass!(circuits, n1)
    if length(circuits) == 1
        error("hihi")
    end

    # find the ones that are still waiting to be placed into a group


    dists = distances(data)
    smallest = sort([k for (k, v) in dists], by = x -> last(x))
    flat = flt(circuits)
    # for circuit in flat
    for circuit in circuits
        for i in circuit

        end
    end
end

function part2(data)
    data = deepcopy(data)
    prev_data = deepcopy(data)
    n1 = 10
    # circuits = join_one_pass!(data, n1)
    # data = deepcopy(data)
    # res = []
    # dists = distances(data)
    # n2 = 3
    # p = false
    # smallest = sort([(i, k, v) for (i, (k, v)) in enumerate(dists)], by = x -> last(x))
    # _, (i, j), _ = smallest[end]
    # Tuple(i)[1] * Tuple(j)[1]
    circuits = init(data, n1)
    prev_circuits = deepcopy(circuits) # Set?
    N = length(circuits)
    # println(length(circuits))
    # p = Progress(N)

    join_two!(circuits)
    # next!(p)
    while length(circuits) > 2
        # println("here")
        # prev_circuits = deepcopy(circuits)
        join_two!(circuits)
        # next!(p)
    end

    a, b = join_two!(circuits, true)
    # next!(p)
    # join_one_pass!(circuits, n1)

    # finish!(p)
    Tuple(a)[1]*Tuple(b)[1]
end

#=function part2(data)
    circuits = init(data, 10)

end=#


### Main ###
DATA = parse_input("data08.txt")
# DATA = parse_input("data08.test.txt")
DISTS = distances(DATA)
SMALLEST = sort([(k, v) for (k, v) in DISTS], by = x -> last(x))
SMALLEST = [x for (x, _) in SMALLEST]

function main()
    # println(data)
    data = deepcopy(DATA)

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 97384
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 9003685096
    println("Part 2: $part2_solution")
end

main()
