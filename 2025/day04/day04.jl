# Description: what was the problem; how did I solve it; and (optionally)
# any thoughts on the problem or how I did.

#  ]add ~/projects/AdventOfCode.jl Statistics LinearAlgebra Combinatorics DataStructures StatsBase IntervalSets OrderedCollections MultidimensionalTools
using AdventOfCode.Parsing, AdventOfCode.Multidimensional
using Base.Iterators
using Statistics
using LinearAlgebra
using Combinatorics
using DataStructures
using StatsBase
using IntervalSets
using OrderedCollections
using MultidimensionalTools


### Parse Input ###

function parse_input(input_file::String)
    M = readlines_into_char_matrix(input_file)
    return M
    # S = strip(read(input_file, String))
    # L = string.(strip.(readlines(input_file)))
    # L = get_integers.(L)
    return L
end


### Part 1 ###

function part1(data)
    a = 0
    for i in CartesianIndices(data)
        data[i] == '@' || continue
        b = 0
        for d in cartesian_directions(2)
            x = Multidimensional.tryindex(data, i + d)
            b += x == '@'
        end
        if b < 4
            a += 1
        end
    end
    return a
end


### Part 2 ###
function something!(data)
    a = 0
    Is = []
    for i in CartesianIndices(data)
        data[i] == '@' || continue
        b = 0
        for d in cartesian_directions(2)
            x = Multidimensional.tryindex(data, i + d)
            b += x == '@'
        end
        if b < 4
            push!(Is, i)
            a += 1
        end
    end
    for i in Is
        data[i] = '.'
    end
    return a
end

function part2(data)
    data = deepcopy(data)
    prev_state = deepcopy(data)
    r = something!(data)
    while data != prev_state
        prev_state = deepcopy(data)
        r += something!(data)
    end
    return r
end


### Main ###

function main()
    data = parse_input("data04.txt")
    # data = parse_input("data04.test.txt")
    # println(data)

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 1344
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 8112
    println("Part 2: $part2_solution")
end

main()
