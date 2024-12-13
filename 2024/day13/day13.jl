# Today was fun.  We were given a list of claw machines, where the target location
# (on an imaginary 2D grid) was specified, along with two buttons.  Each button
# moved the claw a specified amount in the x and y direction.  Pressing button a
# cost 3 tokens and pressing button b cost 1.  The idea was to find a minimal
# solution such that button presses add together to put the claw above the prize,
# but we spend as few tokens as possible.
#
# The obvious solution to this was linear programming (LP).  I've used JuMP before,
# which is great (though I don't use it between AoC each year so always forget its
# syntax/API!).  I recall feeling similar success from its use in day 16 of 2022
# (the pipes and valves one).
#
# When I initially started the problem, I went through a couple of iterations of
# possible solutions.  I was even concerned for a little while that I would have
# to use a non-linear solver, like I tried to do in day 21 of 2022.  Nevertheless,
# I ended up writing a decent solution using LP.
#
# I had to start late today as I was at an improv show (check out PopRox!), but
# as I had already written an LP solution for part 1, part 2 was very fast to
# implement: we just had to add a large number to the target.  I was oviously
# missing something "simple" in part one because adapting my solution for part
# 2 was far too easy.  There must have been a brute force solution for part 1 that
# I didn't find.

using JuMP, GLPK


### Parse Input ###

mutable struct Machine
    a::CartesianIndex{2}
    b::CartesianIndex{2}
    prize::CartesianIndex{2}  # target
end

const BUTTON_PAT = r"^Button (?:A|B): X\+(?<x>\d+), Y\+(?<y>\d+)$"
const PRIZE_PAT = r"^Prize: X=(?<x>\d+), Y=(?<y>\d+)$"

function parse_button(s::AbstractString)
    m = match(BUTTON_PAT, strip(s))
    @assert !isnothing(m)
    x, y = parse.(Int, (m[:x], m[:y]))
    return CartesianIndex{2}(y, x)
end

function parse_prize(s::AbstractString)
    m = match(PRIZE_PAT, strip(s))
    @assert !isnothing(m)
    x, y = parse.(Int, (m[:x], m[:y]))
    return CartesianIndex{2}(y, x)
end

function parse_machine(s::AbstractString)
    A = split(strip(s), '\n')
    @assert length(A) == 3
    as, bs, ps = A
    button_a = parse_button(as)
    button_b = parse_button(bs)
    prize = parse_prize(ps)
    return Machine(button_a, button_b, prize)
end

function parse_input(input_file::String)
    S = strip(read(input_file, String))
    return Machine[parse_machine(s) for s in split(S, "\n\n")]
end


### Part 1 ###

# Use linear programming to solve the equation to minimize the number of tokens spent
function solve(machine::Machine)
    m = Model(GLPK.Optimizer)

    # Number of button presses a and b
    @variable(m, a >= 0, Int)
    @variable(m, b >= 0, Int)

    # Button presses must add to target in order to win prize
    # Can't use cartesian indices directly so have to check each dimension separately
    @constraint(m, [i=1:2], a * machine.a.I[i] + b * machine.b.I[i] == machine.prize.I[i])

    # Minimize number of button presses
    @objective(m, Min, 3a + b)
    optimize!(m)

    # If no optimal solution is found, return zeros
    # In real life, you wouldn't want to return valid numbers as it implies
    # a solution was found, but for this situation it is good enough
    termination_status(m) == MOI.OPTIMAL || return 0, 0

    # Otherwise, we found a solution
    return round.(Int, (value(a), value(b)))
end

# Find the sum of tokens required to win prizes on a list of machines
function solve(machines::Vector{Machine})
    return sum(machines) do machine
        a, b = solve(machine)
        3a + b
    end
end

part1(data::Vector{Machine}) = solve(data)


### Part 2 ###

# add 10 trillion offset to target
function offset_target!(machine::Machine; offset::Int = 10_000_000_000_000)
    machine.prize += CartesianIndex(offset, offset)
    return machine
end

function part2(data)
    offset_target!.(data)
    return solve(data)
end


### Main ###

function main()
    data = parse_input("data13.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 36571
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 85527711500010
    println("Part 2: $part2_solution")
end

main()
