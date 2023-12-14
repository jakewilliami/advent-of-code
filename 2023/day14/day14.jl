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
    M = readlines_into_char_matrix(input_file)
    @assert all(c -> c in ("O#."), M)
    return M
    # S = read(input_file, String)
    # L = readlines(input_file)
    # L = get_integers.(L)
    return L
end

function dis(M)
    println(join(join.(eachrow(M)), "\n"))
end

function g!(M, d)
    moved = false
    for i in CartesianIndices(M)
        c1 = M[i]
        c1 == 'O' || continue
        j = i + d
        hasindex(M, j) || continue
        c2 = M[j]
        if c2 == '.'
            M[j] = c1
            M[i] = '.'
            moved = true
        end
    end
    return moved
end

function f!(M, d)
    while true
        g!(M, d) || break
    end
    return M
end

function score(M)
    res = 0
    for (i, row) in enumerate(eachrow(M))
        j = size(M, 1) - i + 1
        # println(j)
        # println(row)
        # println(sum(c == 'O' for c in row))
        res += sum(c == 'O' for c in row) * j
    end
    return res
end

function part1(data)
    M = copy(data)
    f!(M, INDEX_ABOVE)
    return score(M)
end

function f2!(M)
    for d in [INDEX_ABOVE, INDEX_LEFT, INDEX_BELOW, INDEX_RIGHT]
        f!(M, d)
    end
    return M
end

function h!(M)
    # TODO: cardinal_directions
    seen = [hash(M)]
    si = ei = 0
    for i in 1:1_000_000_000
        f2!(M)
        h = hash(M)

        if h in seen
            si = findfirst(==(h), seen) - 1
            ei = i
            break
        else
            push!(seen, h)
        end
    end

    cycle_length = ei - si
    rem_cycles = 1_000_000_000 - si

    # 3 10 7 999999997 3
    # 10 38 28 999999990 10
    println("$si $ei $cycle_length $rem_cycles $(mod(rem_cycles, cycle_length))")

    for i in 1:mod(rem_cycles, cycle_length)
        f2!(M)
    end

    # dis(M)

    return score(M)
end

function oldh!(M)
    # TODO: cardinal_directions
    directions = [INDEX_ABOVE, INDEX_LEFT, INDEX_BELOW, INDEX_RIGHT]
    seen = [hash(M)]
    si = ei = 0
    last_d = INDEX_ABOVE
    for i in 1:1_000_000_000
        d = directions[mod1(i, 4)]
        f!(M, d)
        h = hash(M)

        if h in seen
            si = findfirst(==(h), seen) - 1
            ei = i
            last_d = d
            break
        else
            push!(seen, h)
        end
    end

    cycle_length = ei - si
    rem_cycles = 1_000_000_000 - si

    # 3 10 7 999999997 3
    # 10 38 28 999999990 10
    println("$si $ei $cycle_length $rem_cycles $(mod(rem_cycles, cycle_length))")

    di = findfirst(==(last_d), directions)
    for i in 1:mod(rem_cycles, cycle_length)
        d = directions[mod1(i + di, 4)]
        f!(M, d)
    end

    # dis(M)

    return M
end

function part2(data)
    M = copy(data)
    h!(M)
    return score(M)
end

function main()
    data = parse_input("data14.txt")
    # data = parse_input("data14.test.txt")
    # println(data)

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 109665
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 96061
    println("Part 2: $part2_solution")
end

main()
