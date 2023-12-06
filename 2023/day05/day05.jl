# TODO

using IntervalSets

struct IntervalRange
    src::ClosedInterval
    dst::ClosedInterval
end

struct HortMap
    desc::AbstractString
    maps::Vector{IntervalRange}
end

function parse_input(input_file::String)
    A = split(read(input_file, String), "\n\n")
    seeds_str = popfirst!(A)
    seeds = [parse(Int, a) for a in split(last(split(seeds_str, ": ")))]

    B = HortMap[]
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
        push!(B, HortMap(b[1][1:end-1], X))
    end

    # return re_parse_data((seeds, B))
    return seeds, B
end

function get_val(M::HortMap, n::Int)
    for m in M.maps
        if n ∈ m.src
            return leftendpoint(m.dst) + (n - leftendpoint(m.src))
        end
    end
    return n
end

function process_values(M::HortMap, values)

    V = []
    for v in values
        push!(V, get_val(M, v))
    end
    return V
end

function part1(data)
    seeds, A = data
    V = seeds
    for a in A
        V = process_values(a, V)
    end
    return minimum(V)



    V, A = data
    for a in A
        V = process_values(a, V)
    end
    return minimum(V)
end

function parse_seeds(seeds)
    A = []
    for i in 1:2:(length(seeds)-1)
        j = seeds[i]..(seeds[i]+seeds[i+1]-1)
        push!(A, j)
    end
    return A
end

function src_to_dst(M::HortMap, n::Int)
    for m in M.maps
        if n ∈ m.src
            return leftendpoint(m.dst) + (n - leftendpoint(m.src)) + 1
        end
    end
    return n
end

function interval_except(i1, i2)
    return leftendpoint(i1)..leftendpoint(i2), rightendpoint(i2)..rightendpoint(i1)
end

function process_values!(R, M)
    A = []
    for m in M.maps
        NR = []
        while length(R) > 0
            r = pop!(R)
            i = r ∩ m.src
            # dst = src_to_dst(M, leftendpoint(i)) .. src_to_dst(M, rightendpoint(i))
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
end

function part2(data)
    seeds, M = data
    seeds = parse_seeds(seeds)


    S = []
    for s in seeds
        R = [s]
        for m in M
            process_values!(R, m)
        end
        push!(S, minimum(leftendpoint.(R)))
    end
    return minimum(S)
end

function main()
    data = parse_input("data05.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 107430936
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 23738616
    println("Part 2: $part2_solution")
end

main()
