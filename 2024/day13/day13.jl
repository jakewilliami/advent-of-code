using AdventOfCode.Parsing, AdventOfCode.Multidimensional
# using Base.Iterators
# using Statistics
# using LinearAlgebra
# using Combinatorics
# using DataStructures
# using StatsBase
# using IntervalSets
# using OrderedCollections

const Button = CartesianIndex{2}
const Prize = CartesianIndex{2}

struct Machine
    a::Button
    b::Button
    prize::Prize  # target
end

const BUTTON_PAT = r"Button (?:A|B): X\+(?<x>\d+), Y\+(?<y>\d+)"
const PRIZE_PAT = r"Prize: X=(?<x>\d+), Y=(?<y>\d+)"

function parse_line(s, pat, T)
    m = match(pat, s)
    @assert !isnothing(m)
    x, y = parse.(Int, (m[:x], m[:y]))
    return T(y, x)
end

function parse_button(s)
    m = match(BUTTON_PAT, s)
    @assert !isnothing(m)
    x, y = parse.(Int, (m[:x], m[:y]))
    return Button(y, x)
end

function parse_prize(s)
    m = match(PRIZE_PAT, s)
    @assert !isnothing(m)
    x, y = parse.(Int, (m[:x], m[:y]))
    return Prize(y, x)
end

function parse_machine(s)
    A = split(s, '\n')
    @assert length(A) == 3
    button_a = parse_button(A[1])
    button_b = parse_button(A[2])
    prize = parse_prize(A[3])
    return Machine(button_a, button_b, prize)
end

function parse_input(input_file::String)
    # M = readlines_into_char_matrix(input_file)
    S = strip(read(input_file, String))
    return [parse_machine(strip(s)) for s in split(S, "\n\n")]
    # L = strip.(readlines(input_file))
    # L = get_integers.(L)

    return L
end

# 3 tokens to push button a and one to push button b
#
# What is the smallest number of tokens you would have to spend to win as many prizes as possible?

# NL Solve?
# https://github.com/jakewilliami/advent-of-code/blob/master/2022/day21/day21.jl

using JuMP, GLPK

function solve(machines)
    cost_a = 3
    cost_b = 2
    model = Model(GLPK.Optimizer)

    # Variables
    @variable(model, x[1:length(machines)], Bin)  # x[i] = 1 if machine i is used, 0 otherwise

    # Objective: Minimize the total cost
    # @objective(model, Min, sum(cost_a * x[i] + cost_b * x[i] for i in 1:length(machines)))

    # Constraints: Ensure that we can only win a prize if we press the buttons
    # @constraint(model, [i in 1:length(machines)], x[i] * (machines[i].a + machines[i].b) >= machines[i].prize)

    # Solve
    optimize!(model)
end

# Can we with a prize with `tokens` tokens on `machine`?
# recursion inspired by https://github.com/jonathanpaulson/AdventOfCode/blob/c58061ba/2024/7.py#L14-L23 from day 7
function wins_prize(machine, tokens, state = 𝟘(2))
    # println(tokens)
    # break condition: we won a prize
    if state == machine.prize
        return true
    end

    if tokens ≥ 3 && wins_prize(machine, tokens - 3, state + machine.a)
        return true
    end

    if tokens ≥ 1 && wins_prize(machine, tokens - 1, state + machine.b)
        return true
    end

    return false
end

# What is the fewest tokens you would have to spend to win all possible prizes?

function solve_presses_to_win(machine)
    # TODO: this doesn't account for how much it costs
    A = hcat(Int[Tuple(machine.a)...], Int[Tuple(machine.b)...])
    b = vcat([Tuple(machine.prize)...])
    # Use matrix solving in Julia
    X = A \ b
    if !all(isinteger, X)
        return false, 0, 0
    end
    @assert length(X) == 2
    a, b = round.(Int, X)
    return true, a, b
end

function solve_presses_to_win(machine)
    # A = hcat(Int[Tuple(machine.a)...], Int[Tuple(machine.b)...])
    # b = vcat([Tuple(machine.prize)...])

    m = Model(GLPK.Optimizer)

    # number of button presses a and b
    @variable(m, a >= 0, Int)
    @variable(m, b >= 0, Int)

    # button presses must add to target to win prize
    # @constraint(m, machine.a * value(a) + machine.b * value(b) == machine.prize)
    @constraint(m, [i=1:2], a * machine.a.I[i] + b * machine.b.I[i] == machine.prize.I[i])

    # minimize number of button presses
    @objective(m, Min, 3a + b)

    optimize!(m)

    if termination_status(m) == MOI.OPTIMAL
        @assert all(isinteger, (value(a), value(b)))
        optimal_a = round(Int, value(a))
        optimal_b = round(Int, value(b))

        return true, optimal_a, optimal_b
    end

    return false, 0, 0
end

function solve(machines)
end

function part1(data)
    # machine = data[3]
    # solve(data)
    # solve_presses_to_win(machine)

    r = 0
    for (i, machine) in enumerate(data)
        # println("$i/$(length(data))")
        solvable, a, b = solve_presses_to_win(machine)
        if solvable
            r += 3a + b
        end
    end
    return r
end

# obviously missed something "simple" in part one if part two was so easy to modify to solve.  must have been a brute force soltion i didn't find

function part2(data)
    r = 0
    for (i, machine) in enumerate(data)
        println("$i/$(length(data))")
        machine = Machine(machine.a, machine.b, machine.prize + CartesianIndex(10000000000000, 10000000000000))
        solvable, a, b = solve_presses_to_win(machine)
        if solvable
            r += 3a + b
        end
    end
    return r
end

function main()
    data = parse_input("data13.txt")
    # data = parse_input("data13.test.txt")

    # Part 1
    part1_solution = part1(data)
    # @assert part1_solution ==
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    # @assert part2_solution ==
    println("Part 2: $part2_solution")
end

main()
