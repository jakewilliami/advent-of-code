# Our data is in an interesting format, where the first line of the
# input is a starting set of "seed values", and the remaining lines
# are groups of funcions we must apply to the seed values.  The
# functions consist of ranges of mappings, such that a seed is mapped
# to a soil value; a soil is mapped to a fertiliser value; and so on
# and so forth.
#
# Part 1 of the problem asks us to apply the mappings for each seed in
# the original input.  This was straight forward, easy to brute force
# (though since original implementation I have cleaned up the solution
# a bit), and I actually did the best I've ever done on part 1 (I got
# placed just over 800th on the global leaderboard which is cool).
#
# Part 2 was *hard*.  Instead of the top line of the input being individual
# seed values, they represented ranges of values.  Ranges large enough
# for brute force not to be an option.  I had to use interval sets, and
# account for different intersections/overlap between the input ranges,
# the source range in the mappings, and the destination range.  My part 2
# solution is inspired by others I read as I needed a nudge in order to
# solve it.

using IntervalSets

struct IntervalRange
    src::ClosedInterval
    dst::ClosedInterval
end

struct HorticultureMap
    desc::AbstractString
    maps::Vector{IntervalRange}
end

function parse_input(input_file::String)
    A = split(read(input_file, String), "\n\n")
    seeds_str = popfirst!(A)
    seeds = [parse(Int, a) for a in split(last(split(seeds_str, ": ")))]

    B = HorticultureMap[]
    for a in A
        b = split(a, "\n")
        X = []
        for c in b[2:end]
            if !isempty(strip(c))
                d, s, l = parse.(Int, split(c))
                i1 = s .. (s + l)
                i2 = d .. (d + l)
                push!(X, IntervalRange(i1, i2))
            end
        end
        push!(B, HorticultureMap(b[1][1:end-1], X))
    end

    return seeds, B
end

function src_to_dst(M::HorticultureMap, n::Int)
    for m in M.maps
        ss, ds = leftendpoint(m.src), leftendpoint(m.dst)
        if n ∈ m.src
            return ds - ss + n
        end
    end
    return n
end

function src_to_dst!(V::Vector{Int}, M::HorticultureMap)
    for i in eachindex(V)
        V[i] = src_to_dst(M, V[i])
    end
    return V
end

function part1(seeds::Vector{Int}, M::Vector{HorticultureMap})
    for m in M
        src_to_dst!(seeds, m)
    end
    return minimum(seeds)
end

function parse_seeds(seeds::Vector{Int})
    A = ClosedInterval[]
    for i in 1:2:(length(seeds)-1)
        j = seeds[i]..(seeds[i]+seeds[i+1]-1)
        push!(A, j)
    end
    return A
end

function map_values!(R::Vector{ClosedInterval}, M::HorticultureMap)
    A = ClosedInterval[]
    for m in M.maps
        ss, se = endpoints(m.src)
        ds, de = endpoints(m.dst)
        offset = ds - ss

        NR = ClosedInterval[]
        while length(R) > 0
            r = pop!(R)
            rs, re = endpoints(r)

            before = rs..min(re, ss)
            i = r ∩ m.src
            is, ie = endpoints(i)
            intersection = is+offset..ie+offset
            after = max(se, rs)..re

            isempty(before) || push!(NR, before)
            isempty(i)      || push!(A, intersection)
            isempty(after)  || push!(NR, after)
        end
        append!(R, NR)
    end
    append!(R, A)
    return R
end

function part2(seeds::Vector{Int}, M::Vector{HorticultureMap})
    seeds = parse_seeds(seeds)
    S = Int[]
    for s in seeds
        R = ClosedInterval[s]
        for m in M
            map_values!(R, m)
        end
        push!(S, minimum(leftendpoint.(R)))
    end
    return minimum(S)
end

function main()
    seeds, horticulture_maps = parse_input("data05.txt")

    # Part 1
    part1_solution = part1(copy(seeds), horticulture_maps)
    @assert part1_solution == 107430936
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(copy(seeds), horticulture_maps)
    @assert part2_solution == 23738616
    println("Part 2: $part2_solution")
end

main()
