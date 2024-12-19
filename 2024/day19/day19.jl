# Another easy problem today (though I was slow because I started late).  The
# input consists of two parts: a list of towels by their colour, and a list of
# target displays.  The goal is to use the first list to construct elements in
# the second, thereby creating these colourful displys of towels.
#
# In part 1, we had to count how many displays are possible to make with our
# collection of towels.  In part 2, we had to count the number of ways we can
# make these arrangements.
#
# Both parts were a nice, simple exercise of recursion.  The only slight trick
# is that part 2 is too slow to run in any reasonable time without memoisation.


### Parse Input ###

function parse_input(input_file::String)
    S = strip(read(input_file, String))
    S1, S2 = split(S, "\n\n")

    S1′ = String.(split(S1, ", "))
    S2′ = String.(split(S2, "\n"))

    # S1 is towel options, S2 is target displays
    return S1′, S2′
end


### Part 1 ###

function can_make_display(target::String, options::Vector{String})
    isempty(target) && return true
    return any(options) do option
        length(option) ≤ length(target) || return false
        startswith(target, option) || return false
        return can_make_display(target[(length(option) + 1):end], options)
    end || false
end

part1(options::Vector{String}, targets::Vector{String}) =
    sum(can_make_display(target, options) for target in targets)


### Part 2 ###

function ways_to_make_display(
    target::String,
    options::Vector{String},
    mem = Dict{String, Int}(),
)
    # Memoisation is required to compute this in any reasonable time
    haskey(mem, target) && return mem[target]

    # If the target is empty then we have found a solution
    n = isempty(target)

    for option in options
        length(option) ≤ length(target) || continue
        startswith(target, option) || continue
        n += ways_to_make_display(target[(length(option) + 1):end], options, mem)
    end

    mem[target] = n

    return n
end

part2(options::Vector{String}, targets::Vector{String}) =
    sum(ways_to_make_display(target, options) for target in targets)


### Main ###

function main()
    options, targets = parse_input("data19.txt")

    # Part 1
    part1_solution = part1(options, targets)
    @assert part1_solution == 358
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(options, targets)
    @assert part2_solution == 600639829400603
    println("Part 2: $part2_solution")
end

main()
