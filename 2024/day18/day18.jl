using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

const Index = CartesianIndex{2}

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    L = get_integers.(L)
    return [CartesianIndex{2}(y, x) for (x, y) in L]
end

function find_path(si, ei, data, N)
    R = si:ei
    disallowed = Set{Index}(data[1:N])
    Q = Queue{Tuple{Index, Direction{2}, Int}}()
    S = Set{Tuple{Index, Direction{2}}}()
    for d in cardinal_directions(2)
        enqueue!(Q, (si, d, 0))
    end

    while !isempty(Q)
        i, d, s = dequeue!(Q)

        if i == ei
            return s
        end

        if (i, d) ∈ S
            continue
        end
        push!(S, (i, d))

        for d in cardinal_directions(2)
            j = i + d
            if j ∉ disallowed && j ∈ R
                enqueue!(Q, (j, d, s + 1))
            end
        end
    end
end

function part1(data, test=true)
    si = origin(2)
    ei = test ? CartesianIndex(6, 6) : CartesianIndex(70, 70)
    return find_path(si, ei, data, test ? 12 : 1024)
end

function part2(data, test=false)
    si = origin(2)
    ei = test ? CartesianIndex(6, 6) : CartesianIndex(70, 70)

    N = test ? 12 : 1024
    while N <= length(data)
        n = find_path(si, ei, data, N)
        if isnothing(n)
            y, x = Tuple(data[N])
            return "$x,$y"
        end
        N += 1
    end
end

function main()
    data = parse_input("data18.txt")
    # data = parse_input("data18.test.txt")

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
