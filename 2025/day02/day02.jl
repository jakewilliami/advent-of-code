# Description: what was the problem; how did I solve it; and (optionally)
# any thoughts on the problem or how I did.

#  ]add ~/projects/AdventOfCode.jl Statistics LinearAlgebra Combinatorics DataStructures StatsBase IntervalSets OrderedCollections MultidimensionalTools
# using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections
# using MultidimensionalTools


### Parse Input ###

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    # S = strip(read(input_file, String))
    L = only(string.(strip.(readlines(input_file))))
    A = string.(split(L, ','))
    R = [parse.(Int, split(l, '-')) for l in A]
    Q = [a:b for (a, b) in R]
    return Q
    # L = get_integers.(L)
    return L
end


### Part 1 ###

# Stolen:
#   github.com/jakewilliami/LinearShiftRegisters.jl/blob/c2c24a9d/src/LinearShiftRegisters.jl#L5-L31
function _repeated_substring(source)
    len = length(source)

    # had to account for weird edge case in which length 2 vectors always returns themselves
    if len < 3
        len == 1 && return nothing

        s1, s2 = source
        if len == 2 && s1 == s2
            return s1
        else
            return nothing
        end
    end

    # Check candidate strings
    for i in 1:(len ÷ 2 + 1)
        repeat_count, remainder = divrem(len, i)

        # Check for no leftovers characters, and equality when repeated
        if remainder == 0 && source == repeat(source[1:i], repeat_count)
            return source[1:i]#, repeat_count
        end
    end

    return nothing
end

function is_valid_num(n::Int)
    s = string(n)
    r = _repeated_substring(s)
    if isnothing(r)
        return true
    end

    if count(r, s) != 2
        return true
    end

    # strip leading zeros # no it doesn't
    # if isodd(ndigits(parse(Int, r)))
        # return true
    # end

    return false
end

function split_string_in_half(s::String)
    if isodd(length(s))
        return nothing ## cannot split in half
    end
    return string(s[1:length(s)÷2]), string(s[length(s)÷2+1:end])
end

function is_valid_2(n::Int)
    s = string(n)
    r = split_string_in_half(s)

    if isnothing(r)
        return true
    end

    a, b = r
    if a == b
        return false
    end

    return true
end

function part1(data)
    res = 0
    for rng in data
        for n in rng
            if !is_valid_2(n)
                # println(n)
                res += n
            end
        end
    end
    return res
end


### Part 2 ###

function is_valid_3(n::Int)
    s = string(n)
    r = _repeated_substring(s)
    if isnothing(r)
        return true
    end

    if count(r, s) >= 2
        return false
    end

    return true
end

function part2(data)
    res = 0
    for rng in data
        for n in rng
            if !is_valid_3(n)
                # println(n)
                res += n
            end
        end
    end
    return res
end


### Main ###

function main()
    data = parse_input("data02.txt")
    # data = parse_input("data02.test.txt")
    # println(data)

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution == 23560874270 # done in about 15--20 mins
    # 23388708624 too low
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    # did this one 3 minutes later because of the code I stole from an earlier project
    println("Part 2: $part2_solution")
end

main()
