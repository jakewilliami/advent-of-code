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
    S = strip(read(input_file, String))
    S1, S2 = split(S, "\n\n")
    L1 = [parse.(Int, split(l, '|')) for l in split(S1, '\n') if !isempty(strip(l))]
    L2 = [parse.(Int, split(l, ',')) for l in split(S2, '\n') if !isempty(strip(l))]
    # L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L1, L2
end

function allowed_before(a::Int, b::Int, data)
    # x must come before y
    v1,v2 = [], []
    for (x, y) in data
        if x == a && y == b
            return true
        end
        if x == b && y == a
            return false
        end
    end

    return true
end

function check(l::Vector{Int}, data)
    for i in 1:length(l)
        if !all(allowed_before(l[i], l[j], data) for j in (i+1):length(l))
            return false
        end
    end
    return true
end

function part1(data)
    L1, L2 = data

    r = 0
    for l in L2
        if check(l, L1)
            i = fld(length(l), 2) + 1
            r += l[i]
        end
    end

    r
end

using Combinatorics

function find_before(a, data, used, order)
    for (x, y) in data
        if y == a && y ∉ used
            return x
        end
    end
end

L1, L2 =  parse_input("data05.txt")
# L1, L2 =  parse_input("data05.test.txt")

function correct_order(a, b, data)
    # an = true
    for (x, y) in data
        if x == a && y == b
            return true
        end
        # if x ever comes before y
        if x == b && y == a
            return false
        end
    end

    return true
end

struct MO <: Base.Order.Ordering end
Base.Order.lt(_o::MO, a, b) = correct_order(a, b, L2)
# Base.Order.lt(_o::MO, a, b) = correct_order(a, b, L2)
# Base.Order.gt(_o::MO, b, a) = allowed_before(b, a, L2)


struct F <: AbstractVector{Int}
    data::Vector{Int}
end

function findfirst_allowed(l, data)
    for i in 1:length(l)
        l2 = deepcopy(l)
        x = l2[i]
        deleteat!(l2, i)
        if all(allowed_before(x, y, data) for y in l2)
            return (i, x)
        end
    end
end

function find_lowest(data)
    i = 1
    order = []
    l, r = data[i]
    res = find_before(l, data, Set(), order)
    res_prev = res
    used = Set((l, res))
    pushfirst!(order, l)
    pushfirst!(order, res)
    while !isnothing(res)
        res_prev = res
        res = find_before(res, data, used, order)
        if !isnothing(res)
            push!(used, res)
            pushfirst!(order, res)
        end
    end
    println(order)
    return res_prev
end

function correct_order(l, data)
    l2 = []

    l′ = deepcopy(l)
    while true
        if !isempty(l′)
            i, x = findfirst_allowed(l′, data)
            push!(l2, x)
            deleteat!(l′, i)
        else
            break
        end
    end
    return l2

    #=for p in permutations(l)
        # println(p, ": ", check(l, data))
        if check(p, data)
            return p
        end
    end=#
    # println(find_lowest(data))
    println(sort(l, order=MO()))
    l
end

function part2(data)
    L1, L2 = data
    # println(check([97, 75, 47, 61, 53], L1))
    # println(check([61,29,13], L1))
    # println(check([97,75,47,29,13], L1))

    r = 0
    for l in L2
        if !check(l, L1)
            # println("-==================")
            # println(l)
            # println(findfirst_allowed(l, data))

            # l′ = sort(l, order=MO())
            l′ = correct_order(l, L1)
            println(l, " => ", l′)
            i = fld(length(l), 2) + 1
            r += l′[i]
        end
    end

    r
end


function main()
    data = parse_input("data05.txt")
    # data = parse_input("data05.test.txt")

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


# not 5198
