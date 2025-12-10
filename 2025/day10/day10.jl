# Each line of our input represented a machine.  Each machine had a target "lighting"
# configuration, in which some were turned on and others turned off; a number of
# button wiring schematic; and joltage requirements.  Each button wiring schematic
# told us which lights (by index) to toggle when using that button.  For example, the
# button wiring schematic might be (0, 1, 5), so using that button you would toggle
# lights 1, 2, and 6 respectively.
#
# In part 1, we can ignore joltage.  For each machine, we are asked to find the smallest
# combination of buttons to press in order to get the target lighting configuration
# (starting with all lights being off).  I solved this the trivial way, with BFS.
# I even used a vector to store and update the lighting configuration, rather than
# doing the memory-conscious thing of storing them in a bitmask.  This solution was
# trivial, but I took about 45 minutes to complete it as I was tired and the structure
# of the input was slightly convoluted.
#
# In part 2, we can ignore the target lighting configuration and focus on the joltage
# requirements.  Instead of a button toggling the lights, the add to the joltage of
# those lights.  BFS does not work here.  In fact, this is very clearly a job for
# linear programming, as we have a target vector and we need some combination of input
# vectors to sum to it.  I used linear programming, as I did in day 13 last year, but
# I think this is probably solvable using basic matrix solving.
#
# Overall a fun day.  Part 2 was non-trivial and I don't tend to use LP any time other
# than December, so it took me a while to get to the solution.

using DataStructures
using JuMP, GLPK


### Parse Input ###

struct Wiring
    data::Vector{Int}
end

struct Target
    lighting::BitVector
    joltage::Vector{Int}
end

struct Machine
    target::Target
    buttons::Vector{Wiring}
end

function _parse_collection(s::AbstractString)
    @assert length(s) > 2
    # The collection should be bounded by braces
    b1, b2 = first(s), last(s)
    @assert b1 * b2 ∈ ("()", "[]", "{}")
    return s[2:end - 1]
end

function parse_collection(s::AbstractString)
    s = _parse_collection(s)
    return parse.(Int, split(s, ','))
end

function parse_machine(s::AbstractString)
    parts = split(s)

    # Lights target
    lights_config = _parse_collection(first(parts))
    lights = falses(length(lights_config))
    lights[findall(==('#'), lights_config)] .= true

    # Buttons
    parse_button(s::AbstractString) = Wiring(parse_collection(s) .+ 1)
    buttons = parse_button.(parts[2:end - 1])

    # Joltage requirements
    joltages = parse_collection(parts[end])

    # Construct machine structure
    target = Target(lights, joltages)
    return Machine(target, buttons)
end

function parse_input(input_file::String)
    L = strip.(readlines(input_file))
    return Machine[parse_machine(line) for line in L]
end


### Part 1 ###

function apply_button!(lighting::BitVector, button_wiring::Wiring)
    lighting[button_wiring.data] .⊻= true
    return lighting
end

function solve1(machine::Machine)
    target = machine.target.lighting
    start = falses(length(target))

    # Short circuit BFS if the starting configuration is already the target
    start == target && return 0

    # Set up data structures for BFS
    Q, seen = Queue{Tuple{BitVector, Int}}(), Set{BitVector}()
    push!(Q, (start, 0))
    push!(seen, start)

    # Perform BFS, keeping track of current state and number of operations
    # to get there
    while !isempty(Q)
        current_state, n = popfirst!(Q)

        # Explore the different buttons' effects on the current state
        for (i, button) in enumerate(machine.buttons)
            # Perform the operation for the present button
            new_state = copy(current_state)
            apply_button!(new_state, button)

            # Skip the new state if we have already seen it
            new_state ∈ seen && continue
            push!(seen, new_state)

            # Greedily stop the algorithm and return the number of operations
            # it took to get here, if the new state is the target one
            new_state == target && return n + 1

            # Otherwise, keep looking
            push!(Q, (new_state, n + 1))
        end
    end

    error("unreachable: all machines should have a solution")
end

part1(data::Vector{Machine}) = sum(solve1, data)


### Part 2 ###

# Adapted from:
#     https://github.com/jakewilliami/advent-of-code/blob/af2ca6b0/2024/day13/day13.jl#L71-L94
function solve2(machine::Machine)
    m = Model(GLPK.Optimizer)

    # Extract required information from machine model
    buttons, target = machine.buttons, machine.target.joltage
    B, n = length(buttons), length(target)

    # Non-zero, integer button presses
    @variable(m, x[1:B] >= 0, Int)

    # Sum of button effects equals the target
    @constraint(
        m,
        [i=1:n],
        sum(x[b] * (i ∈ buttons[b].data) for b in 1:B) == target[i],
    )

    # Minimise number of button presses
    @objective(m, Min, sum(x[b] for b in 1:B))
    optimize!(m)

    # If no optimal solution is found, return zeros
    # In real life, you wouldn't want to return valid numbers as it implies a solution
    # was found, but for this situation it is good enough
    termination_status(m) == MOI.OPTIMAL || return nothing

    # Otherwise, we found a solution
    return round.(Int, value.(x))
end

part2(data::Vector{Machine}) = sum(sum ∘ solve2, data)


### Main ###

function main()
    data = parse_input("data10.txt")

    # Part 1
    part1_solution = part1(data)
    @assert part1_solution == 547
    println("Part 1: $part1_solution")

    # Part 2
    part2_solution = part2(data)
    @assert part2_solution == 21111
    println("Part 2: $part2_solution")
end

main()
