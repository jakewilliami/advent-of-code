# In this problem, we have a dial on a circle of numbers; sequentially 0 to 99.
# Each line of the puzzle input is an instruction: a direction (left or right)
# in which you rotate the dial, and the number of notches that the dial is rotated.
#
# In part one, after each instruction is actioned, we are to count the number of
# times the dial falls on 0.  In part two, we are to count the number of times the
# dial falls on zero, even in passing (during an instruction),
#
# My performance today wasn't great.  It was harder than I expected, even though
# it was a simple problem.  The first problem I was getting wrong as I read the
# following:
#   the number of times the dial is left pointing at 0 after any rotation in the
#   sequence
#
# I read this as the dial has to be "left-pointing" and "at 0", not left (stopped)
# at zero!  So that lost quite a bit of time.  And then in part 2, I tried a "clever"
# solution which didn't work because I'm dumb (premature optimisation and all that),
# so then I refactored it into a naïve solution but I had some old code in the loop
# that was erroneously counting up some of the time, so the answer was only off by
# a small number.  Despite the poor performance, it was fun.


### Parse Input ###

function parse_input(input_file::String)
    L = strip.(readlines(input_file))
    return Tuple{Char, Int}[(x[1], parse(Int, x[2:end])) for x in L]
end


### Part 1 ###

function part1(data::Vector{Tuple{Char, Int}})
    dial, res = 50, 0
    modifiers = Dict{Char, Int}('L' => -1, 'R' => 1)

    for (d, n) in data
        res += iszero(dial)
        modifier = modifiers[d]
        dial = mod(dial + n * modifier, 100)
    end

    return res
end


### Part 2 ###

function part2(data::Vector{Tuple{Char, Int}})
    dial, res = 50, 0
    modifiers = Dict{Char, Int}('L' => -1, 'R' => 1)

    for (d, n) in data
        modifier = modifiers[d]
        i = 0
        while i < n
            dial = mod(dial + modifier, 100)
            res += iszero(dial)
            i += 1
        end
    end
    return res
end


### Main ###

function main()
    data = parse_input("data01.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 1118
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 6289
    println("Part 2: $part2_solution")
end

main()
