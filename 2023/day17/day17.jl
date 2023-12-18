# found it very hard to debug priority queue when i've not actually used the data structure before so i had no idea if

using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    M = readlines_into_int_matrix(input_file)
    return M
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end

function part1(data)
    si, ei = CartesianIndex{2}(), last(CartesianIndices(data))
end

function allowed_turns(d)
    return (rotl90(d), rotr90(d), d)
    i = origin(2)
    rd = CartesianIndex(reverse(d.I))
    return (i - rd, i + rd, d)
end

# enqueue!(h::BinaryMinHeap, x) = push!(h, x)
# enqueue!(h::BinaryMinHeap, x, _y) = push!(h, x)
# dequeue!(h::BinaryMinHeap) = popmin!(h)

function _bfs_core(data, end_i)
    Q = PriorityQueue{Any, Int}()
    # Q = BinaryMinHeap{Any}()
    # start_i = CartesianIndex{2}()
    # for d in (INDEX_RIGHT, INDEX_BELOW)
        # enqueue!(Q, (start_i, data[start_i], d, 1, [(start_i, d)]), 0)
    # end

    # index, cumulative heat loss, direction, number of straight moves, path
    # for (i, d) in ((CartesianIndex(1, 2), INDEX_RIGHT), (CartesianIndex(2, 1), INDEX_BELOW))
    for d in (INDEX_RIGHT, INDEX_BELOW)
        i = CartesianIndex{2}() + d
        enqueue!(Q, (i, d, 1, [(i, d)]), data[i])
    end
    # println(Any[(t[1], t[3]) for (t, _) in Q])
    #=for d in (INDEX_RIGHT, INDEX_BELOW)
        si = CartesianIndex{2}()
        j = si + d
        enqueue!(Q, (j, data[j], d, 1, [(j, d)]), data[j])
    end=#
    # si = CartesianIndex{2}()
    # d = INDEX_RIGHT
    # j = si + d
    # enqueue!(Q, (j, data[j], d, 1, [(j, d)]), data[j])
    # enqueue!(Q, (si, 0, INDEX_RIGHT, 0, []), 0)
    # enqueue!(Q, (si, 0, INDEX_DOWN, 0, []), 0)
    S = Set()
    D = Dict()

    while !isempty(Q)
        # println(Q)
        # println(Any[(t[1], t[3]) for (t, _) in Q])
        (i, d0, dn, path), v = dequeue_pair!(Q)
        # i ∈ S && continue
        # push!(S, i)
        (i, d0, dn) in keys(D) && continue
        D[(i, d0, dn)] = v
        if i == end_i
            return path, v, D
        end
        for d in cardinal_directions(2)
            # 3 in one way max
            dn1 = d0 == d ? dn + 1 : 1
            dn1 <= 3 || continue
            # only left/right/straight turns
            d in (allowed_turns(d0)) || continue
            j = i + d
            hasindex(data, j) || continue
            # enqueue!(Q, (j, v + data[j], d, dn1), v + data[j])
            # only increment energy when you enter a new index
            nv = v + data[j]
            new_path = push!(copy(path), (j, d))
            enqueue!(Q, (j, d, dn1, new_path), nv)
        end
    end
end

function d_char(d)
    d == INDEX_RIGHT && return '>'
    d == INDEX_BELOW && return 'v'
    d == INDEX_ABOVE && return '^'
    d == INDEX_LEFT && return '<'
    error("invalid direction $d")
end

function dis(M, path)
    M2 = Matrix{Any}(undef, size(M))
    for i in CartesianIndices(M2)
        found = false
        for (j, d) in path
            if i == j
                M2[j] = d_char(d)
                found = true
                break
            end
        end
        if !found
            M2[i] = M[i]
        end
    end
    println()
    println(join((join(r) for r in eachrow(M2)), '\n'))
    println()
end


function part1(data)
    path, v, D = _bfs_core(data, last(CartesianIndices(data)))

    for i in path
        # println(i)
    end

    # dis(data, path)

    return v
end

function _bfs_core2(data, end_i)
    Q = PriorityQueue{Any, Int}()

    # index, cumulative heat loss, direction, number of straight moves, path
    # for (i, d) in ((CartesianIndex(1, 2), INDEX_RIGHT), (CartesianIndex(2, 1), INDEX_BELOW))
    for d in (INDEX_RIGHT, INDEX_BELOW)
        i = CartesianIndex{2}() + d
        enqueue!(Q, (i, d, 1, [(i, d)]), data[i])
    end
    D = Dict()

    while !isempty(Q)
        # println(Q)
        # println(Any[(t[1], t[3]) for (t, _) in Q])
        (i, d0, dn, path), v = dequeue_pair!(Q)
        (i, d0, dn) in keys(D) && continue
        D[(i, d0, dn)] = v
        if i == end_i
            return path, v, D
        end
        for d in cardinal_directions(2)
            # 3 in one way max
            dn1 = d0 == d ? dn + 1 : 1
            # (dn1 <= 4 || d != d0) && continue

            # TODO: "even before it can stop at the end"
            (dn1 <= 10 && (d == d0 || dn >= 4)) || continue


            # dn1 <= 10 || continue
            # (dn == d0 && dn1 >= 4) || continue

            # max distance in same direction
            # dn1 <= 10 || continue

            # min distance in one direction
            # 4 < dn1 && d != d0 && continue
            # 4 <

            # dn1 <= 3 || continue

            # (dn1 <= 10 && (d == d0 || dn1 > 4)) || continue
            #=if dn1 <= 4 && d != d0
                continue
            end
            dn1 <= 10 || continue
            if 4 < dn1 <= 10
            end=#
            d in (allowed_turns(d0)) || continue
            # only left/right/straight turns
            j = i + d
            hasindex(data, j) || continue

            # "even before it can stop at the end"
            (j == end_i && dn1 < 4) && continue

            # enqueue!(Q, (j, v + data[j], d, dn1), v + data[j])
            # only increment energy when you enter a new index
            nv = v + data[j]
            new_path = push!(copy(path), (j, d))
            enqueue!(Q, (j, d, dn1, new_path), nv)
        end
    end
end

function part2(data)
    path, v, D = _bfs_core2(data, last(CartesianIndices(data)))

    # dis(data, path)

    return v
end

function main()
    data = parse_input("data17.txt")
    # data = parse_input("data17.test.txt")
    # data = parse_input("data17.test2.txt")
    # println(data)

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution == 771
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution == 930
    println("Part 2: $part2_solution")
    # not 927 too low
    # not 930 too low
    # not 931 too high
end

main()
