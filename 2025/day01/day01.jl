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
#
# After the intial solution (01c231c), I added models to help solve the problem
# (2f64a2d), but part 2 is still naïvely solved.


### Parse Input ###

@enum Direction begin
    left = -1
    right = 1
end

Base.parse(::Type{Direction}, c::Char) =
    c == 'L' ? left  :
    c == 'R' ? right :
    throw(ArgumentError("Invalid direction char: $c"))

struct Instruction
    d::Direction  # Direction of rotation
    n::Int        # Number of notches to rotate the dial
end

function Base.parse(::Type{Instruction}, input::AbstractString)
    d = parse(Direction, input[1])
    n = parse(Int, input[2:end])
    return Instruction(d, n)
end

function parse_input(input_file::String)
    L = strip.(readlines(input_file))
    return Instruction[parse(Instruction, x) for x in L]
end


### Part 1 ###

mutable struct State
    position::Int  # Position of the dial
    max_n::Int     # Number of notches on the dial
    counter::Int   # Counter for puzzle answer
end

State() = State(50, 100, 0)  # Default configuration

# Prod on Instruction gives the distance _and_ direction
Base.prod(inst::Instruction) = Int(inst.d) * inst.n

function part1(data::Vector{Instruction})
    state = State()

    for inst in data
        state.counter += iszero(state.position)
        state.position = mod(state.position + prod(inst), state.max_n)
    end

    return state.counter
end


### Part 2 ###

function part2(data::Vector{Instruction})
    state = State()

    for inst in data
        i = 0
        while i < inst.n
            state.counter += iszero(state.position)
            state.position = mod(state.position + Int(inst.d), state.max_n)
            i += 1
        end
    end

    return state.counter
end


### Main ###

function main()
    data = parse_input("data01.txt")
    # data = parse_input("data01.test.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 1118 part1_solution
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 6289
    println("Part 2: $part2_solution")
end

main()
