using IntervalSets

struct WeirdRange
    dest_start::Int
    source_start::Int
    range_length::Int
end

struct WeirdRange2
    source::ClosedInterval
    dest::ClosedInterval
end

struct HortMap
    desc::AbstractString
    maps::Vector{WeirdRange}
end

struct HortMap2
    desc::AbstractString
    maps::Vector{WeirdRange2}
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
                push!(X, WeirdRange(parse.(Int, split(c))...))
            end
        end
        push!(B, HortMap(b[1][1:end-1], X))
    end

    return seeds, B
end

function get_val(M::HortMap, n::Int)
    for m in M.maps
        for i in 0:(m.range_length - 1)
            if n == (m.source_start + i)
                return m.dest_start + i
            end
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
    V, A = data
    for a in A
        V = process_values(a, V)
    end
    return minimum(V)
end

function part2_naive(data)
    V1, A = data
    V = []
    for i in 1:2:(length(V1)-1)
        for v in V1[i]:(V1[i]+V1[i+1]-1)
            push!(V, v)
        end
    end
    println(V)
    for a in A
        V = process_values(a, V)
    end
    return minimum(V)
end

function get_min(R::Vector{WeirdRange})
    m = nothing
    out = nothing
    for r in R
        if isnothing(m) || m < r.dest_start
            m = r.dest_start
            out = r
        end
    end
    return out
end

function get_min(M::HortMap)
    return get_min(M.maps)
end

function parse_seeds(seeds)
    A = []
    for i in 1:2:(length(seeds)-1)
        j = seeds[i]..(seeds[i]+seeds[i+1]-1)
        push!(A, j)
    end
    return A
end

function re_parse_data(data)
    seeds, A = data
    B = []
    for a in A
        M = []
        for m in a.maps
            i1 = m.dest_start..(m.dest_start+m.range_length)
            i2 = m.source_start..(m.source_start+m.range_length)
            push!(M, WeirdRange2(i2, i1))
        end
        push!(B, HortMap2(a.desc, M))
    end
    seeds = parse_seeds(seeds)
    # seeds = []
    return seeds, B
end

function src_to_dst(M::HortMap2, n::Int)
    for m in M.maps
        if n ∈ m.source
            return leftendpoint(m.dest) + (n - leftendpoint(m.source)) + 1
        end
    end
    return n
end

function perform_thing(seeds, A)
    function process_values(M::HortMap2, values)
        function get_val(M::HortMap2, n::Int)
            for m in M.maps
                if n ∈ m.source
                    return leftendpoint(m.dest) + (n - leftendpoint(m.source)) + 1
                end
            end
            return n
        end
        V = []
        for v in values
            push!(V, get_val(M, v))
        end
        return V
    end

    V = seeds
    for a in A
        V = process_values(a, V)
    end
    return V
end

function interval_except(i1, i2)
    return leftendpoint(i1)..leftendpoint(i2), rightendpoint(i2)..rightendpoint(i1)
end

function map_source_range!(ranges, r, M::HortMap2)
    for m in M.maps
        i = r ∩ m.source
        width(i) == 0 && continue
        dst = src_to_dst(M, leftendpoint(i)) .. src_to_dst(M, rightendpoint(i))
        push!(ranges, dst)

        i == r && return ranges
        for r2 in interval_except(r, i)
            map_source_range!(ranges, r2, M)
        end
        # append!(inputs, interval_except(r, i))
    end

    push!(ranges, r)
    return ranges
end

function part2(data)
    seeds, A = re_parse_data(data)

    R = []
    for r in seeds
        for m in A
            # println(m)
            map_source_range!(R, r, m)
        end
    end
    println()
    println(minimum(leftendpoint.(R)))

    return 0

    # error("Not yet implemented")

    # for R in seeds
        # for n in range(R)

        # end
    # end

    R = []
    while length(seeds) > 0
        r = pop!(seeds)
        l1 = length(R)
        for a in A
            # a ∩ b
        end
    end

    # return 0
    function apply_range(R, a)
        A = []
        for m in a.maps
            src_start = leftendpoint(m.source)
            src_end = rightendpoint(m.source)
            NR = []
            while R
                # [st                                     ed)
                #          [src       src_end]
                # [BEFORE ][INTER            ][AFTER        )
                r = pop!(R)
                int = r ∩ m.source
                before = leftendpoint(r) .. leftendpoint(int)
                after = rightendpoint(int) .. rightendpoint(r)
            end
        end
    end

    # A = []
    B = []
    for a in A
        for m in a.maps

        end
    end


    return 0

    V = seeds
    for a in A
        function process_values(M::HortMap2, values)
            function get_val(M::HortMap2, n::Int)
                for m in M.maps
                    if n ∈ m.source
                        return leftendpoint(m.dest) + (n - leftendpoint(m.source)) + 1
                    end
                end
                return n
            end
            V = []
            for v in values
                push!(V, get_val(M, v))
            end
            return V
        end
        V = process_values(a, V)
    end
    return minimum(V)


    return 0
    # TODO: work backwards?
    println(typeof(data[2]))
    for d in data[2]
        println(d.desc)
        println("    ", get_min(d))
    end
    println(get_min(data[2]))
    return 0

    # return 0
    V1, A = data
    V = []
    for i in 1:2:(length(V1)-1)
        for v in V1[i]:(V1[i]+V1[i+1]-1)
            push!(V, v)
        end
    end
    println(V)
    for a in A
        V = process_values(a, V)
    end
    return V
    return minimum(V)
end

function main()
    # data = parse_input("data05.txt")
    data = parse_input("data05.test.txt")
    # println(data[1])
    # println(data)
    # println(process_values(data[2][1], data[1]))

    # Part 1
    # part1_solution = part1(data)
    # @assert part1_solution ==
    # println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: \n$part2_solution")
end

main()
