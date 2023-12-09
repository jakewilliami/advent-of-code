# using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

function parse_input(input_file::String)
    # L = get_integers.(readlines(input_file))
    L = [parse.(Int, split(l)) for l in readlines(input_file)]
    return L
    return collect(zip(L, gcd.(L)))
end

function calc_new_row(row)
    return [row[i] - row[i - 1] for i in 2:length(row)]
    return eltype(row)[row[i] - row[i - 1] for i in 2:length(row)]
end

function fill_table(row)
    table = [row]
    while !all(iszero, row)
        row = calc_new_row(row)
        push!(table, row)
    end
    return table
end

function extrapolate_table(table)
    table = deepcopy(table)
    push!(table[end], 0)
    for i in (length(table) - 1):-1:1
        a = table[i][end]
        c = table[i + 1][end]
        # println(i, " ", a, " ",c, " ",  table[i], table[i + 1])
        b = c + a
        push!(table[i], b)
    end
    return table
end

function extrapolate_backwards(table)
    table = deepcopy(table)
    pushfirst!(table[end], 0)
    for i in (length(table) - 1):-1:1
        b = table[i][1]
        c = table[i + 1][1]
        # println(i, " ", a, " ",c, " ",  table[i], table[i + 1])
        a = b - c
        pushfirst!(table[i], a)
    end
    return table
end

function first_extrapolation(row)
    full_table = fill_table(row)
    extrapolated = extrapolate_table(full_table)
    return last(first(extrapolated))
end

function part1(data)
    return sum(first_extrapolation(row) for row in data)
end

function part2(data)
    # println(extrapolate_backwards(fill_table(data[3])))
    # return 0
    res = 0
    for row in data
        full_table = fill_table(row)
        # extrapolated = extrapolate_table(full_table)
        # res += last(first(extrapolated))
        extr_back = extrapolate_backwards(full_table)
        res += first(first(extr_back))
    end
    return res
end

function main()
    data = parse_input("data09.txt")
    # data = parse_input("data09.test.txt")
    # println(data)

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 1987402313
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 900
    println("Part 2: $part2_solution")
end

main()

# not -328445473
