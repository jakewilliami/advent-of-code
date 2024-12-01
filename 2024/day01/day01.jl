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
    L = get_integers.(L)
    L1, L2 = [l[1] for l in L], [l[2] for l in L]
    # println(L1)
    return L1, L2
end

function part1(data)
    L1, L2 = data
    L1, L2 = sort(L1), sort(L2)
    s = 0
    for i in 1:length(L1)
        l1, l2 = L1[i], L2[i]
        s += abs(l1 - l2)
        # println(l1,  " ", l2, " ", abs(l1-l2))
    end
    s
end

function part2(data)
    function cnt(n, lst)
        s = 0
        for i in lst
            if i == n
                s += 1
            end
        end
        s
    end
    L1, L2 = data
    s = 0
    for i in 1:length(L1)
        s += L1[i] * cnt(L1[i], L2)
    end
    s
end

function main()
    data = parse_input("data01.txt")
    # data = parse_input("data01.test.txt")

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
