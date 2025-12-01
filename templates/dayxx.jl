# Description: what was the problem; how did I solve it; and (optionally)
# any thoughts on the problem or how I did.

#  ]add ~/projects/AdventOfCode.jl Statistics LinearAlgebra Combinatorics DataStructures StatsBase IntervalSets OrderedCollections MultidimensionalTools
using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections
# using MultidimensionalTools


### Parse Input ###

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end


### Part 1 ###

function part1(data)
end


### Part 2 ###

function part2(data)
end


### Main ###

function main()
    data = parse_input("data1.txt")
    data = parse_input("data1.test.txt")
    # println(data)

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
