using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

function parse_input(input_file::String)
    M = readlines_into_char_matrix(input_file)
    return M
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end

# There's a map of nearby hiking trails (your puzzle input) that indicates paths (.), forest (#), and steep slopes (^, >, v, and <).

SLOPES = Dict('>' => INDEX_RIGHT, '<' => INDEX_LEFT, '^' => INDEX_UP, 'v' => INDEX_DOWN)

function get_target(M, k)
    row = view(M, k, :)
    i = only(findall(i -> row[i] == '.', eachindex(row)))
    return CartesianIndex(k, i)
end
get_start(M) = get_target(M, 1)
get_end(M) = get_target(M, size(M, 1))

function possible_positions(M, i)
    I = []
    for (j, c) in cardinal_adjacencies_with_indices(M, i)
        if c != '#'
            push!(I, j)
        end
    end
    return I
end

function part1(data)
    si = get_start(data)
    ti = get_end(data)

    Ps = []

    Q, S = Queue{Any}(), Set()
    enqueue!(Q, (si, [si]))

    while !isempty(Q)
        i, P = dequeue!(Q)

        i in S && continue
        push!(S, i)
        # i in P && continue

        if i == ti
            push!(Ps, P)
            continue
        end

        c = data[i]
        if haskey(SLOPES, c)
            # we have to go in this direction
            j = i + SLOPES[c]
            enqueue!(Q, (j, push!(copy(P), j)))
        else
            for j in possible_positions(data, i)
                enqueue!(Q, (j, push!(copy(P), j)))
            end
        end
    end

    return length(Ps)
    return minimum(length, Ps)
end

function part2(data)
end

function main()
    data = parse_input("data23.txt")
    data = parse_input("data23.test.txt")

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
