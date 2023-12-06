# TODO

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
        if n ∈ m.src
            return leftendpoint(m.dst) + (n - leftendpoint(m.src))
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

function process_values!(R::Vector{ClosedInterval}, M::HorticultureMap)
    A = ClosedInterval[]
    for m in M.maps
        NR = ClosedInterval[]
        while length(R) > 0
            r = pop!(R)
            i = r ∩ m.src
            before = leftendpoint(r)..min(rightendpoint(r), leftendpoint(m.src))
            after = max(rightendpoint(m.src), leftendpoint(r)) .. rightendpoint(r)
            width(before) > 0 && push!(NR, before)
            # TODO: pm?
            width(i) > 0 && push!(A, leftendpoint(i)-leftendpoint(m.src)+leftendpoint(m.dst)..rightendpoint(i)-leftendpoint(m.src)+leftendpoint(m.dst))
            width(after) > 0 && push!(NR, after)
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
            process_values!(R, m)
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
