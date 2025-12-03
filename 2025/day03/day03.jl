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
    # M = readlines_into_int_matrix(input_file)
    # return M
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    return L
    # L = get_integers.(L)
    # return [parse(BigInt, l) for l in L]
    return L
end


### Part 1 ###

function get_first_max(s::AbstractString)
    for n in 9:-1:1
        c = only(string(n))
        if c ∈ s[1:end-1]
            return c
        end
    end
end

function get_max(s::AbstractString)
    a = get_first_max(s)
    i = findfirst(a, s)

    A = []
    for j in i+1:length(s)
        push!(A, parse(Int, s[j]))
    end

    b = maximum(A)
    return parse(Int, "$a$b")

    # for i in 1:length(s)
        # for j in 1:length(s)
            # i == j && continue
            # for i in 9:-1:0
        # end
    # end
end

function part1(data)
    sum(data) do x
        get_max(x)
    end
end


### Part 2 ###

function get_first_max2(s::AbstractString, i)
    for n in 9:-1:1
        c = only(string(n))
        if c ∈ s[1:end-i]
            return c
        end
    end
end

function get_max2111(s::AbstractString)
    a = get_first_max(s)
    i = findfirst(a, s)

    A = []
    for j in i+1:length(s)
        push!(A, parse(Int, s[j]))
    end

    b = maximum(A)
    return parse(Int, "$a$b")

    # for i in 1:length(s)
        # for j in 1:length(s)
            # i == j && continue
            # for i in 9:-1:0
        # end
    # end
end

function get_max2_old(s::AbstractString, i = 1, res = "")
    if i == 12
        return res
    end

    j = i - 1
    for n in 9:-1:1
        c = only(string(n))
        if c ∈ s[1:end-j]
            k = findfirst(c, s[1:end-j])
            return get_max2(s[k:end], i + 1, res * c)
        end
    end
end

function get_max2_bad_logic(s)
    # remove them
    len = length(s)
    target = 12
    to_remove = len - target
    i = 0
    n = 1
    while i <= to_remove
        c = only(string(n))
        if c ∈ s
            j = findfirst(c, s)
            a = collect(s)
            deleteat!(a, j)
            s = join(a)
            i += 1
        else
            n += 1
        end
    end
    return parse(Int, s)
end

function get_max2(s)
    a = get_first_max2(s, 12 - 1)
    i = findfirst(a, s)
    b = get_first_max2(s[i+1:end], 12 - 2)
    # i =

    res = ""
    i = 0
    for j in 12:-1:1
        s = s[i+1:end]
        c = get_first_max2(s, j - 1)
        res *= c
        i = findfirst(c, s)
    end
    return parse(Int, res)

    A = []
    for j in i+1:length(s)
        push!(A, parse(Int, s[j]))
    end

    b = maximum(A)
    return parse(Int, "$a$b")
end

function part2(data)
    sum(data) do x
        s = get_max2(x)
        # println(s)
        s
    end
end


### Main ###

function main()
    data = parse_input("data03.txt")
    # data = parse_input("data03.test.txt")
    # println(data)

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution == 17535
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution == 173577199527257
    # not 15025641770162
    println("Part 2: $part2_solution")
end

main()
