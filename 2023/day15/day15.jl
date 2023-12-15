using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
using OrderedCollections

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    S = strip(read(input_file, String))
    # L = readlines(input_file)
    L = split(S, ",")
    # L = get_integers.(L)
    return L
end

h(c::Char, s=0) = rem((s+Int(c)) * 17, 256)
function h(s::AbstractString)
    ans = 0
    for c in s
        ans = h(c, ans)
    end
    return ans
end

function part1(data)
    for s in data
        # println(s)
        # println(h(s))
    end
    return sum(h(s) for s in data)
    res = 0
    return res
end

function get_val(s)
    if '=' in s
        n, v = split(s, '=')
        v = parse(Int, v)
        return n, v
    else
        @assert endswith(s, '-')
        return s[1:end-1], s
    end
end

function dis(A)
    for i in 1:length(A)
        if !isempty(A[i])
            println("    Box $(i - 1): $(A[i])")
        end
    end
    println()
end

function _score_helper(A)
    D = Dict()
    for (i, box) in enumerate(A)
        for (j, (lens, len)) in enumerate(box)
            D[lens] = (i, j, len)
        end
    end
    return D
end

function score(A)
    D = _score_helper(A)
    res = 0
    for (i, box) in enumerate(A)
        for (j, (lens, len)) in enumerate(box)
            res += prod((i, j, len))
        end
    end
    return res
end

function part2(data)
    A = [OrderedDict() for _ in 1:256]
    # A = Vector(undef, 256)

    for s in data
        n, v = get_val(s)
        m = h(n) + 1

        if v isa Int
            # =
            if haskey(A[m], n)
                A[m][n] = v
            else
                A[m][n] = v
            end
        else
            # -
            if haskey(A[m], n)
                pop!(A[m], n)
            end
        end
        # println("After \"$s\":")
        # dis(A)
    end

    return score(A)

    return A

    return 0
    D = OrderedDict()
    # i = 1
    for s in data
        n, v = get_val(s)
        # =
        if v isa Int
            if haskey(D, n)
                D[n] = v
            else
                D[n] = v
            end
        else # -
            if haskey(D, n)
                pop!(D, n)
            end
        end
    end
    println(D)
end

function main()
    data = parse_input("data15.txt")
    # data = parse_input("data15.test.txt")
    # println(data)
    # println(h(data[end]))

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
