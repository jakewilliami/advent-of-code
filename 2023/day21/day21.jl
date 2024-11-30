using AdventOfCode.Parsing, AdventOfCode.Multidimensional
using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

function parse_input(input_file::String)
    M = readlines_into_char_matrix(input_file)
    return M
    # S = strip(read(input_file, String))
    L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end

function allowed_positions(M, io)
    P = []
    for (i, c) in cardinal_adjacencies_with_indices(M, io)
        if c == '.' || c == 'S'
            push!(P, i)
        end
    end
    return P
end

function dis(M, seen)
    M2 = copy(M)
    for i in seen
        M2[i] = 'O'
    end
    println(join(join.(eachrow(M2)), "\n"))
end

function part1(data)
    data = copy(data)
    si = findfirst(i -> data[i] == 'S', CartesianIndices(data))
    plots = [i for i in CartesianIndices(data) if data[i] == '.']
    rocks = [i for i in CartesianIndices(data) if data[i] == '#']

    Q = Queue{Any}()
    enqueue!(Q, (Set([si]), 1))
    N = 64
    seen = Set()
    while !isempty(Q)
        I, k = dequeue!(Q)
        # k > N && continue
        # i in seen && continue
        # push!(seen, i)
        if k > N
            # dis(data, I)
            return length(I)
        end
        seen = Set(I)
        I2 = Set(Iterators.flatten(allowed_positions(data, i) for i in I))
        enqueue!(Q, (I2, k + 1))
        # for j in allowed_positions(data, i)
            # enqueue!(Q, (j, k + 1, Set()))
        # end
        # seen = Set(S)
    end
end

# is j in direction d of i?
# i.e., is there an n such that (n*d)+i = j
function in_direction(d, i, j)
    d == direction(j - i)
end

# find the direction we go to out of bounds of the array
function get_new_offset(M, i, j)
    hasindex(M, j) && return origin(2)

    # check corners
    for d in cartesian_directions(2)
        if in_direction(d, i, j)
            return d
        end
    end
end

function allowed_positions2(MO, io)
    P = []
    for d in cardinal_directions(MO, io)
        i = io + d
        if hasindex(MO, i)
            c = M[i]
            if c == '.' || c == 'S'
                push!(P, (i, d))
            end
        else
            # TODO: handle if out of bounds
            error("todo")
        end
    end
    return P
end

function part2(data)
    data = copy(data)
    si = findfirst(i -> data[i] == 'S', CartesianIndices(data))
    plots = [i for i in CartesianIndices(data) if data[i] == '.']
    rocks = [i for i in CartesianIndices(data) if data[i] == '#']

    Q = Queue{Any}()
    enqueue!(Q, (Set([(si, origin(2))]), 1))
    N = 26501365
    seen = Set()
    while !isempty(Q)
        I, k = dequeue!(Q)
        k > N && return length(I)

        I2 = Set()
        for (i, off) in I
            for P in allowed_positions2(data, i)
                for j in P
                    off2 = get_new_offset(data, i, j)
                    push!(I2, (j, off2))
                end
            end
        end

        # I2 = Set(Iterators.flatten(allowed_positions(data, i) for i in I))
        # enqueue!(Q, (I2, k + 1, Set()))
    end
    return length(seen)
end

function main()
    data = parse_input("data21.txt")
    data = parse_input("data21.test.txt")
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
