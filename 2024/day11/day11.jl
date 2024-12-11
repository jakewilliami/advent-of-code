# We are given a small list of integers.  They represent engravings on
# stones.  Stones' engravings change (and stones multiply) according to
# some rules.  Every time you blink, the set of stones change.  In part
# one, we simulated 25 blinks, and in part two, 75 blinks.  After the
# simulation period, all we need to do is count the number of stones.
#
# The problem states that the order matters, but it doesn't.  I knew
# what was coming in the second part because I remember the lanternfish
# so vividly (2021, day 6), but I simulated it naïvely anyway in part
# one.  Of course, we don't have enough memory or time to do this in
# part two.  The idea instead is to keep track of the number of times
# each stone value appears, using a count map.  This is because there
# are fewer unique stone values than stones in the list, so it's much
# less resource intensive.  Each simulation step ("blink"), we can
# increment the count by the number of times the stone's value has
# already been seen

using AdventOfCode.Parsing
using DataStructures


### Parse Input ###

parse_input(input_file::String) = get_integers(read(input_file, String))


### Part 1 ###

# Split a number down the middle into two numbers
function splitnum(n::Int)
    h = 10^(ndigits(n) ÷ 2)
    left = n ÷ h
    right = n % h
    return left, right
end

# Simulate change of one number based on the rules:
#   - If the number is zero, it changes to one;
#   - If the number has an even number of digits, it splits down the
#      middle and turns into two numbers;
#   - Otherwise, it multiplies by 2,024.
function change(s::Int)
    iszero(s) && return Int[1]
    iseven(ndigits(s)) && return Int[splitnum(s)...]
    return Int[s * 2024]
end

# Simulate (in-place) change for all rocks in the set in one blink
function blink!(S::Vector{Int})
    # Initialise vector to keep track of stones that need to multiply
    M = Tuple{Int, Vector{Int}}[]

    # First pass: apply simple changes (i.e., replacing one value with
    # another one)
    for (i, s) in enumerate(S)
        s′ = change(s)

        if isone(length(s′))
            S[i] = only(s′)
        else
            # If the change is more complex, store for next step
            push!(M, (i, s′))
        end
    end

    # Second pass: now handle expansion
    for (offset, (i, s′)) in enumerate(M)
        # We can handle offset using `enumerate` because the numbers only
        # split into two so the offset increments by just one each time
        splice!(S, i + offset - 1, s′)
    end

    return S
end

function part1(data::Vector{Int})
    # Simulate 25 blinks
    for i in 1:25
        blink!(data)
    end

    return length(data)
end


### Part 2 ###

function part2(data::Vector{Int})
    # Simulate 75 blinks

    # Initialise the count map with initial data
    D = DefaultDict(0)
    for d in data
        D[d] += 1
    end

    # Heavily inspired by lanternfish solution I recalled:
    # https://www.youtube.com/watch?v=fHlWM8CIrlI
    #
    # There are much fewer unique types of engravings we can get
    # than the stones in the list
    for i in 1:75
        D′ = DefaultDict(0)
        for (s, n) in D
            for s′ in change(s)
                D′[s′] += n
            end
        end
        D = D′
    end

    return sum(values(D))
end


### Main ###

function main()
    data = parse_input("data11.txt")

    # Part 1
    part1_solution = part1(deepcopy(data))
    @assert part1_solution == 198089
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(deepcopy(data))
    @assert part2_solution == 236302670835517
    println("Part 2: $part2_solution")
end

main()
