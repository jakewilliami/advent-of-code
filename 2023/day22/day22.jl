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
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    L = get_integers.(L)
    @assert all(length(l) == 6 for l in L)
    L = [(l[1:3], l[4:6]) for l in L]
    L = [(CartesianIndex(a...), CartesianIndex(b...)) for (a, b) in L]
    L = [a:b for (a, b) in L]
    return L
end

function down(dim)
    return CartesianIndex(1, [0 for _ in 1:(dim - 1)]...)
end

function add_d_to_rng(r, d)
    return (first(r) + d):(last(r) + d)
end

vert(p::CartesianIndex) = first(Tuple(p))
verts(r::CartesianIndices) = Set(vert(i) for i in r)

function vert_range1(r)
    a, b = extrema(r)
    return vert(a), vert(b)
end

function vert_range(positions)
    a, b = extrema(Base.Iterators.flatten(vert_range1(r) for r in positions))
    return a:b
end

function min_vert(r)
    a, b = vert_range1(r)
    return min(a, b)
end

function any_below(r, positions)
    # vs = Set(vert(r) for r in p)
    # a, _b = vert_range1(p)
    v0 = min_vert(r)
    for (i ,r1) in enumerate(setdiff(positions, r))
        if min_vert(r1) == (v0 - 1)
            return true
        end
    end
    return false


    for i in 1:length(positions)
        positions[i] == p && continue
        # if any(vert(positions[i]) == (vert(r) - 1) for r in positions[i])
        if any(vert(r) in vs for r in positions[i])
            return true
        end
    end
    return false
end

function new_pos(p, d, positions)
    if any(==(1), verts(p)) || any_below(p, positions)
        return p
    end
    return add_d_to_rng(p, d)
end

function fall!(positions)
    d = down(3)
    for vi in vert_range(positions)
        for (i, r) in enumerate(positions)
            if vi == min_vert(r)
                positions[i] = new_pos(r, d, positions)
            end
        end
    end
    return positions

    d = down(3)
    for i in 1:length(positions)
        if any(vert(r) == 1 for r in positions[i]) || any_below(positions[i], positions)
            continue
        end
        positions[i] = add_d_to_rng(positions[i], d)
    end
end

function has_fallen(positions)


    for r in positions
        # vs = Set(vert(i) for i in r)
        # vs = union(Set(vert(i) + 1 for i in r), Set(vert(i) - 1 for i in r))
        # vs = verts()
        v = min_vert(r)
        for r2 in setdiff(positions, r)
            vs2 = Set(vert(i) for i in r2)
            # if !(v2 in (v+1, v-1))
            if !any(v in vs for v in vs2)
            # if !()
                return false
            end
        end
    end
    return true
    for r in positions
        if any(vert(i) == 1 for i in r)
            return true
        end
    end
    return false
end

function count_disintegratable(positions)
    ans = 0
    for i in 1:length(positions)
        P = copy(positions)
        deleteat!(P, i)
        if has_fallen(P)
            ans += 1
        end
    end
    return ans
    # positions = copy()
end

function extrema1(V)
    V1 = extrema.(V)
    return extrema(Base.Iterators.flatten(V1))
end

function part1(data)
    positions = [r for r in data]
    prev_pos = copy(positions)
    while true
        fall!(positions)
        println(positions)
        if has_fallen(positions) #|| positions == prev_pos
            break
        end
        prev_pos = copy(positions)
    end
    return count_disintegratable(positions)
end

function part2(data)
end

function main()
    data = parse_input("data22.txt")
    data = parse_input("data22.test.txt")
    println(data)

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
