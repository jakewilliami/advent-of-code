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
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    L = get_integers(only(L))
    return L
end

function splitnum(n)
    h = 10^(ndigits(n) ÷ 2)
    left = n ÷ h
    right = n % h
    return left, right
end

function change(s::Int)
    iszero(s) && return [1]
    iseven(ndigits(s)) && return [splitnum(s)...]
    return s * 2024
end

function blink!(S::Vector{Int})
    M = Tuple{Int, Vector{Int}}[]  # the stones that need to multiply
    for (i, s) in enumerate(S)
        s′ = change(s)
        if isone(length(s′))
            S[i] = only(s′)
        else
            push!(M, (i, s′))
        end
    end

    # now handle expansion
    for (offset, (i, s′)) in enumerate(M)
        # we can handle offset using enumerate because the numbers only split into two so the offset increments by just one each time
        splice!(S, i + offset - 1, s′)
    end

    return S
end

function part1(data)
    N = 25
    for i in 1:N
        blink!(data)
    end
    length(data)
end

function part2(data)
    N = 75

    D = DefaultDict(0)
    for d in data
        D[d] += 1
    end

    # Heavily inspired by lanternfish solution:
    # https://www.youtube.com/watch?v=fHlWM8CIrlI
    for i in 1:N
        println("$i/$N")
        D′ = DefaultDict(0)
        for (s, n) in D
            for s′ in change(s)
                D′[s′] += n
            end
        end
        # merge!(D, D′)
        D = D′
    end

    return sum(values(D))

    r = 0
    for i in 1:N
        r += sum(() for s in data)
    end
end

function main()
    data = parse_input("data11.txt")
    # data = parse_input("data11.test.txt")
    # data = parse_input("data11.test2.txt")
    # data = parse_input("data11.test3.txt")

    # Part 1
    part1_solution = part1(deepcopy(data))
    # @assert part1_solution ==
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(deepcopy(data))
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()

# Not 367052, too low
# Not 5895 - didn't try but obviously too low
