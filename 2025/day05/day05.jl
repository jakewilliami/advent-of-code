# Description: what was the problem; how did I solve it; and (optionally)
# any thoughts on the problem or how I did.

#  ]add ~/projects/AdventOfCode.jl Statistics LinearAlgebra Combinatorics DataStructures StatsBase IntervalSets OrderedCollections MultidimensionalTools
# using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using ProgressMeter
# using IterTools
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using BenchmarkTools
# using IntervalSets
# using OrderedCollections
# using MultidimensionalTools


### Parse Input ###

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    S = strip(read(input_file, String)) # readchomp
    a, b = split(S, "\n\n")
    # fresh ingredient ids
    a = [split(x, '-') for x in split(a, '\n')]
    a = [Tuple(parse.(Int, x)) for x in a]
    a = [m:n for (m, n) in a]
    # available ingredients
    b = [parse(Int, x) for x in split(b, '\n')]
    return a, b
    # L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end


### Part 1 ###

function part1(data)
    fresh, available = data
    r = 0
    for i in available
        if any(i ∈ r for r in fresh)
            r += 1
        end
    end
    return r
end


### Part 2 ###

function ranges_contiguous(r1, r2)
    r1, r2 = sort([r1, r2])
    a = false
    if isone(r2.start - r1.stop)
        a = true
    end

    if !a && !isempty(intersect(r1, r2))
        a = true
    end

    if a
        return [r1.start:r2.stop]
    else
        return [r1, r2]
    end
end

function ranges_contiguous′(r1, r2)
    r = ranges_contiguous(r1, r2)
    if isone(length(r))
        return true, r
    else
        return false, r
    end
end

function simplify_ranges(r1, r2)
    return ranges_contiguous(r1, r2)
    r = ranges_contiguous(r1, r2)
    if isnothing(r)
        return [r1, r2]
    else
        return [r]
    end
end

function _simplify_ranges(rs)
    rs′ = []
    for i in 1:length(rs) - 1
        # println(i)
        for j in i+1:length(rs)
            # println("  ", j)
            r1, r2 = rs[i], rs[j]
            r = simplify_ranges(r1, r2)
            for x in r
                if x ∉ rs′
                    push!(rs, x)
                end
            end
            # append!(rs′, r)
            # unique!(rs′)
        end
    end
    #=is = []
    for i in 1:length(rs′)
        r = rs′[i]
        for j in 1:length(rs′)
            i == j && continue
            r2 = rs′[j]
            if all(x ∈ r2 for x in r)
                push!(is, i)
            end
        end
    end
    sort!(is)
    unique!(is)
    deleteat!(rs′, is)=#
    return rs′
end

function simplify_ranges(rs)
    rs_prev = deepcopy(rs)
    rs = _simplify_ranges(rs)
    # println(length(rs))
    # println("----")
    while rs_prev != rs
        # println(length(rs))
        rs_prev = deepcopy(rs)
        rs = _simplify_ranges(rs)
        # println(length(rs))
    end
    return rs
end

function rnormalize(s)
    sort([[a.start, a.stop] for a in s])
    # sort([sort(bounds) for bounds in s])
end

# https://rosettacode.org/wiki/Range_consolidation#Julia
function consolidate0(ranges)
    norm = rnormalize(ranges)
    for (i, r1) in enumerate(norm)
        if !isempty(r1)
            # println("$i: $r1")
            for (j, r2) in enumerate(norm[i+1:end])
                j += i
                isempty(r2) && continue
                # println("  $j: $r2")
                if !isempty(r2) && r1[end] >= r2[1]     # intersect?
                    r1 .= [r1[1], max(r1[end], r2[end])]
                    empty!(r2)
                    # println("    right: $(norm)")
                end
            end
        end
    end
    # println("$norm, $([r for r in norm if !isempty(r)])")
    [r for r in norm if !isempty(r)]
end

function consolidate!(rs)
    rs′ = []
    println("sorting...")
    rs1 = [[r.start, r.stop] for r in rs]
    sort!(rs1)
    for i in 1:length(rs)
        a, b = rs1[i]
        rs[i] =a:b
    end
    # rs = [a:b for (a, b) in rs1]
    # rs = sort!(rs)
    empty_range = 1:0
    for i in 1:length(rs)
        r1 = rs[i]
        # println(r1)
        isempty(r1) && continue
        # println("$i: $r1")
        for j in i+1:length(rs)
            # r1 = rs[i]
            r2 = rs[j]
            # println("  $r2")
            isempty(r2) && continue
            # println("  $j: $r2")
            # cont, r = ranges_contiguous′(r1, r2)
            # if cont
            if r1.stop >= r2.start
                rs[i] = r1.start:max(r1.stop, r2.stop)
                r1 = rs[i]
                # println("    old: $r2, new: $(rs[i])")
                rs[j] = empty_range
                # println("    right: $(rs)")
            end
        end
    end
    is = [i for i in 1:length(rs) if isempty(rs[i])]
    deleteat!(rs, is)
    # println("$rs, $([r for r in rs if !isempty(r)])")
    return rs
end

function part2(data)
    data, _ = data
    # length(Set(vcat(data...)))  # works on small input
    # data = [1:3, 2:8, 7:10]
    # println(_simplify_ranges(data))
    # println(consolidate0(data))
    # println(sum(length(a:b) for (a, b) in consolidate0(data)))
    # println("len: $(length(data))")
    consolidate!(data)
    # println(data)
    return sum(length, data)
    # return sum(length, simplify_ranges(data))
    #=c = IterTools.chain(data...)
    d = IterTools.distinct(c)
    r = 0
    for x in d
        r += 1
    end
    r=#
    # sum(1 for _ in d)
    #=sort!(data)
    count = 0
    prev_stop = -1
    for r in data
        start, stop = r.start, r.stop
        if stop > prev_stop
            count += stop - max(start - 1, prev_stop)
        end
    end
    return count=#
    #=data = [1:3, 2:8, 7:10]
    count = 0
    for i in 1:length(data)-1
        for j in i+1:length(data)
            i == j && continue
            r1, r2 = data[i], data[j]
            int = r1 ∩ r2
            count += length(r1) + length(r2) - length(int)
        end
    end
    return count=#
end


### Main ###

function main()
    data = parse_input("data05.txt")
    # data = parse_input("data05.test.txt")
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
