# easy but slow and recursion hard but necessary

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
    S = strip(read(input_file, String))
    S1, S2 = split(S, "\n\n")
    S1′ = split(S1, ", ")
    S2′ = split(S2, "\n")
    # S1 is towel options, S2 is target displays
    return S1′, S2′
    # L = strip.(readlines(input_file))
    # L = get_integers.(L)
    return L
end

function can_make_display_slow(target, options)
    # offset, found
    Q = Queue{Tuple{Int, Bool}}()
    for option in options
        option == target[1:length(option)] || continue
        found = target == option
        enqueue!(Q, (length(option) + 1, found))
    end
    while !isempty(Q)
        i, found = dequeue!(Q)

        if found
            return true
        end

        for option in options
            j = i + length(option) - 1
            if j ≤ length(target) && target[i:j] == option
                found = j == length(target)
                enqueue!(Q, (j + 1, found))
            end
        end
    end
    return false
end

function can_make_display(target, options)
    isempty(target) && return true
    return any(options) do option
        length(option) ≤ length(target) || return false
        option == target[1:length(option)] || return false
        return can_make_display(target[(length(option) + 1):end], options)
    end || false
end

function part1(A, B)
    sum(enumerate(B)) do (i, target)
        # println("$i/$(length(B))")
        can_make_display(target, A)
    end
end

function number_of_ways_to_make_display_slow(target, options)
    # target, found, count
    Q = Queue{String}()
    n = 0
    for option in options
        length(option) ≤ length(target) || continue
        option == target[1:length(option)] || continue

        n += target == option
        enqueue!(Q, target[(length(option) + 1):end])
    end
    while !isempty(Q)
        target = dequeue!(Q)

        if isempty(target)
            n += 1
        end

        for option in options
            length(option) ≤ length(target) || continue
            option == target[1:length(option)] || continue
            enqueue!(Q, target[(length(option) + 1):end])
        end
    end
    return n
end

DP = Dict()  # dynamic programming/memoisation
function number_of_ways_to_make_display_wrong(target, options, n = 0)
    haskey(DP, target) && return DP[target]
    if isempty(target)
        return 1
    end
    for option in options
        length(option) ≤ length(target) || continue
        startswith(target, option) || continue
        # n += target == option
        n += number_of_ways_to_make_display_wrong(target[(length(option) + 1):end], options, n)
    end
    DP[target] = n
    return n
end

DP = Dict()  # dynamic programming/memoisation
function number_of_ways_to_make_display(target, options)
    haskey(DP, target) && return DP[target]

    n = 0
    n += isempty(target)

    for option in options
        length(option) ≤ length(target) || continue
        startswith(target, option) || continue
        n += number_of_ways_to_make_display(target[(length(option) + 1):end], options)
    end

    DP[target] = n

    return n
end

function part2(A, B)
    sum(enumerate(B)) do (i, target)
        println("$i/$(length(B))")
        number_of_ways_to_make_display(target, A)
    end
end

function main()
    data = parse_input("data19.txt")
    # data = parse_input("data19.test.txt")

    # Part 1
    part1_solution = part1(data...)
    # @assert part1_solution ==
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data...)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()


# NOT 7751713902318070855, too high
