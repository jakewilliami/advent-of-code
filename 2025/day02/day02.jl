# We are given a comma-separated list of unit ranges.  Each integer in these
# ranges are IDs.  In part 1, we are asked to find the IDs in each range that
# are made up of two repeating numbers (e.g., 11, 1212, 123123).  In part 2,
# we have to find the IDs in each range that are made up of two or more repeat-
# ing numbers (e.g., 11, 1212, 121212, 999, 565656).
#
# I had to start this day late as I was out with my brother, but after I started
# the first part, I solve it in about 10–15 minutes.  I started implementing it
# as I would implement part 2, because I didn't realise part 1 was as simple as
# it was.  Because I had already basically (accidentally) implemented part 2 in
# part 1, it only took 3 more minutes.
#
# Conveniently, I have some code that I...took inspiration from, in order to find
# repeating substrings in strings.  This is from LinearShiftRegisters.jl.
#
# Overall, quite a simple day, and more happy with it than yesterday (even though,
# on paper, because I was delayed to start, I didn't do as well.  But no global
# leaderboard this year so who cares!).


### Parse Input ###

function parse_input(input_file::String)
    S = readchomp(input_file)
    P = split(S, ',')
    Q = Tuple{Int, Int}[parse.(Int, Tuple(split(p, '-'))) for p in P]
    R = UnitRange{Int}[a:b for (a, b) in Q]
    return R
end


### Part 1 ###

function halve(s::String)
    # Cannot split string in half if its length is odd
    isodd(length(s)) && return nothing

    mid = length(s) ÷ 2
    return s[1:mid], s[mid + 1:end]
end

function is_invalid₁(id::Int)
    s = halve(string(id))
    isnothing(s) && return false

    # If both halves are the same then the ID is invalid, as we have to
    # check that the _whole_ string is repeating:
    #
    #   "any ID which is made only of some sequence of digits repeated twice"
    a, b = s
    return a == b
end

function sum_invalids(data::Vector{UnitRange{Int}}, predicate)
    # For each unit range, check each ID in the range
    return sum(data) do rng
        sum(rng) do id
            # If the ID matches a predicate, add that ID to the
            # resulting sum
            predicate(id) ? id : 0
        end
    end
end

part1(data::Vector{UnitRange{Int}}) = sum_invalids(data, is_invalid₁)


### Part 2 ###

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

function is_invalid₂(id::Int)
    s = string(id)
    r = _repeated_substring(s)
    isnothing(r) && return false

    # Here we find repeated substrings in the string which can be repeated
    # two times or more.
    #
    #   "made only of some sequence of digits repeated at least twice"
    return count(r, s) >= 2
end

part2(data::Vector{UnitRange{Int}}) = sum_invalids(data, is_invalid₂)


### Main ###

function main()
    data = parse_input("data02.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 23560874270
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 44143124633
    println("Part 2: $part2_solution")
end

main()
