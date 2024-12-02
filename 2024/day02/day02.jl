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
    return L
end

function issafe(l)
    function isgt(l)
        all(2:length(l)) do i
            l[i-1] > l[i]
        end
    end
    function islt(l)
        all(2:length(l)) do i
            l[i-1] < l[i]
        end
    end
    function diffs(l)
        return [abs(l[i-1] - l[i]) for i in 2:length(l)]
    end
    function f2(l)
        all(diffs(l)) do i
            1 <= i <= 3
        end
    end
    return (isgt(l) || islt(l)) && f2(l)
end

function part1(data)

    c = 0
    for l in data
        if issafe(l)
            c += 1
        end
    end
    return c
end

function part2(data)
    c = 0
    for l in data
        found = false
        for i in 1:length(l)
            l2 = deepcopy(l)
            deleteat!(l2, i)
            if issafe(l2)
                found = true
                break
            end
        end
        c += found
    end
    return c
end

function main()
    data = parse_input("data02.txt")
    # data = parse_input("data02.test.txt")

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
