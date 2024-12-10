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
    M = readlines_into_int_matrix(input_file)
    return M
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end

function elevation_allowed(curr, next)
    (next - curr) == 1 || return false
    return true
end

# as long as possible and has an even, gradual, uphill slope

function starts(data)
    A = Set{CartesianIndex{ndims(data)}}()
    for i in CartesianIndices(data)
        if data[i] == 0
            push!(A, i)
        end
    end
    A
end

# from: 2022/day12/day12.jl
function _bfs_core(data::Matrix{Int}, Q::Queue{Tuple{CartesianIndex{2}, Set{CartesianIndex{2}}}})
    directions = cardinal_directions(2)
    n = 0
    while !isempty(Q)
        i, S = dequeue!(Q)
        i ∈ S && continue
        # println(i, ", ", data[i])
        push!(S, i)
        if data[i] == 9
            n += 1
            continue
        end
        for d in directions
            j = i + d
            hasindex(data, j) || continue
            if elevation_allowed(data[i], data[j])
                enqueue!(Q, (j, S))
            end
        end
    end
    return n
end

## I MISREAD THE EXPECTED OUTPUT I'M SO STUPID

function part1(data)

    r = 0
    for s in starts(data)
        Q = Queue{Tuple{CartesianIndex{2}, Set{CartesianIndex{2}}}}()
        # Q = Queue{Tuple{CartesianIndex{2}, Int}}()
        # S = Set{CartesianIndex{2}}()
        # enqueue!(Q, (s, 0))
        enqueue!(Q, (s, Set{CartesianIndex{2}}()))
        x = _bfs_core(data, Q)
        # println(x)
        r += x
        # enqueue!(Q, (s, 0))
    end
    r

    # _bfs_core(data, Q, S)
    # Q = Queue{CartesianIndex{N}}()
    # i = 0
end

function _bfs_core(data::Matrix{Int}, start::CartesianIndex{2})
    directions = cardinal_directions(2)
    Q = Queue{Tuple{CartesianIndex{2}, Vector{CartesianIndex{2}}}}()  # Queue to hold (current index, path)
    enqueue!(Q, (start, [start]))  # Start with the initial position and path
    unique_paths = Set{Vector{CartesianIndex{2}}}()  # To store unique paths to 9

    while !isempty(Q)
        current, path = dequeue!(Q)

        if data[current] == 9
            push!(unique_paths, path)  # Store the unique path to 9
            continue  # Continue to explore other paths
        end

        for d in directions
            next = current + d
            hasindex(data, next) || continue
            if elevation_allowed(data[current], data[next]) && !(next in path)
                enqueue!(Q, (next, push!(copy(path), next)))  # Add the next node to the path
            end
        end
    end

    # for
    return length(unique_paths)  # Return the count of unique paths reaching 9
end

function part2(data)
    r = 0
    for s in starts(data)
        # Q = Queue{Tuple{CartesianIndex{2}, Set{CartesianIndex{2}}}}()
        Q = Queue{Tuple{CartesianIndex{2}, Int}}()
        S = Set{CartesianIndex{2}}()
        # enqueue!(Q, (s, 0))
        # enqueue!(Q, (s, Set{CartesianIndex{2}}()))
        x = _bfs_core(data, s)
        # println(x)
        r += x
        # enqueue!(Q, (s, 0))
    end
    r
end

function main()
    data = parse_input("data10.txt")
    # data = parse_input("data10.test.txt")
    # data = parse_input("data10.test0.txt")

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
