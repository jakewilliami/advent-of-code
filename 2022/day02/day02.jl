# Today's problem was straight forward: model the game of paper scissors rock.  Our input
# was a list of pairs of characters, the first column containing A–C, the second containing
# X–Z.
#
# Part 1 states that the first column can be mapped to your opponent's move: rock, paper,
# or scissors.  The second column, we assume, is what we should pick.
#
# In part 2, we realise that the second column should be mapped to the outcome of the the
# game: lose, win, or draw.
#
# If A beats B, B beats C, and C beats A, then finding the winner given a pair of moves is
# some trivial modulo maths.


### Parse input

parse_input(f::String) = Pair{Char, Char}[line[1] => line[end] for line in readlines(f)]


### Part 1

@enum Play rock = 1 paper scissors
@enum Outcome lose = 0 win = 6 draw = 3

const COL1_MAP = Dict{Char, Play}('A' => rock, 'B' => paper, 'C' => scissors)
const COL2_MAP_1 = Dict{Char, Play}('X' => rock, 'Y' => paper, 'Z' => scissors)

parse_input_1(data::Vector{Pair{Char, Char}}) =
    Pair{Play, Play}[COL1_MAP[a] => COL2_MAP_1[b] for (a, b) in data]

# Does play b beat play a?
function wins(a::Play, b::Play)
    a == b && return draw
    won = Play(mod1(Int(a) + 1, 3)) == b
    return won ? win : lose
end

play(input::Union{Vector{Pair{Play, Play}}, Vector{Pair{Play, Outcome}}}) =
    sum(Int(b) + Int(wins(a, b)) for (a, b) in input)


### Part 2

const COL2_MAP_2 = Dict{Char, Outcome}('X' => lose, 'Y' => draw, 'Z' => win)

parse_input_2(data::Vector{Pair{Char, Char}}) =
    Pair{Play, Outcome}[COL1_MAP[a] => COL2_MAP_2[b] for (a, b) in data]

function wins(a::Play, b::Outcome)
    b == draw && return a
    return Play(b == win ? mod1(Int(a) + 1, 3) : mod1(Int(a) - 1, 3))
end


### Main

function main()
    raw_data = parse_input("data02.txt")

    # Part 1
    part1_data = parse_input_1(raw_data)
    part1_solution = play(part1_data)
    @assert part1_solution == 10595
    println("Part 1: $part1_solution")

    # Part 2
    part2_data = parse_input_2(raw_data)
    part2_solution = play(part2_data)
    @assert part2_solution == 9541
    println("Part 2: $part2_solution")
end

main()


### Main (Linear Algebra)

# reddit.com/r/adventofcode/comments/zac2v2/2022_day_2_solutions/iynysrx
#
# While this solution is really cool, it is not as efficient; 979.906 μs
# (12500 allocations: 429.69 KiB), compared to 6.245 μs (0 allocations: 0 bytes).
# I implemented part 1 using this anyway as I saw it on Reddit and thought
# it was cool.

using LinearAlgebra

function main_lin_alg()
    ROCK_BASIS, PAPER_BASIS, SCISSORS_BASIS = eachcol(I(3))

    RPC_M = [
        3 0 6
        6 3 0
        0 6 3
    ]

    RPC_BASES = Dict{Play, AbstractVector}(
        rock => ROCK_BASIS,
        paper => PAPER_BASIS,
        scissors => SCISSORS_BASIS,
    )

    play_lin_alg(a::Play, b::Play) = Outcome(transpose(RPC_BASES[b]) * RPC_M * RPC_BASES[a])
    play_lin_alg(input::Vector{Pair{Play, Play}}) =
        sum(Int(b) + Int(play_lin_alg(a, b)) for (a, b) in input)


    raw_data = parse_input("data02.txt")

    part1_data = parse_input_1(raw_data)
    part1_solution = play_lin_alg(part1_data)
    @assert part1_solution == 10595
    println("Part 1 (using Linear Algebra): $part1_solution")
end
