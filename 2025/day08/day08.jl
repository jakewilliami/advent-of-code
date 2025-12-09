# Description: what was the problem; how did I solve it; and (optionally)
# any thoughts on the problem or how I did.

using LinearAlgebra


### Parse Input ###

const Index = CartesianIndex
const Circuit = Set{Index}

function parse_input(input_file::String)
    L = strip.(readlines(input_file))
    return Index[Index(parse.(Int, split(line, ','))...) for line in L]
end


### Part 1 ###

# TODO: order all pairs (junctions) by distance
# TODO: JP used UF (union find) https://www.youtube.com/watch?v=Gd4-LOBfA88

struct Junction  # set tuple
    p::Tuple{Index,Index}
end

Junction(a::Index, b::Index) = Junction(Tuple(sort([a, b])))
Base.iterate(s::Junction) = Base.iterate(s.p)
Base.iterate(s::Junction, state) = Base.iterate(s.p, state)
Base.:(==)(a::Junction, b::Junction) = a.p == b.p

# Compute Euclidean distance using LinearAlgebra
distance(i::Index, j::Index) = norm(Tuple(i - j))

# Find index of circuit to which Index `i` belongs (greedy algorithm; findfirst)
function find_circuit(circuits::Vector{Circuit}, i::Index, j::Index)
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

    return nothing
end

function precompute_distances(data::Vector{Index})
    D = Dict{Junction, Float64}()

    for i in 1:length(data)
        for j in i+1:length(data)
            a, b = data[i], data[j]
            d = distance(a, b)
            D[Junction(a, b)] = d
        end
    end

    return D
end

function init(data::Vector{Index}, sorted::Vector{Junction})
    data = deepcopy(data)
    circuits = Circuit[]

    # Memoise the index of the circuit that a junction (pair of indices) exists
    mem = Dict{Union{Junction, Index}, Int}()
    # mem = Dict{Index, Int}()

    # initially join closest 1000 smallest (TODO: document)
    # TODO: document
    for s in sorted[1:1000]
        i, j = s

        #=if !haskey(mem, s)
            # two options: fresh pair, or individuals and need to join circuits
            if haskey(mem, i) && haskey(mem, j)
                k1, k2 = mem[i], mem[j]
                if k1 == k2
                end
            else
                push!(circuits, Set{Index}((i, j)))
                mem[s] = length(circuits)
            end
            continue
        end

        k = mem[s]
        push!(circuits[k], i)
        push!(circuits[k], j)=#

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
    end

    # fill in the remaining (TODO: document)
    for i in data
        if !any(i ∈ c for c in circuits)
            push!(circuits, Set{Index}((i,)))
        end
    end

    return circuits
end

function part1(data::Vector{Index}, sorted::Vector{Junction})
    circuits = init(data, sorted)
    return prod(sort(map(length, circuits), rev=true)[1:3])
end


### Part 2 ###

function find_nearest_joinable_circuits(circuits::Vector{Circuit}, sorted::Vector{Junction})
    for s in sorted
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

    error("unreachable")
end

# Find index of circuit to which Index `i` belongs (greedy algorithm; findfirst)
function find_circuit(circuits::Vector{Circuit}, i::Index)
    for (k, circuit) in enumerate(circuits)
        any(i == j for j in circuit) && return k
    end
    return nothing
end

function join_nearest_two_circuits!(circuits::Vector{Circuit}, sorted::Vector{Junction})
    # step 1: find the smallest distance between two junctions that don't share
    # the same circuit
    i, j = find_nearest_joinable_circuits(circuits, sorted)

    # step 2: find thier circuits and join
    k1, k2 = find_circuit(circuits, i), find_circuit(circuits, j)

    # step 3: join them
    for x in circuits[k2]
        push!(circuits[k1], x)
    end
    deleteat!(circuits, k2)

    return circuits
end

function part2(data::Vector{Index}, sorted::Vector{Junction})
    data = deepcopy(data)
    n1 = 10
    circuits = init(data, sorted)

    join_nearest_two_circuits!(circuits, sorted)
    while length(circuits) > 2
        join_nearest_two_circuits!(circuits, sorted)
    end

    i, j = find_nearest_joinable_circuits(circuits, sorted)
    return first(Tuple(i)) * first(Tuple(j))
end


### Main ###

function main()
    data = parse_input("data08.txt")
    # data = parse_input("data08.test.txt")
    distances = precompute_distances(data)
    sorted = sort([(k, v) for (k, v) in distances], by = x -> last(x))
    sorted = Junction[x for (x, _) in sorted]

    # Part 1
    part1_solution = part1(data, sorted)
    @assert part1_solution == 97384
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data, sorted)
    @assert part2_solution == 9003685096
    println("Part 2: $part2_solution")
end

main()
