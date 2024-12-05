# We are given two chunks of data separated by a blank line.  The first data are
# pairs of numbers, a and b (ordered), which specify a custom ordering: a must come
# before b.  The second chunk of data is rows of lists of numbers (I naïvely call
# these data the powerset).
#
# Part one requires us to find the rows of the second chunk of data that are in
# order as per the specified custom ordering instructions (and then count up
# certain elements in these sets).
#
# In part two, we are to find the sets that *aren't* in order, and order then (and
# then count up certain elements in these newly ordered sets).
#
# This day took me a while.  I was actually rather stumped at the problem, but I
# don't know why.  I also had a bug where I tried to extend Julia's Base.Order.Ordering
# type but I wasn't getting the correct answer so I had to use a different solution
# where I manually sort the lists.  Nevertheless, it was quite fun once I figured out
# a solution.  This problem reminded me of day 13 of 2022.

using DataStructures: DefaultDict


### Parse Input ###

function parse_input(input_file::String)
    S = strip(read(input_file, String))
    S1, S2 = split(S, "\n\n")

    # Get instructions as a list of tuples
    I = Tuple{Int, Int}[Tuple(parse.(Int, split(l, '|'))) for l in split(S1, '\n')]

    # Get a powerset 𝒫 (\scrP); a list of vectors with order and possible duplicates
    𝒫 = Vector{Int}[parse.(Int, split(l, ',')) for l in split(S2, '\n')]

    return Instructions(I), 𝒫
end

struct Instructions
    # Values indicate all numbers that should come strictly after the key
    data::DefaultDict{Int, Vector{Int}}

    function Instructions(data::Vector{Tuple{Int, Int}})
        D = DefaultDict{Int, Vector{Int}}(Vector{Int})

        for (a, b) in data
            push!(D[a], b)
        end

        new(D)
    end
end

const I, 𝒫 = parse_input("data05.txt")


### Part 1 ###

# As per the provided instructions, is a allowed to come before b?
allowed_before(a::Int, b::Int, I::Instructions) =
    b ∈ I.data[a]

# As per the provided instructions, is a allowed to come before all elements of b?
function allowed_before(a::Int, b::Vector{Int}, I::Instructions)
    return all(1:length(b)) do i
        allowed_before(a, b[i], I)
    end
end

# Check that the given set is correctly ordered as per the provided instructions
function allowed_order(S::Vector{Int}, I::Instructions)
    # The idea is to look through each element of the set and ensure that all
    # elements that succeed it are allowed to do so
    return all(1:length(S)) do i
        allowed_before(S[i], S[i + 1:end], I)
    end
end

function part1(I::Instructions, 𝒫::Vector{Vector{Int}})
    return sum(𝒫) do S
        allowed_order(S, I) || return 0
        S[length(S) ÷ 2 + 1]
    end
end


### Part 2 ###

# Define new ordering type based on the instructions provided.
#
# Note that I tried to do this earlier but couldn't get it to work in good
# time, so I ended up going with a more manual sort solution:
# <https://github.com/jakewilliami/advent-of-code/blob/6e34547/2024/day05/day05.jl#L86-L166>
#
# Since refactoring in 6e34547, this method now magically works.  I suspect
# there might have been a bug in the old allowed_before function because it
# was greedy so it was good enough for part one but not for proper sorting.
# Now that we use this Instructions type that stores data internally with
# all available information, adding a custom ordering type works.
struct InstructionOrder <: Base.Order.Ordering end
Base.Order.lt(_o::InstructionOrder, a, b) = allowed_before(a, b, I)

function part2(I::Instructions, 𝒫::Vector{Vector{Int}})
    return sum(𝒫) do S
        allowed_order(S, I) && return 0
        sort!(S, order = InstructionOrder())
        S[length(S) ÷ 2 + 1]
    end
end


### Main ###

function main()
    # Part 1
    part1_solution = part1(I, 𝒫)
    @assert part1_solution == 5509
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(I, 𝒫)
    @assert part2_solution == 4407
    println("Part 2: $part2_solution")
end

main()
