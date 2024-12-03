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
    # L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return S
    return filter(!=('\n'), S)
end

function part1(data)
    pat = r"mul\((\d+),(\d+)\)"
    # data = only(data)
    c = 0
    for d in data
    for m in eachmatch(pat, d)
        m1 = parse(Int, m[1])
        m2 = parse(Int, m[2])
        c += m1*m2
    end
        end
    return c
end

function part2(data)
    pat1 = r"do\(\)"
    pat2 = r"don't\(\)"
    pat3 = r"mul\((\d+),(\d+)\)"
    c = 0
    d = only([data])

    f1 = last.(findall(pat1, d))
    pushfirst!(f1, 1)
    f2 = first.(findall(pat2, d))
        # push!(f2, length(d))

    for (i, d) in enumerate([data])
        println("line: $i")
    f1 = last.(findall(pat1, d))
    pushfirst!(f1, 1)
    f2 = first.(findall(pat2, d))
        push!(f2, length(d))
        println("$f1, $f2")

        # for (s, e) in zip(f1, f2)
        prev_e = nothing
        for s in f1
            if !isnothing(prev_e) && s < prev_e
                continue
            end
            e = f2[findfirst(x -> x > s, f2)]
            # println("$s $e")
        d2 = d[s:e]
        # println(s)
        # println(e)
            # println(repr(d2))
        for m in eachmatch(pat3, d2)
            m1 = parse(Int, m[1])
        m2 = parse(Int, m[2])
        c += m1*m2
        end
    end
        end
    c = 0
    for r in findall(pat3, data)
        s, e = first(r), last(r)
        # println("$s, $e")
        if any(s1 < s for s1 in f1) && any(e < e1 for e1 in f2)
            d2 = data[s:e]
            for m in eachmatch(pat3, d2)
            m1 = parse(Int, m[1])
        m2 = parse(Int, m[2])
        c += m1*m2
        end
        end
    end
    c = 0
    pat = r"(do\(\)|don't\(\))"
    allowed = true
    ms = findall(pat, data)
    pat = r"mul\((\d+),(\d+)\)"
    used = []
    i = 1
    while i <= length(data)-7
        break
        if data[i:i+4] == "do()"
            allowed=true
        elseif data[i:i+7] == "don't()"
            allowed=false
        end
        if allowed
            m = eachmatch(pat, data[i:end])
            if !isnothing(m) && !isempty(m)
                m = first(m)
                m1 = parse(Int, m[1])
        m2 = parse(Int, m[2])
                c += m1*m2
                i = last(findfirst(pat, data[i:end]))
            end
        end
        i += 1
    end
    c = 0
    D = Dict()
    allowed = true
    for i in 1:length(data)-7
        if data[i:i+3] == "do()"
            allowed=true
        elseif data[i:i+6] == "don't()"

            allowed=false
        end
        D[i] = allowed
    end
    # println(D)

    for r in findall(pat, data)
        # if all(i -> get(D, i, false), r)
            if get(D, first(r), false)
            println(r)
            s = data[r][5:end-1]
            c += prod(parse.(Int, split(s, ',')))
        end
    end
    c
end

function main()
    data = parse_input("data03.txt")
    # data = parse_input("data03.test.txt")

    # Part 1
    # part1_solution = part1(data)
    # @assert part1_solution ==
    # println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

# not 197919940
# not 492057231
# not 306080445
# not 165225049
# answer was 108830766

main()
