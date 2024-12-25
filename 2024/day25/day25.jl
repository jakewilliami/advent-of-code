using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

abstract type LockSchematic end

struct KeySchematic <: LockSchematic
    columns::Vector{Int}  # column heights
    height::Int

    function KeySchematic(columns::Vector{Int}, height::Int)
        @assert length(columns) == 5
        return new(columns, height)
    end
end

function KeySchematic(M::Matrix{Char})
    columns = Vector{Int}(undef, 5)

    nr = size(M, 1)
    for (i, col) in enumerate(eachcol(M))
        columns[i] = count(==('#'), col) - 1
        @assert columns[i] + count(==('.'), col) + 1 == nr
    end

    height = nr - 2  # subtract base on top and bottom
    return KeySchematic(columns, height)
end

struct PinSchematic <: LockSchematic
    columns::Vector{Int}  # pin heights
    height::Int

    function PinSchematic(columns::Vector{Int}, height::Int)
        @assert length(columns) == 5
        return new(columns, height)
    end
end

function PinSchematic(M::Matrix{Char})
    columns = Vector{Int}(undef, 5)

    nr = size(M, 1)
    for (i, col) in enumerate(eachcol(M))
        columns[i] = count(==('#'), col) - 1
        @assert columns[i] + count(==('.'), col) + 1 == nr
    end

    height = nr - 2  # subtract base on top and bottom
    return PinSchematic(columns, height)
end

function is_key_schematic(M::Matrix{Char})
    if all(==('#'), M[end, :])
        @assert all(==('.'), M[1, :])
        return true
    end
    return false
end
function is_pin_schematic(M::Matrix{Char})
    if all(==('#'), M[1, :])
        @assert all(==('.'), M[end, :])
        return true
    end
    return false
end

function LockSchematic(M::Matrix{Char})::LockSchematic
    if is_key_schematic(M)
        return KeySchematic(M)
    elseif is_pin_schematic(M)
        return PinSchematic(M)
    else
        error("undefined")
    end
end

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    S = strip(read(input_file, String))
    Ss = split(S, "\n\n")
    Ms = Matrix{Char}[Parsing._lines_into_matrix(split(s, '\n')) for s in Ss]
    Ks = KeySchematic[]
    Ps = PinSchematic[]
    for M in Ms
        if is_key_schematic(M)
            push!(Ks, KeySchematic(M))
        elseif is_pin_schematic(M)
            push!(Ps, PinSchematic(M))
        else
            error("undefined")
        end
    end
    return Ks, Ps
    # L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end

function compatible(key::KeySchematic, pins::PinSchematic)
    # println(key)
    # println(pins)
    @assert length(key.columns) == length(pins.columns)
    @assert key.height == pins.height
    for i in 1:length(key.columns)
        ck, cp = key.columns[i], pins.columns[i]
        ck′ = key.height - ck
        # println("  $ck′, $cp")
        # ck′ == cp || return false
        ck′ ≥ cp || return false
    end
    # println("  good")
    return true
end

function part1(data)
    Ks, Ps = data
    # println(Ks[1])
    # println(Ks[3])
    # return compatible(Ks[1], Ps[1])
    r = 0
    for p in Ps, k in Ks
        # println("$(k), $(p), $(compatible(k, p))")
        r += compatible(k, p)
    end
    r
end

function part2(data)
    # Ms, Ks = data
end

function main()
    data = parse_input("data25.txt")
    # data = parse_input("data25.test.txt")

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
