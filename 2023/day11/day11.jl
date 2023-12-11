# Copied some BFS code from 2022 day12

using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
using Combinatorics
using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

function parse_input(input_file::String)
    return readlines_into_char_matrix(input_file)
    L = readlines(input_file)
    return L
end

rows_no_galaxies(data) = [i for (i, r) in enumerate(eachrow(data)) if all(==('.'), r)]
cols_no_galaxies(data) = [i for (i, r) in enumerate(eachcol(data)) if all(==('.'), r)]

function expand_galaxy(data, n = 1)
    rs, cs = rows_no_galaxies(data), cols_no_galaxies(data)
    ro, co = 0, 0
    for ri in rs
        data = cat(data[1:ri+ro, :], fill('.', n, size(data, 2)), data[ri+ro+1:end, :], dims = 1)
        ro += 1
    end
    for ci in cs
        data = cat(data[:, 1:ci+co], fill('.', size(data, 1), n), data[:, ci+co+1:end], dims = 2)
        co += 1
    end
    return data
end

find_galaxies(data::Matrix{Char}) = findall(i -> data[i] == '#', CartesianIndices(data))
galaxy_pairs(galaxies::Vector{CartesianIndex{2}}) = combinations(galaxies, 2)
galaxy_pairs(data::Matrix{Char}) = galaxy_pairs(find_galaxies(data))

# SLOOWWWWWW
function _bfs_core(data::Matrix{Char}, target, Q::Queue{Tuple{CartesianIndex{2}, Int}}, S::Set{CartesianIndex{2}})
    directions = cardinal_directions(2)
    while !isempty(Q)
        i, v = dequeue!(Q)
        i ∈ S && continue
        push!(S, i)
        if i == target
            return v
        end
        for d in directions
            j = i + d
            hasindex(data, j) || continue
            # TODO: optimise somehow??
            enqueue!(Q, (j, v + 1))
        end
    end
end

function find_shortest_path(g1, g2, data)
    Q = Queue{Tuple{CartesianIndex{2}, Int}}()
    enqueue!(Q, (g1, 0))
    S = Set{CartesianIndex{2}}()
    return _bfs_core(data, g2, Q, S)
end

function part1(data)
    data = expand_galaxy(data)
    res = 0
    for (g1, g2) in galaxy_pairs(data)
        res += find_shortest_path(g1, g2, data)
    end
    return res
end


### Part 2 ###

function part2(data)
    rs, cs = rows_no_galaxies(data), cols_no_galaxies(data)
    n = 10
    n = 1_000_000

    res = 0
    for (g1, g2) in galaxy_pairs(data)
        (g1y, g1x), (g2y, g2x) = g1.I, g2.I

        ax, bx = min(g1x, g2x), max(g1x, g2x)
        ay, by = min(g1y, g2y), max(g1y, g2y)

        # https://www.reddit.com/r/adventofcode/comments/18fmrjk/comment/kcv853i/
        res += (by - ay) + length(rs ∩ (ay:by))*(n - 1)
        res += (bx - ax) + length(cs ∩ (ax:bx))*(n - 1)
    end

    return res


    n = 1_000_000
    n = 10
    # n = 100
    data = expand_galaxy(data, n - 1)
    res = 0
    for (g1, g2) in galaxy_pairs(data)
        sp = find_shortest_path(g1, g2, data)
        # println("g1: $g1, g2: $g2, sp: $sp")
        res += sp
    end
    return res
end

function main()
    data = parse_input("data11.txt")
    # data = parse_input("data11.test.txt")
    # println(expand_galaxy(readlines_into_char_matrix("data11.test.txt")) == readlines_into_char_matrix("data11.test.expected.txt"))

    # Part 1
    part1_solution = part1(data)
    println("Part 1: $part1_solution")
    # @assert part1_solution == 9742154

    # Part 2
    part2_solution = part2(data)
    println("Part 2: $part2_solution")
    # @assert part2_solution == 411142919886
end

main()
