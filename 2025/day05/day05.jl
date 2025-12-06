# Today's problem was pretty basic, but I struggled a bit on part 2.  We have two parts
# to the input; the first part was a list of integer ranges, representing the range of
# IDs for fresh ingredients, and the second part was a simple integer list representing
# the available ingredients we have.
#
# In part 1 of the problem, we were simply asked to count the available ingredients
# that are fresh (i.e., whose IDs exist in the ranges in the first part of the input.
# This was very simple.
#
# In part 2 of the problem, we disregarded the available ingredients list; the elves
# wanted to know how many unique ingredients there are in the ranges of fresh ingredients.
# "Unique" here is important as the ranges are potentially overlapping.
#
# I was _hoping_ Julia would have some kind of convenient union-ing for unit ranges, as
# this sounds like something Julia would have.  I also tried finding "tricks" online to
# this, as I was sure it had come up before, but I didn't find anything useful.  Alas, I
# had to think of the logic myself.  Even though it's not an _extremely_ difficult problem,
# it was just not something I had thought about before, so it was certainly interesting.
#
# My first intuition was simple: first, we implement a function to check if two ranges
# can be joined into one (I would call these contiguous [1]).  Then, for each pair, we
# can join the ranges that can be joined, and continue this process until the list of
# ranges were maximally simplified [2, 3].  I _think_ this would have worked.  It worked
# on the test data, but it was incredibly slow on the large input and never finished
# running.  (At least _I_ know that I implemented it myself.)
#
# After going back to the drawing board, I found a whole list of algorithms on Rosetta
# code for exactly this problem.  I adapted the algorithm for Julia [4], which itself
# was adapted for the Python algorithm.  I made it more "Julian," using unit ranges
# instead of pairs.
#
# The trick with this algorithm is to basically do what I did but in one pass, which
# works if the input is sorted.  The only issue I had from here was that
# sort!(::Vector{UnitRange{Int}}) was _incredibly_ slow.  It was sufficient to just sort
# by the start of each range.
#
# JP as usual has a cool solution to find the size of the union of all ranges: [5].
#
# [1]: github.com/jakewilliami/advent-of-code/blob/173209b2/2025/day05/day05.jl#L55-L71
# [2]: github.com/jakewilliami/advent-of-code/blob/173209b2/2025/day05/day05.jl#L93-L108
# [3]: reddit.com/r/adventofcode/comments/1pf799n/comment/nshvqxv
# [4]: rosettacode.org/wiki/Range_consolidation#Julia
# [5]: github.com/jonathanpaulson/AdventOfCode/blob/16e28057/2025/5.py#L14-L26


### Parse Input ###

function parse_input(input_file::String)
    ranges, list = split(readchomp(input_file), "\n\n")

    # Parse fresh ingredient IDs as list of ranges
    R = UnitRange{Int}[]
    for r in eachsplit(ranges, '\n')
        a, b = parse.(Int, split(r, '-'))
        push!(R, a:b)
    end

    # Parse available ingredients list
    A = Int[parse(Int, i) for i in eachsplit(list, '\n')]

    return R, A
end


### Part 1 ###

function part1(data::Tuple{Vector{UnitRange{Int}}, Vector{Int}})
    fresh, available = data

    # Count up all available ingredients if they're in the fresh ranges
    return sum(available) do id
        any(id ∈ r for r in fresh)
    end
end


### Part 2 ###

# Adapted from:
#   https://rosettacode.org/wiki/Range_consolidation#Julia
function consolidate_ranges!(Rs::Vector{UnitRange{Int}})
    # Need to specify sort by startbecause sort!(::Vector{UnitRange}) is sooooo slow
    sort!(Rs, by = r -> r.start)
    to_delete = Set{Int}()

    # Iterator over every range in the list
    for i in 1:length(Rs)
        # Skip over a range if it has been consolidated into another
        i ∈ to_delete && continue
        r₁ = Rs[i]

        # For each pair in the list, see if we can consolidate the two ranges
        for j in i+1:length(Rs)
            j ∈ to_delete && continue
            r₂ = Rs[j]

            # If the intersection of the two ranges is not empty---i.e., r₁ stops
            # before or when r₂ starts---then we can merge them.
            #
            # Equivalent to checking if r₁.stop < r₂.start.
            isempty(r₁ ∩ r₂) && continue

            # Define the new, consolidated range
            r₁′ = r₁.start:max(r₁.stop, r₂.stop)
            Rs[i] = r₁ = r₁′

            # We have successfully merged range at index j into the range
            # at index i, so we want to exclude range at index j from now on
            push!(to_delete, j)
        end
    end

    # Delete empty as they have been absorbed by consolidated ranges
    deleteat!(Rs, sort!(collect(to_delete)))

    return Rs
end

function part2(data::Tuple{Vector{UnitRange{Int}}, Vector{Int}})
    data, _ = deepcopy(data)
    consolidate_ranges!(data)
    return sum(length, data)
end


### Main ###

function main()
    data = parse_input("data05.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 607
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 342433357244012
    println("Part 2: $part2_solution")
end

main()
