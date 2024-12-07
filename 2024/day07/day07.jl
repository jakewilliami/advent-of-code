using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    L = [strip.(split(l, ':')) for l in L]
    L1 = [parse(Int, l) for (l, _) in L]
    L2 = [parse.(Int, split(l)) for (_, l) in L]
    # L = get_integers.(L)
    return L1, L2
end

function ops(v)
    return collect(Base.Iterators.product(((+, *) for i in 1:(length(v)-1))...))
    [p for p in permutations((+, *), length(v) - 1)]
end

function apply_op(v, ov)
    r = ov[1](v[1], v[2])
    for i in 2:length(ov)
        r = ov[i](r, v[i + 1])
    end
    r
end

function part1(data)
    L1, L2 = data
    r = 0
    for (n, (l1, l2)) in enumerate(zip(L1, L2))
        a = any(apply_op(l2, o) == l1 for o in ops(l2))
        if a
            r += sum(l1)
        end
    end
    r
end

function ops2(v)
    return collect(Base.Iterators.product((('+', '*', '|') for i in 1:(length(v)-1))...))
end

function apply_op1(op, v1, v2)
    if op == '+'
        return v1 + v2
    elseif op == '*'
        return v1 * v2
    elseif op == '|'
        return parse(Int, join((v1, v2)))
    else
        error(op)
    end
end

function apply_op2(v, ov)
    r = apply_op1(ov[1], v[1], v[2])
    for i in 2:length(ov)
        r = apply_op1(ov[i], r, v[i + 1])
    end
    r
end

function part2(data)
    L1, L2 = data
    r = 0
    for (n, (l1, l2)) in enumerate(zip(L1, L2))
        println("$n/$(length(L1))")
        a = any(apply_op2(l2, o) == l1 for o in ops2(l2))
        if a
            r += sum(l1)
        end
    end
    r
end

function main()
    data = parse_input("data07.txt")
    # data = parse_input("data07.test.txt")

    # Part 1
    # part1_solution = part1(data)
    # @assert part1_solution ==
    # println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()
